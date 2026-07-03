# UI Specification - Label Print

## 1. Design System & Project Metadata
* **Stitch Project ID:** `14748630710542737198`
* **Design System:** Industrial Precision (Chuyên dụng cho thương mại/giao vận).
  * **Accent Color:** Indigo (Nút chính, trạng thái active).
  * **Background Color:** Slate (Nền phụ, thanh trạng thái).
  * **Typography:** Font **Inter** hỗ trợ tiếng Việt.
* **Quy chuẩn chung:**
  * Toàn bộ Button chính/phụ: Bo góc (Border Radius) `12px`, chiều cao tối thiểu `48px`.
  * Nút nhấn chính có hiệu ứng co giãn nhẹ `0.98` (AnimatedScale).
  * Ô nhập liệu (TextField): Bo góc `12px`, padding nội bộ `16px`.

---

## 2. Chi tiết các màn hình cốt lõi

### 2.1 Màn hình Trang chủ (Home Screen)
* **Stitch Screen ID:** `8fde02fd1d0442b488c6f857f21b3d52`
* **Thành phần UI chính:**
  * **AppBar:** Tiêu đề "LABEL PRINT", icon máy in bên phải hiển thị chỉ báo trạng thái kết nối màu sắc (Xanh: Sẵn sàng, Đỏ: Lỗi, Xám: Chưa cấu hình).
  * **PrinterStatusWidget:** Card hiển thị thông tin máy in mặc định hiện tại (Tên, địa chỉ kết nối).
  * **FeatureGrid:** Lưới 2 cột gồm 8 nút chức năng in (In Mã Vạch, In Mã QR, In Nhãn Tự Do, Nhãn Vận Chuyển, In Hóa Đơn, In File PDF, In Hình Ảnh, Phiếu Giao Hàng).
  * **AdBannerSlot:** Banner quảng cáo cố định ở chân trang (Adaptive Banner).
  * **BottomNavigationBar:** Thanh điều hướng 3 tab (Trang chủ, Lịch sử in, Bản mẫu).

### 2.2 Màn hình Quản lý máy in (Printer Management Screen)
* **Stitch Screen ID:** `c0993A519c3649d69cc510c5b7b55072`
* **Thành phần UI chính:**
  * **AppBar:** Tiêu đề "QUẢN LÝ MÁY IN" và nút `[+]` góc phải để thêm máy in mới.
  * **Card List:** Danh sách các máy in đã lưu.
    * Mỗi card hiển thị: Tên máy in, Icon kết nối (WiFi/Bluetooth), Badge trạng thái, Dấu tick xanh (nếu là mặc định), thông số kỹ thuật (protocol, IP/MAC).
    * Hành động trên card: Vuốt trái (Swipe left) mở tùy chọn Sửa/Xóa. Có 3 nút hành động trực tiếp: "Test Connection", "Sửa", "Xóa".
  * **PrimaryButton:** "QUÉT THIẾT BỊ MỚI (BLUETOOTH)" cố định ở dưới cùng.
  * **Add/Edit Printer Dialog:** Form nhập gồm: `CustomTextField` × 3 (Tên máy in, IP, Port), Radio Buttons chọn kiểu kết nối (Bluetooth/WiFi) và giao thức (TSPL/ESC-POS).
* **Trạng thái màu sắc (PrinterStatusBadge):**
  * `ready` -> Green (`#16A34A`)
  * `idle` -> Slate (`#94A3B8`)
  * `error` -> Red (`#DC2626`)
  * `notConfigured` -> Amber (`#F59E0B`)

### 2.3 Màn hình Cấu hình bản in & Lưu bản mẫu (Print Config Screen)
* **Stitch Screen ID:** `1d88b70cfA6c45d189fd9a9498b476c7`
* **Thành phần UI chính:**
  * **PaperSizeSelector:** Lựa chọn dạng ChoiceChip (A5, A6, A7, A8, Tùy chỉnh).
  * **PaperTypeSelector:** Radio buttons (Decal nhãn, Hóa đơn cuộn, Vạch đen).
  * **OrientationSelector:** SegmentedButton (Dọc / Ngang).
  * **Margin Input Row:** 3 ô `CustomTextField` nhập số (Lề trên, Lề trái, Lề phải).
  * **DarknessSlider:** Slider phạm vi `1-15`, hiển thị số hiện tại trên tổng số `15`.
  * **SpeedDropdown:** Dropdown chọn tốc độ từ `2.0` đến `6.0` ips.
  * **ScalingSelector:** Radio chọn (Fit Width, Fit Height, Custom %).
  * **TemplateNameInput:** Ô nhập tên bản mẫu.
  * **Bottom Bar:** Nút chính "LƯU CẤU HÌNH" và nút phụ "LƯU THÀNH BẢN MẪU".

