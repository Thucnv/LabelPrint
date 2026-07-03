# Architecture & Database Schema - Label Print

## 1. Kiến trúc ứng dụng (Clean Architecture & BLoC)
Hệ thống được tổ chức thành 3 lớp riêng biệt:

### Lớp Presentation (Giao diện & State Management)
* **Thành phần:** UI Screens, Widgets, BLoC/Cubit.
* **Quy tắc:** Chỉ tương tác với Use Cases của lớp Domain, quản lý state bằng `flutter_bloc`.

### Lớp Domain (Logic Nghiệp vụ Thuần)
* **Thành phần:** Entities, Use Cases, Repository Interfaces.
* **Quy tắc:** Mã nguồn Dart thuần túy, không phụ thuộc vào thư viện bên ngoài hay UI. Chứa các contract giao tiếp.

### Lớp Data (Dữ liệu & Triển khai thực tế)
* **Thành phần:** Repository Implementations, Models, Data Sources (Local/Remote).
* **Quy tắc:** Triển khai các interface từ Domain. Thao tác trực tiếp với cơ sở dữ liệu SQLite, Bluetooth, Socket.

---

## 2. Cấu trúc thư mục dự án
```
lib/
├── main.dart                          # Entry point, khởi tạo DI
├── app.dart                           # MaterialApp, Routing, Theme & L10n setup
├── core/                              # Shared Core (dùng chung)
│   ├── constants/                     # Hằng số hệ thống
│   ├── theme/                         # Theme, Colors, Typography
│   ├── l10n/                          # File đa ngôn ngữ (.arb)
│   ├── widgets/                       # Widget dùng chung (TextField, Button, Badge...)
│   ├── utils/                         # Helper (Binarization, Dithering, Command Generators)
│   ├── errors/                        # Custom Exceptions & Failures
│   └── di/                            # Dependency Injection (get_it)
├── domain/                            # Lớp Domain
│   ├── entities/                      # Business Entities & Enums
│   ├── repositories/                  # Contract Interfaces
│   └── usecases/                      # Single-responsibility logic classes
├── data/                              # Lớp Data
│   ├── models/                        # Models ánh xạ DB/JSON (extends Entities)
│   ├── datasources/                   # SQLite helpers & Local data sources
│   └── repositories/                  # Triển khai thực tế Repository
└── presentation/                      # Lớp Presentation (UI + BLoC)
    ├── home/                          # Home Screen & Cubit
    ├── printer_management/            # Printer Management Screen & Bloc
    ├── print_config/                  # Print Config Screen & Cubit
    └── barcode/                       # Barcode Printing Screen & Bloc
```

---

## 3. Cơ sở dữ liệu nội bộ (SQLite DDL)

