# KẾ HOẠCH TRIỂN KHAI - ỨNG DỤNG LABEL PRINT (FLUTTER)

Tài liệu này mô tả chi tiết kế hoạch triển khai Phase 1 của ứng dụng **Label Print** (`com.chuot.labelPrint`) bằng Flutter, tuân thủ Clean Architecture, BLoC pattern, và các nguyên tắc code sạch.

---

## User Review Required

> [!IMPORTANT]
> **State Management:** Kế hoạch sử dụng **flutter_bloc** (Cubit + BLoC). Nếu bạn muốn dùng Riverpod hoặc Provider thay thế, xin cho biết trước khi bắt đầu code.

> [!IMPORTANT]
> **Database:** Kế hoạch sử dụng **sqflite** theo đúng DDL đã định nghĩa trong BRD. Nếu muốn chuyển sang Drift (type-safe) hoặc Isar, xin xác nhận.

> [!IMPORTANT]
> **Localization:** Kế hoạch sử dụng hệ thống `flutter_localizations` + file `.arb` chính thức của Flutter (gen-l10n). Nếu muốn dùng `easy_localization` với file `.json`, xin cho biết.

---

## Open Questions

> [!WARNING]
> **Min SDK:** BRD ghi Target SDK 34. Cần xác nhận **minSdkVersion** là bao nhiêu? (Khuyến nghị: `21` để hỗ trợ ~99% thiết bị Android).

> [!NOTE]
> **Google AdMob App ID:** Bạn đã có App ID của AdMob chưa? Nếu chưa, tôi sẽ dùng ID test mặc định của Google và đặt placeholder trong `AndroidManifest.xml`.

---

## Proposed Changes

Dự án sẽ được chia thành **5 bước tuần tự**. Mỗi bước phải hoàn thành và verify trước khi chuyển bước tiếp.

---

### Bước 1: [COMPLETED] Khởi tạo dự án Flutter & Cấu trúc thư mục Clean Architecture

#### [NEW] Khởi tạo Flutter project

Chạy `flutter create` với cấu hình:
- Project name: `label_print`
- Package name: `com.chuot.labelPrint`
- Platform: Android only
- Tổ chức: `com.chuot`

#### [NEW] Cấu trúc thư mục Clean Architecture