### 2.4 Màn hình In mã vạch (Barcode Printing Screen)
* **Stitch Screen ID:** `fcb0239289314e1f9ce16c543bf0c9a0`
* **Thành phần UI chính:**
  * **CustomTextField:** Nhập chuỗi mã vạch, có suffix icon mở Camera quét mã.
  * **BarcodeTypeSelector:** Dropdown chọn loại mã vạch (Code128, EAN13, EAN8, UPCA).
  * **Height Slider:** Điều chỉnh chiều cao mã vạch (phạm vi 40-200 dots).
  * **SwitchListTile:** Bật/tắt hiển thị mã số bên dưới mã vạch.
  * **BarcodePreviewCanvas:** Khung hiển thị ảnh mã vạch thời gian thực (đen trên nền trắng).
  * **PrimaryButton:** "TIẾP TỤC IN" dẫn đến màn hình Xem trước bản in.

### 2.5 Màn hình Xem trước bản in (Print Preview Screen)
* **Thành phần UI chính:**
  * **AppBar:** Nền màu xanh đậm (`#0963C5`), tiêu đề căn giữa "Xem trước & in tem", nút quay lại màu trắng, không chứa các nút tùy chọn khác.
  * **Canvas (Khung preview):**
    * Nền xám nhạt (`#EFF3F8`), căn giữa tuyệt đối.
    * Hỗ trợ zoom (Pinch-to-zoom) lên đến 300% và kéo (Pan) thông qua `InteractiveViewer`.
    * Khung giấy được bo góc `4px`, viền xám mảnh (`#CBD5E1`), và đổ bóng nhẹ.
    * **Tương quan kích thước tỉ lệ thực**: Khung giấy tự động co giãn dựa trên chiều lớn nhất của khổ giấy được chọn so với A5 làm tham chiếu (210mm). Nhờ đó, các khổ giấy nhỏ hơn (như A8) sẽ hiển thị nhỏ hơn rõ rệt so với A5, bảo toàn tương quan tỉ lệ thật trên màn hình.
    * **Nhãn kích thước**: Hiển thị kích thước thực tế tính bằng inch ở phía trên (chiều rộng) và bên phải (chiều cao, xoay 90 độ), được làm tròn thông minh bằng hàm `_fmtMmToInch` (nếu là số nguyên thì không hiện phần thập phân, ví dụ `4 in`, ngược lại hiển thị 1 chữ số thập phân, ví dụ `5.8 in`).
    * Đường viền nét đứt thể hiện lề vật lý không thể in được vẽ bên trong khung giấy (chỉ vẽ khi lề > 0).
    * Hỗ trợ tự động xoay hình ảnh in bằng `RotatedBox` dựa trên hướng xoay được chọn.
  * **Bảng cấu hình in (Cuộn được khi tràn màn hình):**
    * **Khổ giấy**: Hộp chọn dạng thả xuống (DropdownButtonFormField) gồm các tùy chọn: A5 (148×210mm), A6 (105×148mm), A7 (74×105mm), A8 (52×74mm) và "Tùy chọn".
    * **Kích thước tùy chỉnh**: Ô nhập "Rộng (mm)" và "Cao (mm)" nằm cạnh nhau, chỉ hiển thị khi chọn khổ giấy "Tùy chọn".
    * **Hướng giấy**: Nhóm 4 nút xoay tròn tương ứng với góc 0°, 90°, 180°, 270°. Nút đang chọn có màu xanh lục (`#0963C5`) chữ trắng, các nút còn lại nền xám nhạt chữ xám.
    * **Độ đậm**: Thanh trượt từ 1 đến 15 kèm theo cụm nút tăng/giảm nhanh [-] và [+].
  * **Thanh nút hành động ở chân trang:**
    * Chứa một nút duy nhất "IN TEM" lớn trải dài 100% chiều rộng, màu xanh đậm (`#0963C5`), có icon máy in bên trái.