### printers
```sql
CREATE TABLE printers (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    type TEXT CHECK(type IN ('LABEL', 'RECEIPT')) NOT NULL,
    protocol TEXT CHECK(protocol IN ('TSPL', 'ESC_POS')) NOT NULL,
    connection_method TEXT CHECK(connection_method IN ('BLUETOOTH', 'WIFI')) NOT NULL,
    bt_mac_address TEXT UNIQUE,
    wifi_ip TEXT,
    wifi_port INTEGER DEFAULT 9100,
    is_default INTEGER CHECK(is_default IN (0, 1)) DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### printer_configs
```sql
CREATE TABLE printer_configs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    printer_id INTEGER NOT NULL,
    paper_size TEXT DEFAULT 'A6',
    paper_type TEXT DEFAULT 'LABEL',
    orientation TEXT CHECK(orientation IN ('PORTRAIT', 'LANDSCAPE')) DEFAULT 'PORTRAIT',
    margin_top REAL DEFAULT 0.0,
    margin_left REAL DEFAULT 0.0,
    margin_right REAL DEFAULT 0.0,
    print_darkness INTEGER DEFAULT 8,
    print_speed REAL DEFAULT 4.0,
    scaling_mode TEXT CHECK(scaling_mode IN ('FIT_WIDTH', 'FIT_HEIGHT', 'CUSTOM')) DEFAULT 'FIT_WIDTH',
    scaling_value INTEGER DEFAULT 100,
    FOREIGN KEY(printer_id) REFERENCES printers(id) ON DELETE CASCADE
);
```

### print_jobs
```sql
CREATE TABLE print_jobs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    printer_id INTEGER NOT NULL,
    job_name TEXT NOT NULL,
    document_type TEXT CHECK(document_type IN ('BARCODE', 'QR', 'LABEL', 'SHIPPING_LABEL', 'DELIVERY_NOTE', 'RECEIPT', 'PDF', 'IMAGE')) NOT NULL,
    total_pages INTEGER DEFAULT 1,
    copies INTEGER DEFAULT 1,
    status TEXT CHECK(status IN ('PENDING', 'PRINTING', 'SUCCESS', 'FAILED')) DEFAULT 'PENDING',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(printer_id) REFERENCES printers(id)
);
```

### print_history
```sql
CREATE TABLE print_history (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    job_id INTEGER NOT NULL,
    printed_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    success_pages INTEGER DEFAULT 0,
    error_log TEXT,
    FOREIGN KEY(job_id) REFERENCES print_jobs(id) ON DELETE CASCADE
);
```

### templates
```sql
CREATE TABLE templates (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL,
    width_mm INTEGER NOT NULL,
    height_mm INTEGER NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
```

### template_items
```sql
CREATE TABLE template_items (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    template_id INTEGER NOT NULL,
    type TEXT CHECK(type IN ('TEXT', 'BARCODE', 'QR', 'IMAGE', 'SHAPE')) NOT NULL,
    pos_x REAL NOT NULL,
    pos_y REAL NOT NULL,
    width REAL NOT NULL,
    height REAL NOT NULL,
    content TEXT,
    style_metadata TEXT,
    FOREIGN KEY(template_id) REFERENCES templates(id) ON DELETE CASCADE
);
```

### app_settings
```sql
CREATE TABLE app_settings (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    setting_key TEXT UNIQUE NOT NULL,
    setting_value TEXT NOT NULL
);
```

---

## 4. Quy trình in & Sinh lệnh máy in (Communication Flow)
Đoạn mã in ấn chia làm 3 phần: **Tối ưu hóa kích thước** (Resize/Scale), **Command Generator** (Tạo mảng byte thô) và **Transport Connection** (Gửi byte qua Socket/Bluetooth).

```
[Nguồn: PDF, Ảnh, Barcode]
       ↓
[Tối ưu hóa & Resize kích thước] (Chuyển đổi kích thước ảnh khớp độ phân giải máy in & Căn lề byte)
       ↓
[Binarization / Dithering] (Chuyển sang ảnh Bitmap đơn sắc 1-bit)
       ↓
[Command Generator]
 - TSPL:   Gửi lệnh kích thước (SIZE, GAP) + lệnh BITMAP (vẽ ảnh bitmap đơn sắc)
 - ESC/POS: Gửi lệnh định dạng + lệnh GS v 0 (Raster bit image)
       ↓
[Kênh truyền thông (Bluetooth RFCOMM / TCP Socket Port 9100)] (Gửi chuỗi Byte thô)
       ↓
[Máy in vật lý]
```

### 4.1 Tối ưu hóa kích thước & Độ phân giải (Image Scaling & Byte Alignment)
Để tránh hiện tượng máy in bị tràn bộ đệm nhận (Buffer Overflow) dẫn đến việc in ra mảng byte thô hoặc các ký tự rác, hình ảnh đầu vào sẽ được tối ưu hóa trước khi tạo tập lệnh:

1. **Giải mã & Tính tỷ lệ:** Giải mã hình ảnh ban đầu bằng `instantiateImageCodec` để lấy chiều rộng, chiều cao và tỷ lệ khung hình (Aspect Ratio).
2. **Xác định kích thước đích (Target Dots):**
   * **TSPL:** `targetWidth = effectiveWidthMm * 8` (dựa trên mật độ điểm in tiêu chuẩn 8 dots/mm - 203 DPI).
   * **ESC/POS:** Căn cứ theo khổ giấy rộng cấu hình, nếu khổ nhỏ (≤ 60mm) thì cố định `targetWidth = 384 dots` (K57), ngược lại cố định `targetWidth = 576 dots` (K80).
   * **Chiều cao (Height):**
     * Đối với **giấy liên tục (Continuous Paper)**: Chiều cao `targetHeight = (targetWidth * aspectRatio).round()`.
     * Đối với **giấy nhãn (Label Paper)**: Chiều cao bị giới hạn bởi `maxLabelHeightDots = effectiveHeightMm * 8`. Chiều cao thực tế `targetHeight` được xác định theo chế độ co giãn (`fitWidth`, `fitHeight`, hoặc `custom` tỷ lệ phần trăm).
3. **Căn lề byte (Byte Alignment):** Chiều rộng đích bắt buộc phải được làm tròn lên bội số của 8 (`targetWidth = ((targetWidth + 7) ~/ 8) * 8`). Việc này đảm bảo mỗi hàng quét ngang (raster line) chứa số byte nguyên vẹn, tránh lỗi lệch bit (bit-shift) làm hình ảnh bị sọc hoặc nghiêng trên máy in nhiệt.
4. **Native Downscaling:** Sử dụng API `instantiateImageCodec(bytes, targetWidth, targetHeight)` của Flutter để hệ điều hành giải mã và thu nhỏ ảnh bằng mã máy (native code) trực tiếp theo kích thước đích, giúp tiết kiệm bộ nhớ RAM và tối ưu hóa hiệu suất CPU/GPU.

### 4.2 Cấu hình loại giấy & Căn lề giấy (Paper Type & Feed Control)
1. **Giấy nhãn (Label) & Giấy vạch đen (Black Mark):** Giao thức TSPL sử dụng cảm biến khoảng cách/vạch đen để căn lề tự động, gửi lệnh `GAP m mm, 0 mm` hoặc `BLINE m mm, 0 mm` để thiết lập kích thước lề tem.
2. **Giấy liên tục (Continuous):**
   * Giao thức TSPL truyền lệnh cấu hình `GAP 0,0` để vô hiệu hóa kiểm tra cảm biến khoảng cách, tránh lỗi chạy trống/timeout.
   * **Lệnh kéo giấy cuối trang (Feed 80 dots):** Đối với giấy liên tục, sau khi in xong nội dung, đầu in nhiệt thường nằm sau thanh xé giấy của máy in. Vì vậy, ứng dụng tự động chèn lệnh `FEED 80` ở cuối tệp lệnh TSPL để đẩy giấy tiến thêm 80 dots (~10mm), giúp người dùng xé giấy dễ dàng mà không làm mất hoặc rách nội dung in.

### 4.3 Tối ưu hóa số bản in (Print Copies)
1. **TSPL (Native Copies):**
   * Số lượng bản sao được truyền trực tiếp qua lệnh `PRINT copies,1`.
   * Cách này giúp máy in tự sao chép bản in trực tiếp trên bộ nhớ đệm phần cứng, chỉ cần truyền ảnh bitmap thô một lần duy nhất qua Bluetooth/WiFi, cải thiện 90% hiệu suất truyền và tăng độ ổn định của kết nối.
2. **ESC/POS (Single-Session Packet):**
   * Do giao thức ESC/POS không có lệnh sao chép ảnh bitmap trực tiếp trên phần cứng, ứng dụng sử dụng `BytesBuilder` để lặp lại mảng byte lệnh in của toàn bộ hình ảnh `copies` lần.
   * Gửi toàn bộ mảng bytes này trong duy nhất một phiên kết nối. Điều này giúp máy in liên tục in và cắt các bản sao một cách liền mạch, đồng thời tránh việc liên tục đóng/mở socket hay kết nối Bluetooth (vốn là nguyên nhân hàng đầu gây sập kết nối BLE).

---

## 5. Quy trình nhận dữ liệu chia sẻ từ hệ điều hành (Sharing Intent Flow)
Ứng dụng hỗ trợ nhận chia sẻ trực tiếp hình ảnh từ các ứng dụng khác thông qua tính năng Share/Send của hệ điều hành.

### Sơ đồ luồng xử lý:
```
[Hệ điều hành (Android Share Sheet)]
       ↓ (Người dùng chọn chia sẻ ảnh đến LabelPrinter)
[MainActivity (với intent-filter SEND image/* và launchMode="singleTask")]
       ↓ (Ứng dụng khởi chạy hoặc khôi phục)
[LabelPrintApp (StatefulWidget)]
  - Lắng nghe luồng dữ liệu chia sẻ bằng `receive_sharing_intent`
  - Bắt sự kiện chia sẻ:
      + Warm start (khi app đang chạy ngầm): getMediaStream()
      + Cold start (khi app đã đóng hoàn toàn): getInitialMedia()
       ↓ (Trích xuất đường dẫn file ảnh chia sẻ đầu tiên)
[GoRouter Navigation]
  - Chuyển hướng màn hình đến `/print-preview`
  - Truyền dữ liệu `extra: { 'documentType': 'image', 'imagePath': path }`
       ↓
[PrintPreviewScreen]
  - Nhận `extraData` và tự động phân giải `resolvedDocumentType` thành `DocumentType.image`
  - Khởi tạo `PrintPreviewCubit` với `resolvedDocumentType`
       ↓
[GeneratePreviewBitmap (Usecase)]
  - Nhận `imagePath` từ tham số truyền vào
  - Đọc file ảnh từ ổ đĩa thành byte (`File(imagePath).readAsBytes()`)
       ↓ (Trả về Uint8List bytes)
[PrintPreviewCubit]
  - Cập nhật ảnh bitmap xem trước `previewImage` vào State
       ↓
[PreviewCanvas (UI Screen)]
  - Render ảnh `Uint8List` trực tiếp lên Canvas đồ họa phục vụ việc xem trước và điều chỉnh kích thước nhãn.
```
