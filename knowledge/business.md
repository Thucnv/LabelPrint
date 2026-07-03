# Business Rules & Logic - Label Print

## 1. Quản lý máy in
* **Máy in mặc định:** Chỉ cho phép duy nhất một máy in làm mặc định tại một thời điểm. Chọn máy in mới làm mặc định sẽ tự động hủy trạng thái mặc định của máy in cũ.
* **Test Connection:**
  * WiFi: Mở TCP Socket kết nối qua IP:Port. Gửi gói byte in thử nghiệm.
  * Bluetooth: Mở kênh RFCOMM SPP kết nối qua MAC Address. Gửi gói byte in thử nghiệm.
  * Gói byte in thử gồm: Logo ứng dụng, tên máy in, thông tin kết nối và chữ "Kết nối thành công!".
* **Lọc quét Bluetooth:** Chỉ hiển thị thiết bị có Major Class là `IMAGING` hoặc `PERIPHERAL`.
* **Quy tắc Validate:**
  * Tên máy in: Không được trống.
  * WiFi IP: Đúng định dạng IPv4 (`^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$`). Các octet trong khoảng `[0, 255]`.
  * WiFi Port: Số nguyên dương hợp lệ, không trống (Mặc định `9100`).
  * Trùng lặp: Không cho phép trùng IP hoặc MAC Address đã có trong DB.

## 2. Cấu hình in
* **Khổ giấy:** Tùy chỉnh (Width/Height) phải nằm trong khoảng `[20 mm, 220 mm]`.
* **Độ đậm (Darkness):** Giá trị số từ `1` (nhạt nhất) đến `15` (đậm nhất). Mặc định `8`.
* **Tốc độ in (Speed):** `2.0`, `3.0`, `4.0`, `5.0`, `6.0` ips (inch/giây). Mặc định `4.0 ips`.
* **Tỷ lệ co giãn (Scaling):**
  * `FIT_WIDTH`: Tự động co giãn nội dung theo chiều ngang khổ giấy, chiều dọc tỉ lệ theo.
  * `FIT_HEIGHT`: Tự động co giãn nội dung theo chiều dọc khổ giấy, chiều ngang tỉ lệ theo.
  * `CUSTOM`: Tỉ lệ co giãn thủ công nhập từ `50%` đến `200%`.
* **Giấy cuộn (Continuous):** Vô hiệu hóa cấu hình chiều cao giấy (Height) hoặc tự động co giãn theo chiều cao tài liệu.
* **Giấy nhãn (Label Paper):** Gửi lệnh điều chỉnh cảm biến nhãn (`GAP` sensor) trước khi thực hiện in.

## 3. Định dạng & Kiểm tra dữ liệu in
* **Mã vạch (Barcode):**
  * `EAN-13`: Đúng 13 chữ số, khớp Checksum chuẩn EAN.
  * `EAN-8`: Đúng 8 chữ số, khớp Checksum chuẩn EAN.
  * `UPC-A`: Đúng 12 chữ số.
  * `Code-128`: Chỉ chấp nhận các ký tự chuẩn ASCII (Không có dấu tiếng Việt).
  * Chiều cao mặc định: `80 dots` (~10mm).
* **Mã QR (QR Code):**
  * Sửa lỗi: Cấu hình mặc định `Level H` (High - 30% phục hồi dữ liệu).
  * WiFi QR chuỗi mã hóa: `WIFI:S:<SSID>;T:<WEP|WPA|nopass>;P:<PASSWORD>;H:<true|false>;;`
* **Nhãn tự do (Label):**
  * Layout: Xếp chồng dọc (Vertical Stack).
  * Thứ tự: [Logo/Hình ảnh] -> [Chữ] -> [Barcode/QR] -> [Footer].
  * Khoảng cách mặc định giữa các khối: `2 mm`.