```
lib/
├── main.dart                          # Entry point, khởi tạo DI, chạy App
├── app.dart                           # MaterialApp, routing, theme, localization setup
│
├── core/                              # ═══ SHARED CORE (dùng chung toàn app) ═══
│   ├── constants/
│   │   └── app_constants.dart         # Hằng số toàn cục (timeout, max file size, DPI...)
│   ├── theme/
│   │   ├── app_colors.dart            # Bảng màu Industrial Precision
│   │   ├── app_text_styles.dart       # Typography tokens (heading, body, caption...)
│   │   └── app_theme.dart             # ThemeData Light/Dark tổng hợp
│   ├── l10n/
│   │   ├── app_vi.arb                 # Chuỗi tiếng Việt
│   │   └── app_en.arb                 # Chuỗi tiếng Anh
│   ├── widgets/                       # ═══ REUSABLE WIDGETS ═══
│   │   ├── custom_text_field.dart     # Ô nhập chuẩn hóa (label, error, suffixIcon)
│   │   ├── primary_button.dart        # Nút bấm chính (gradient, micro-animation)
│   │   ├── secondary_button.dart      # Nút bấm phụ (outlined)
│   │   ├── printer_status_badge.dart  # Chip trạng thái máy in (màu theo trạng thái)
│   │   ├── printer_card.dart          # Card hiển thị máy in trong danh sách
│   │   ├── section_header.dart        # Tiêu đề phân nhóm (dùng lại ở nhiều form)
│   │   ├── ad_banner_slot.dart        # Container chứa AdMob banner
│   │   └── loading_overlay.dart       # Overlay loading toàn màn hình
│   ├── utils/
│   │   ├── validators.dart            # Validation IP, barcode, tên máy in...
│   │   ├── image_utils.dart           # Floyd-Steinberg Dithering, Binarization
│   │   ├── printer_commands/
│   │   │   ├── tspl_generator.dart    # Sinh lệnh TSPL từ Bitmap
│   │   │   └── escpos_generator.dart  # Sinh lệnh ESC/POS từ Bitmap
│   │   └── bluetooth_utils.dart       # Helper quét/kết nối Bluetooth
│   ├── errors/
│   │   ├── failures.dart              # Lớp Failure trừu tượng
│   │   └── exceptions.dart            # Custom Exceptions (theo bảng Error BRD)
│   └── di/
│       └── injection_container.dart   # Dependency Injection (get_it)
│
├── domain/                            # ═══ DOMAIN LAYER (Business Logic thuần) ═══
│   ├── entities/
│   │   ├── printer.dart               # Entity Printer
│   │   ├── printer_config.dart        # Entity PrinterConfig
│   │   ├── print_job.dart             # Entity PrintJob
│   │   └── template.dart              # Entity Template
│   ├── repositories/
│   │   ├── printer_repository.dart    # Interface (abstract class) cho Printer
│   │   ├── config_repository.dart     # Interface cho PrinterConfig
│   │   ├── print_job_repository.dart  # Interface cho PrintJob/History
│   │   └── template_repository.dart   # Interface cho Template
│   └── usecases/
│       ├── printer/
│       │   ├── get_all_printers.dart
│       │   ├── add_printer.dart
│       │   ├── update_printer.dart
│       │   ├── delete_printer.dart
│       │   ├── set_default_printer.dart
│       │   └── test_connection.dart
│       ├── config/
│       │   ├── get_config.dart
│       │   ├── save_config.dart
│       │   └── save_as_template.dart
│       └── barcode/
│           ├── generate_barcode.dart
│           └── print_barcode.dart
│
├── data/                              # ═══ DATA LAYER (Triển khai cụ thể) ═══
│   ├── models/
│   │   ├── printer_model.dart         # Model ↔ JSON/SQLite map (extends Entity)
│   │   ├── printer_config_model.dart
│   │   ├── print_job_model.dart
│   │   └── template_model.dart
│   ├── datasources/
│   │   └── local/
│   │       ├── database_helper.dart   # SQLite init, migration, DDL
│   │       ├── printer_local_ds.dart  # CRUD thao tác bảng printers
│   │       ├── config_local_ds.dart   # CRUD thao tác bảng printer_configs
│   │       ├── print_job_local_ds.dart
│   │       └── template_local_ds.dart
│   └── repositories/
│       ├── printer_repository_impl.dart
│       ├── config_repository_impl.dart
│       ├── print_job_repository_impl.dart
│       └── template_repository_impl.dart
│
└── presentation/                      # ═══ PRESENTATION LAYER (UI + BLoC) ═══
    ├── home/
    │   ├── bloc/
    │   │   ├── home_cubit.dart
    │   │   └── home_state.dart
    │   ├── widgets/
    │   │   ├── printer_status_widget.dart
    │   │   └── feature_grid.dart
    │   └── home_screen.dart
    ├── printer_management/
    │   ├── bloc/
    │   │   ├── printer_list_bloc.dart
    │   │   ├── printer_list_event.dart
    │   │   └── printer_list_state.dart
    │   ├── widgets/
    │   │   ├── add_printer_dialog.dart
    │   │   └── scan_devices_sheet.dart
    │   └── printer_management_screen.dart
    ├── print_config/
    │   ├── bloc/
    │   │   ├── print_config_cubit.dart
    │   │   └── print_config_state.dart
    │   ├── widgets/
    │   │   ├── paper_size_selector.dart
    │   │   ├── margin_input_row.dart
    │   │   └── darkness_slider.dart
    │   └── print_config_screen.dart
    └── barcode/
        ├── bloc/
        │   ├── barcode_bloc.dart
        │   ├── barcode_event.dart
        │   └── barcode_state.dart
        ├── widgets/
        │   ├── barcode_preview_canvas.dart
        │   └── barcode_type_selector.dart
        └── barcode_screen.dart
```

---

### Bước 2: [COMPLETED] Cấu hình Theme, Màu sắc & Đa ngôn ngữ

#### [NEW] [app_colors.dart](file:///Users/thucnguyen/Documents/Work/book/LabelPrinter/lib/core/theme/app_colors.dart)

Định nghĩa bảng màu **Industrial Precision** dưới dạng `abstract final class`:

| Token | Hex | Mô tả |
|-------|-----|-------|
| `primary` | `#4F46E5` | Indigo 600 - Nút hành động chính |
| `primaryLight` | `#818CF8` | Indigo 400 - Hover, active state |
| `primaryDark` | `#3730A3` | Indigo 800 - Pressed state |
| `background` | `#F8FAFC` | Slate 50 - Nền sáng |
| `surface` | `#FFFFFF` | White - Card, Dialog |
| `surfaceVariant` | `#F1F5F9` | Slate 100 - Nền phụ |
| `onSurface` | `#1E293B` | Slate 800 - Text chính |
| `onSurfaceVariant` | `#64748B` | Slate 500 - Text phụ |
| `divider` | `#E2E8F0` | Slate 200 - Đường kẻ |
| `success` | `#16A34A` | Green 600 - Trạng thái Sẵn sàng |
| `warning` | `#F59E0B` | Amber 500 - Cảnh báo |
| `error` | `#DC2626` | Red 600 - Lỗi |
| `statusIdle` | `#94A3B8` | Slate 400 - Trạng thái Chờ |

#### [NEW] [app_text_styles.dart](file:///Users/thucnguyen/Documents/Work/book/LabelPrinter/lib/core/theme/app_text_styles.dart)

Typography sử dụng Google Font **Inter** (hỗ trợ tiếng Việt rõ nét):

| Token | Size | Weight | Sử dụng |
|-------|------|--------|---------|
| `headingLg` | 24sp | Bold (700) | Tiêu đề màn hình |
| `headingMd` | 20sp | SemiBold (600) | Tiêu đề phân mục |
| `headingSm` | 16sp | SemiBold (600) | Tiêu đề card |
| `bodyLg` | 16sp | Regular (400) | Nội dung chính |
| `bodyMd` | 14sp | Regular (400) | Nội dung phụ |
| `bodySm` | 12sp | Regular (400) | Caption, ghi chú |
| `button` | 14sp | SemiBold (600) | Text nút bấm |
| `label` | 12sp | Medium (500) | Nhãn trường nhập |

#### [NEW] [app_theme.dart](file:///Users/thucnguyen/Documents/Work/book/LabelPrinter/lib/core/theme/app_theme.dart)

Tổng hợp `ThemeData` cho light mode, áp dụng `AppColors` và `AppTextStyles` vào toàn bộ `ColorScheme`, `AppBarTheme`, `CardTheme`, `ElevatedButtonTheme`, `InputDecorationTheme`, `BottomNavigationBarTheme`.

#### [NEW] [app_vi.arb](file:///Users/thucnguyen/Documents/Work/book/LabelPrinter/lib/core/l10n/app_vi.arb)

File ngôn ngữ tiếng Việt chứa tất cả chuỗi hiển thị theo đặc tả BRD:

