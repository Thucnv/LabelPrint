# Project Metadata - Label Print

## 1. Thông tin chung
* **Tên dự án:** Label Print
* **Package Name:** `com.chuot.labelPrint`
* **Nền tảng:** Android (Target SDK 34 - Android 14)
* **Ngôn ngữ:** Dart (Flutter framework)

## 2. Công nghệ cốt lõi & Package chính
* **State Management:** `flutter_bloc` & `equatable`
* **Dependency Injection:** `get_it`
* **Navigation:** `go_router`
* **Local Database:** `sqflite` & `path`
* **Bluetooth:** `flutter_blue_plus` (Classic & BLE)
* **Fonts:** `google_fonts` (Inter)
* **Ads:** `google_mobile_ads` (Firebase Remote Config cho Unit IDs)
* **Barcode:** `barcode` & `barcode_widget`
* **Functional Programming:** `dartz` (Either type)
* **Sharing Intent:** `receive_sharing_intent` (Nhận chia sẻ hình ảnh/tài liệu từ hệ điều hành)
* **Image Selection:** `image_picker` (Chọn ảnh từ thư viện thiết bị)
* **File Selection:** `file_picker` (Chọn tệp tin hệ thống, ví dụ PDF)
* **PDF Processing:** `pdfx` (Đọc tài liệu và render các trang PDF thành ảnh chất lượng cao)

## 3. Khổ giấy & Loại giấy hỗ trợ
* **Khổ giấy:** A5, A6, A7, A8, Custom Width x Height (20mm - 220mm)
* **Loại giấy:** Decal cảm nhiệt (Label/Decal), Hóa đơn thường (Continuous/Ticket), Giấy vạch đen (Black Mark)

## 4. Giao thức máy in (Protocols)
* **TSPL:** Dùng cho in nhãn nhiệt (Label printer)
* **ESC/POS:** Dùng cho in hóa đơn nhiệt (Receipt printer)

## 5. Tính năng chính (Phase 1)
* In mã vạch (Barcode)
* In mã QR (QR Code)
* In nhãn tự do (Label)
* In nhãn vận chuyển (Shipping Label)
* In phiếu giao hàng (Delivery Note)
* In hóa đơn bán hàng (Sales Receipt)
* In tài liệu PDF (PDF Document)
* In hình ảnh (Image)