* **Nhãn vận chuyển (Shipping Label):**
  * Khổ mặc định: `100x150 mm` (A6).
  * Vùng Barcode vận đơn: Chiếm tối thiểu `25%` chiều cao toàn bộ nhãn.
* **Hóa đơn bán hàng (ESC/POS):**
  * Cuối lệnh in chèn mã lệnh cắt giấy tự động (`GS V 66 0` hoặc tương đương) nếu máy in hỗ trợ.
  * Nếu không hỗ trợ dao cắt, tự động chèn thêm 5 dòng trống (`Feed Paper Lines`).
* **In PDF:**
  * Giới hạn file: Tối đa `25 MB` để tránh tràn bộ nhớ RAM (OOM).
  * Chuyển đổi: Render từng trang PDF sang Bitmap đen/trắng độ phân giải tối thiểu `203 DPI` (hoặc `300 DPI`).
  * Tự động xoay trang (Auto-Rotation) 90 độ nếu hướng giấy in (Portrait/Landscape) lệch hướng trang PDF.
* **In hình ảnh:**
  * Bộ lọc đơn sắc bắt buộc: Sử dụng thuật toán Floyd-Steinberg Dithering hoặc ngưỡng tĩnh (Binarization Threshold) để chuyển ảnh xám sang ảnh đen/trắng (1-bit monochrome).
* **In phiếu giao hàng (Delivery Note):**
  * Bố cục cấu trúc: Tiêu đề "PHIẾU GIAO HÀNG / DELIVERY NOTE", Mã phiếu, Người gửi, Người nhận, Bảng sản phẩm (Item Name, Qty, Unit), Tổng số lượng, và khu vực chữ ký xác nhận của Người giao hàng (Deliverer) và Người nhận hàng (Receiver) ở phần chân phiếu.
  * Căn chỉnh lề: Hỗ trợ tự động xuống dòng và co dãn chiều cao cho cột tên sản phẩm dài để đảm bảo không bị đè chữ lên cột số lượng và đơn vị tính trên các khổ giấy có kích thước khác nhau.
  * Độ phân giải: Render sang ảnh bitmap chất lượng cao phù hợp với khổ giấy đã chọn (dùng tỷ lệ 8 dots/mm) trước khi truyền sang luồng in.

## 4. Tích hợp quảng cáo
* **Banner Ads:** Hiển thị cố định sát bottom của màn hình Trang chủ (phía trên Bottom Navigation). Nếu load thất bại, ẩn vùng chứa (`height: 0`).
* **Interstitial Ads:** Hiển thị sau khi hoàn thành lệnh in hoặc lưu Template thành công. Giới hạn tần suất (Frequency Capping): Tối đa 1 lần mỗi 3 phút.
* **Premium state:** Ẩn hoàn toàn quảng cáo nếu tài khoản đã mua Premium.

## 5. Mã lỗi hệ thống (Error Codes)
* `ERR_PRN_001`: Chưa cấu hình máy in mặc định.
* `ERR_BT_001`: Chưa bật Bluetooth trên điện thoại.
* `ERR_BT_002`: Bị từ chối quyền Bluetooth (Android 12+: `BLUETOOTH_CONNECT`, `BLUETOOTH_SCAN`).
* `ERR_CONN_TIMEOUT`: Kết nối máy in quá thời gian chờ (Timeout 5 giây).
* `ERR_IP_INVALID`: Địa chỉ IP không hợp lệ hoặc không thuộc mạng nội bộ.
* `ERR_PAPER_UNSUPPORTED`: Kích thước giấy vượt khả năng của đầu in.
* `ERR_PDF_CORRUPT`: File PDF hỏng, được bảo mật mật khẩu hoặc không thể đọc.
* `ERR_RAM_OOM`: Tràn bộ nhớ RAM khi xử lý PDF/Hình ảnh nặng.
* `ERR_PRN_BUSY`: Máy in báo bận, kẹt giấy hoặc hết giấy.