```json
{
  "@@locale": "vi",
  "appTitle": "Label Print",
  "homeTitle": "Trang chủ",
  "printerManagement": "Quản lý máy in",
  "printConfig": "Cấu hình bản in",
  "saveTemplate": "Lưu bản mẫu",
  "barcodePrinting": "In mã vạch",

  "featureBarcode": "In Mã Vạch",
  "featureQr": "In Mã QR",
  "featureLabel": "In Nhãn Tự Do",
  "featureShipping": "Nhãn Vận Chuyển",
  "featureReceipt": "In Hóa Đơn",
  "featurePdf": "In File PDF",
  "featureImage": "In Hình Ảnh",
  "featureDelivery": "Phiếu Giao Hàng",

  "printerStatusReady": "Sẵn sàng",
  "printerStatusIdle": "Chờ",
  "printerStatusError": "Lỗi",
  "printerNotConfigured": "Chưa cấu hình máy in mặc định",

  "addPrinter": "Thêm máy in",
  "editPrinter": "Sửa máy in",
  "deletePrinter": "Xóa máy in",
  "testConnection": "In thử",
  "scanDevices": "Quét thiết bị mới",
  "printerName": "Tên máy in",
  "printerType": "Loại máy in",
  "connectionMethod": "Phương thức kết nối",
  "ipAddress": "Địa chỉ IP",
  "port": "Cổng kết nối",
  "setDefault": "Đặt làm mặc định",

  "paperSize": "Khổ giấy in",
  "paperType": "Loại giấy",
  "orientation": "Hướng giấy",
  "portrait": "Chiều dọc (Portrait)",
  "landscape": "Chiều ngang (Landscape)",
  "marginTop": "Lề trên",
  "marginLeft": "Lề trái",
  "marginRight": "Lề phải",
  "printDarkness": "Độ đậm in",
  "printSpeed": "Tốc độ in",
  "scalingMode": "Tỷ lệ co giãn",
  "fitWidth": "Vừa khít ngang",
  "fitHeight": "Vừa khít cao",
  "customScale": "Tùy chỉnh %",
  "templateName": "Tên bản mẫu",
  "saveConfig": "Lưu cấu hình",
  "saveAsTemplate": "Lưu thành bản mẫu",

  "barcodeData": "Nội dung mã vạch",
  "barcodeType": "Loại mã vạch",
  "barcodeHeight": "Chiều cao mã vạch",
  "showReadableText": "Hiển thị mã số bên dưới",
  "continuePrint": "Tiếp tục in",
  "printNow": "In ngay",

  "errPrinterNameEmpty": "Tên máy in không được để trống.",
  "errIpInvalid": "Địa chỉ IP không đúng định dạng IPv4 (Ví dụ: 192.168.1.100).",
  "errDuplicateAddress": "Máy in với địa chỉ kết nối này đã tồn tại trong danh sách.",
  "errConnectionFailed": "Không thể kết nối đến máy in. Vui lòng kiểm tra lại nguồn điện, khoảng cách Bluetooth hoặc địa chỉ IP.",
  "errPaperSizeRange": "Kích thước giấy tùy chỉnh phải nằm trong khoảng từ 20mm đến 220mm.",
  "errScaleRange": "Tỷ lệ in tùy chỉnh phải từ 50% đến 200%.",
  "errEan13Format": "Mã vạch EAN-13 phải chứa đúng 13 chữ số.",
  "errCode128Ascii": "Mã vạch Code-128 chỉ chấp nhận các ký tự chữ, số không dấu trong bảng mã ASCII.",

  "successPrinterAdded": "Đã lưu thông tin máy in thành công.",
  "successTestPrint": "Kết nối thử nghiệm thành công! Lệnh in đã được gửi đi.",
  "successConfigSaved": "Đã lưu cấu hình trang in.",
  "successTemplateSaved": "Mẫu thiết kế nhãn đã được lưu thành công vào thư viện.",
  "successPrintSent": "Đã gửi lệnh in thành công.",

  "cancel": "Hủy",
  "save": "Lưu",
  "delete": "Xóa",
  "edit": "Sửa",
  "confirm": "Xác nhận",
  "retry": "Thử lại",
  "bluetooth": "Bluetooth",
  "wifi": "WiFi",
  "labelPrinterTspl": "Nhãn (Label Printer - TSPL)",
  "receiptPrinterEscpos": "Hóa đơn (Receipt Printer - ESC/POS)"
}
```

#### [NEW] [app_en.arb](file:///Users/thucnguyen/Documents/Work/book/LabelPrinter/lib/core/l10n/app_en.arb)

File ngôn ngữ tiếng Anh tương ứng (mirror key từ `app_vi.arb`).

---

### Bước 3: [COMPLETED] Reusable Widgets (Widget dùng chung)

#### [NEW] [custom_text_field.dart](file:///Users/thucnguyen/Documents/Work/book/LabelPrinter/lib/core/widgets/custom_text_field.dart)

Widget ô nhập liệu chuẩn hóa, sử dụng lại ở:
- Form thêm/sửa máy in (tên, IP, port)
- Form cấu hình (kích thước lề, tỷ lệ %)
- Form nhập dữ liệu mã vạch
- Form nhập tên template

**Tham số cấu hình:**
- `label` (String) - Nhãn trường, lấy từ localization
- `hint` (String?) - Gợi ý
- `errorText` (String?) - Lỗi validation
- `keyboardType` (TextInputType) - Kiểu bàn phím
- `suffixIcon` (Widget?) - Icon phía sau (quét camera, eye...)
- `controller` (TextEditingController)
- `validator` (FormFieldValidator?)
- `enabled` (bool)

**Thiết kế:** Rounded border 12px, sử dụng `AppColors.divider` cho border mặc định, `AppColors.primary` cho focus, `AppColors.error` cho lỗi. Padding nội bộ 16px. Label dùng `AppTextStyles.label`.

---

#### [NEW] [primary_button.dart](file:///Users/thucnguyen/Documents/Work/book/LabelPrinter/lib/core/widgets/primary_button.dart)

Nút bấm chính, sử dụng lại ở mọi màn hình:
- "LƯU CẤU HÌNH", "IN NGAY", "TIẾP TỤC IN", "Quét thiết bị mới"

**Tham số:** `text`, `onPressed`, `isLoading`, `icon`, `isFullWidth`

**Thiết kế:**
- Background: `AppColors.primary` (gradient nhẹ từ `primaryLight` → `primary`)
- Border radius: 12px
- Chiều cao tối thiểu: 48px
- Micro-animation: Scale 0.98 khi nhấn giữ (AnimatedScale)
- Loading state: Hiển thị `CircularProgressIndicator` thay text

---

#### [NEW] [secondary_button.dart](file:///Users/thucnguyen/Documents/Work/book/LabelPrinter/lib/core/widgets/secondary_button.dart)

Nút bấm phụ: "Hủy", "LƯU THÀNH BẢN MẪU"

**Thiết kế:** Outlined style, border `AppColors.primary`, text `AppColors.primary`, background `Colors.transparent`.

---

#### [NEW] [printer_status_badge.dart](file:///Users/thucnguyen/Documents/Work/book/LabelPrinter/lib/core/widgets/printer_status_badge.dart)

Chip trạng thái máy in, sử dụng ở Home Screen (widget trạng thái) và Printer Management (mỗi card).

**Input:** `PrinterStatus` enum (`ready`, `idle`, `error`, `notConfigured`)

**Màu tự động:**
- `ready` → `AppColors.success` (xanh lục)
- `idle` → `AppColors.statusIdle` (xám)
- `error` → `AppColors.error` (đỏ)
- `notConfigured` → `AppColors.warning` (cam)

---

#### [NEW] [printer_card.dart](file:///Users/thucnguyen/Documents/Work/book/LabelPrinter/lib/core/widgets/printer_card.dart)

Card hiển thị máy in trong danh sách, sử dụng ở Printer Management Screen.

**Hiển thị:** Tên máy in, icon kết nối (WiFi/Bluetooth), badge trạng thái, thông số kỹ thuật (protocol, IP/MAC), dấu tick mặc định, 3 nút action (Test, Edit, Delete).

---

#### [NEW] [ad_banner_slot.dart](file:///Users/thucnguyen/Documents/Work/book/LabelPrinter/lib/core/widgets/ad_banner_slot.dart)

Container dành riêng cho AdMob Banner. Tự động ẩn (`height: 0`) khi không load được quảng cáo. Sử dụng ở Home Screen.

---

#### [NEW] [section_header.dart](file:///Users/thucnguyen/Documents/Work/book/LabelPrinter/lib/core/widgets/section_header.dart)

Tiêu đề phân nhóm "DANH SÁCH MÁY IN ĐÃ LƯU", "Cài Đặt Lề", "Tỷ Lệ Co Giãn"... Dùng `AppTextStyles.headingSm` + `AppColors.onSurface`.

---

### Bước 4: [COMPLETED] Domain Layer & Data Layer

#### [NEW] Domain Entities

4 entity thuần Dart (không phụ thuộc framework), đúng theo ERD trong BRD:

| Entity | Thuộc tính chính |
|--------|-----------------|
| `Printer` | id, name, type (enum), protocol (enum), connectionMethod (enum), btMacAddress?, wifiIp?, wifiPort, isDefault, createdAt |
| `PrinterConfig` | id, printerId, paperSize (enum), paperType (enum), orientation (enum), marginTop/Left/Right, printDarkness, printSpeed, scalingMode (enum), scalingValue |
| `PrintJob` | id, printerId, jobName, documentType (enum), totalPages, copies, status (enum), createdAt |
| `Template` | id, name, widthMm, heightMm, createdAt, updatedAt |

Tất cả enum được định nghĩa riêng trong `lib/domain/entities/enums/`:
- `PrinterType` → `label`, `receipt`
- `PrinterProtocol` → `tspl`, `escPos`
- `ConnectionMethod` → `bluetooth`, `wifi`
- `PaperSize` → `A5`, `A6`, `A7`, `A8`, `custom`
- `PaperType` → `label`, `continuous`, `blackMark`
- `Orientation` → `portrait`, `landscape`
- `ScalingMode` → `fitWidth`, `fitHeight`, `custom`
- `PrinterStatus` → `ready`, `idle`, `error`, `notConfigured`
- `DocumentType` → `barcode`, `qr`, `label`, `shippingLabel`, `deliveryNote`, `receipt`, `pdf`, `image`
- `JobStatus` → `pending`, `printing`, `success`, `failed`

#### [NEW] Repository Interfaces (abstract class)

Mỗi interface chỉ khai báo contract, không chứa implementation:

```dart
// Ví dụ PrinterRepository
abstract class PrinterRepository {
  Future<Either<Failure, List<Printer>>> getAllPrinters();
  Future<Either<Failure, Printer>> getPrinterById(int id);
  Future<Either<Failure, Printer?>> getDefaultPrinter();
  Future<Either<Failure, void>> addPrinter(Printer printer);
  Future<Either<Failure, void>> updatePrinter(Printer printer);
  Future<Either<Failure, void>> deletePrinter(int id);
  Future<Either<Failure, void>> setDefaultPrinter(int id);
}
```

Sử dụng `Either<Failure, T>` từ package **dartz** để xử lý lỗi functional.

#### [NEW] Use Cases

Mỗi UseCase là 1 class duy nhất với method `call()`, tuân thủ Single Responsibility Principle:

- `GetAllPrinters` → gọi `printerRepository.getAllPrinters()`
- `AddPrinter` → validate → gọi `printerRepository.addPrinter()`
- `SetDefaultPrinter` → hủy default cũ → set default mới
- `TestConnection` → tạo socket/bluetooth → gửi lệnh test → trả kết quả
- `SaveConfig` → validate range → lưu vào `configRepository`
- `SaveAsTemplate` → validate name → lưu config + name vào `templateRepository`
- `GenerateBarcode` → validate format → sinh bitmap → trả `Uint8List`
- `PrintBarcode` → lấy default printer → sinh lệnh TSPL/ESC → gửi byte

#### [NEW] Data Layer

**database_helper.dart:** Singleton quản lý SQLite, chạy DDL đúng theo BRD mục 8.2, hỗ trợ migration version.

**Models:** Mỗi model `extends` entity tương ứng, thêm `fromMap()`, `toMap()` cho SQLite read/write.

**Local Data Sources:** CRUD trực tiếp với SQLite qua `database_helper`.

**Repository Implementations:** Wrap data source, catch Exception → trả `Left(Failure)` hoặc `Right(data)`.

---

### Bước 5: [COMPLETED] Presentation Layer (4 Màn hình + BLoC)

#### [NEW] Màn 1: Home Screen (`home_screen.dart`)

**BLoC:** `HomeCubit` - Load máy in mặc định, load trạng thái kết nối.

**Layout:**
```
┌─ AppBar: "LABEL PRINT" + icon máy in (có badge trạng thái)
├─ PrinterStatusWidget: Card trạng thái máy in mặc định
├─ FeatureGrid: GridView 2 cột, 8 ô chức năng (icon + text)
├─ AdBannerSlot: Quảng cáo cố định
└─ BottomNavigationBar: [Trang chủ, Lịch sử in, Bản mẫu]
```

Sử dụng reusable: `PrinterStatusBadge`, `AdBannerSlot`, `PrimaryButton` (implicit trong grid).

---

#### [NEW] Màn 2: Printer Management Screen (`printer_management_screen.dart`)

**BLoC:** `PrinterListBloc` (Event-driven BLoC vì có nhiều sự kiện phức tạp: Load, Add, Edit, Delete, SetDefault, TestConnection, Scan).

**Events:** `LoadPrinters`, `AddPrinterEvent`, `UpdatePrinterEvent`, `DeletePrinterEvent`, `SetDefaultEvent`, `TestConnectionEvent`, `ScanBluetoothEvent`

**States:** `PrinterListInitial`, `PrinterListLoading`, `PrinterListLoaded(printers)`, `PrinterListError(message)`, `TestConnectionSuccess`, `TestConnectionFailed`

**Layout:**
```
┌─ AppBar: "QUẢN LÝ MÁY IN" + nút [+]
├─ SectionHeader: "DANH SÁCH MÁY IN ĐÃ LƯU"
├─ ListView.builder:
│   └─ PrinterCard (reusable) × N
└─ PrimaryButton: "QUÉT THIẾT BỊ MỚI (BLUETOOTH)"
```

**Dialog thêm/sửa máy in:** `AddPrinterDialog` chứa form với `CustomTextField` × 3 (Tên, IP, Port), Radio buttons (Bluetooth/WiFi, TSPL/ESC-POS).

---

#### [NEW] Màn 3: Print Config & Save Template Screen (`print_config_screen.dart`)

**BLoC:** `PrintConfigCubit` - Quản lý state cấu hình in hiện tại.

**State:** `PrintConfigState` chứa toàn bộ fields: `paperSize`, `paperType`, `orientation`, `margins`, `darkness`, `speed`, `scalingMode`, `scalingValue`, `templateName`.

**Layout:**
```
┌─ AppBar: "CẤU HÌNH BẢN IN & LƯU BẢN MẪU"
├─ ScrollView:
│   ├─ PaperSizeSelector: ChoiceChip row (A5, A6, A7, A8, Custom)
│   ├─ PaperTypeSelector: Radio buttons
│   ├─ OrientationSelector: SegmentedButton (Portrait/Landscape)
│   ├─ SectionHeader: "Cài Đặt Lề"
│   ├─ MarginInputRow: 3× CustomTextField (Top, Left, Right)
│   ├─ SectionHeader: "Độ Đậm In"
│   ├─ DarknessSlider: Slider 1-15 với label
│   ├─ SpeedDropdown: DropdownButton (2.0-6.0 ips)
│   ├─ ScalingSelector: Radio + CustomTextField cho %
│   ├─ SectionHeader: "Lưu thành bản mẫu"
│   └─ CustomTextField: Tên bản mẫu
└─ BottomBar:
    ├─ PrimaryButton: "LƯU CẤU HÌNH"
    └─ SecondaryButton: "LƯU THÀNH BẢN MẪU"
```

---

#### [NEW] Màn 4: Barcode Printing Screen (`barcode_screen.dart`)

**BLoC:** `BarcodeBloc` (Event-driven: `DataChanged`, `TypeChanged`, `HeightChanged`, `ToggleText`, `GeneratePreview`, `PrintBarcode`)

**State:** `BarcodeState` chứa `data`, `barcodeType`, `height`, `showText`, `previewImage (Uint8List?)`, `validationError`, `isPrinting`.

**Layout:**
```
┌─ AppBar: "IN MÃ VẠCH"
├─ ScrollView:
│   ├─ CustomTextField: Dữ liệu mã vạch (suffixIcon: icon camera)
│   ├─ BarcodeTypeSelector: DropdownButton (Code128, EAN13, EAN8, UPCA)
│   ├─ SectionHeader: "Chiều cao mã vạch"
│   ├─ Slider: 40-200 dots
│   ├─ SwitchListTile: "Hiển thị mã số bên dưới"
│   ├─ SectionHeader: "Xem trước"
│   └─ BarcodePreviewCanvas: Container hiển thị ảnh mã vạch realtime
└─ PrimaryButton: "TIẾP TỤC IN"
```

---

### Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: any

  # State Management
  flutter_bloc: ^8.1.0
  equatable: ^2.0.0

  # Functional Programming (Either type)
  dartz: ^0.10.0

  # Dependency Injection
  get_it: ^8.0.0

  # Database
  sqflite: ^2.4.0
  path: ^1.9.0

  # Barcode Generation
  barcode: ^2.2.0
  barcode_widget: ^2.0.0

  # Google Fonts
  google_fonts: ^6.2.0

  # Bluetooth
  flutter_blue_plus: ^1.35.0

  # Ads (placeholder)
  google_mobile_ads: ^5.2.0

  # Navigation
  go_router: ^14.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  mocktail: ^1.0.0
```

---

## Verification Plan

### Automated Tests
```bash
# Chạy sau Bước 2 - Kiểm tra theme & localization compile
flutter analyze
flutter test

# Chạy sau Bước 4 - Unit test cho Data Layer
flutter test test/data/
flutter test test/domain/

# Chạy toàn bộ sau Bước 5
flutter test
```

### Manual Verification
- **Bước 2:** `flutter run` → App hiển thị đúng font Inter, đúng bảng màu Industrial Precision, chuyển đổi được ngôn ngữ Việt ↔ Anh.
- **Bước 3:** Tạo 1 màn hình test gallery hiển thị tất cả reusable widgets để kiểm tra visual.
- **Bước 5:** Điều hướng qua 4 màn hình, nhập dữ liệu, lưu máy in, thay đổi cấu hình, xem trước mã vạch.
- **Build APK:** `flutter build apk --release` → Cài trên thiết bị thật để kiểm tra.
