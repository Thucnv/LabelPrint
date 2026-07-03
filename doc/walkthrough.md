# WALKTHROUGH - DỰ ÁN LABEL PRINT

Tài liệu này tổng kết các kết quả đầu ra đã hoàn thành cho dự án ứng dụng in ấn nhãn chuyên nghiệp **Label Print** (`com.chuot.labelPrint`), bao gồm Tài liệu yêu cầu nghiệp vụ (BRD) và các bản thiết kế màn hình trên hệ thống Stitch.

---

## 1. TÀI LIỆU YÊU CẦU NGHIỆP VỤ (BRD)

Tài liệu BRD đã được biên soạn chi tiết bằng tiếng Việt và lưu trữ tại:
*   **File trong Workspace:** [BRD.md](file:///Users/thucnguyen/Documents/Work/book/LabelPrinter/doc/BRD.md)
*   **Artifact trong Workspace:** [brd_label_print.md](file:///Users/thucnguyen/.gemini/antigravity/brain/32b1A6ca-5f66-42d5-85a4-20f0e3b63c87/brd_label_print.md)

Tài liệu bao gồm đầy đủ 13 mục yêu cầu theo đặc tả của bạn, bao gồm Phân khúc người dùng, Lộ trình, Yêu cầu chức năng chi tiết, Sơ đồ luồng (Mermaid), Cấu trúc CSDL (DDL & ERD), Xử lý lỗi, Yêu cầu phi chức năng và Kiến trúc kỹ thuật khuyến nghị (Flutter Clean Architecture).

---

## 2. KẾT NỐI STITCH & THIẾT KẾ GIAO DIỆN (UI SCREENS)

Một dự án Stitch mới đã được tạo thành công:
*   **Stitch Project ID:** `14748630710542737198`
*   **Project Title:** Label Print
*   **Hệ thống thiết kế áp dụng:** Industrial Precision (Chuyên dụng cho môi trường thương mại, giao vận; sử dụng tông màu Indigo làm điểm nhấn trên nền Slate nhẹ nhàng, font chữ Inter hỗ trợ tiếng Việt sắc nét).

Dưới đây là chi tiết các màn hình cốt lõi đã được thiết kế và tạo lập thành công:

### 2.1 Màn hình Trang chủ (Home Screen)
*   **Stitch Screen ID:** `8fde02fd1d0442b488c6f857f21b3d52`
*   **Mô tả:** Màn hình chính của ứng dụng với tiêu đề thương hiệu, widget hiển thị trạng thái kết nối máy in mặc định, lưới chức năng in ấn 2 cột (In mã vạch, mã QR, hóa đơn, nhãn vận chuyển...) và **phần diện tích dành riêng cho quảng cáo Banner** nằm cố định ngay phía trên thanh điều hướng Bottom Navigation Bar.
*   **Ảnh chụp thiết kế:**
    ![Home Screen Preview](https://lh3.googleusercontent.com/aida/AP1WRLtjmU38D6NT5ygR5QQxJ3pJ1Djqqbc6dBnrvDLaLDDBMB8qQ6Y6hYJ8WCrrSLT32eS4FLdhGTh0AkHkW1lv-ukF9SgWZeVNjibDYTwNXJ5eAW2zZeOgTz1My0TS-4p0d0fRCuHfPWg0DRU7fOQhjT14u1s5g6i3s9LqYvinKQaIr2BX5bTWg2LuG-XGMO431xKgatuTuY1OIoowkuZYOpCljbtdjVjOzm33adiPfuRg6Dr9pQKQ9TWMsC4)

### 2.2 Màn hình Quản lý máy in (Printer Management Screen)
*   **Stitch Screen ID:** `c0993A519c3649d69cc510c5b7b55072`
*   **Mô tả:** Quản lý danh sách máy in đã lưu dưới dạng card trực quan. Hiển thị thông số kết nối (WiFi/Bluetooth, IP, MAC Address, Giao thức TSPL/ESC-POS) và các nút thao tác nhanh (In thử, Sửa, Xóa). Status chip đổi màu theo trạng thái máy in (Xanh lục cho Sẵn sàng, Xám cho Chờ).
*   **Ảnh chụp thiết kế:**
    ![Printer Management Screen Preview](https://lh3.googleusercontent.com/aida/AP1WRLsZ49-ERP_2AljHZHnRfgWcMIJoiny2OAQRl2w07r8Wi2mFMWiKmT850PPK-XI_-PS-g7UCSIxR97zDORs6mUiR61-pVdvRRzC7e0gGfxmf3Hh9eIlxIlMphdOXX2cc7ritrqFK-9wPdafrnA9AKWjtWeSS38kse3qqBzpilvJqf3sMXHQjvSyGVs91AkTq8tBjK7tqv5QZ_ML5ybGATLNyMToxl2hPLDC_9pGZqkEPPBvcmcy1y06nMX36)

### 2.3 Màn hình Cấu hình bản in & Lưu bản mẫu (Print Config & Save Template Screen)
*   **Stitch Screen ID:** `1d88b70cfA6c45d189fd9a9498b476c7`
*   **Mô tả:** Màn hình cấu hình chi tiết thông số trang in (khổ giấy, lề, độ đậm, tốc độ, tỷ lệ co giãn) và tích hợp tính năng lưu thiết lập cấu hình kèm nhãn thành Bản mẫu (Template) thông qua ô nhập tên bản mẫu. Hai nút hành động ở phía dưới hỗ trợ áp dụng nhanh cấu hình và lưu thành bản mẫu mới.
*   **Ảnh chụp thiết kế:**
    ![Print Config & Save Template Screen Preview](https://lh3.googleusercontent.com/aida/AP1WRLt_v9LL5b46mgbdBzsIprw_8ereeK9AV3qg7JVsfDVy0fDxna_1crM2lH1p8A7ELcEHRAhRFIVQ7sNetM4afxuKFbt99ZWRwoS02pSfFYDaV6OfMYJmBjwSaeUnbhqSroYGoe-SROs02LoKrQhwAbBd_op970I0S7GXDEDngm2EY8kg9ze-1UAQ2KmRsuUx_0Hgf2rx0NtHUSJySOX0ZxJhTpI0X70CV2VmYUdOX50isum7b3bIh75eVog)

### 2.4 Màn hình In mã vạch (Barcode Printing Screen)
*   **Stitch Screen ID:** `fcb0239289314e1f9ce16c543bf0c9a0`
*   **Mô tả:** Biểu mẫu cấu hình mã vạch bao gồm ô nhập dữ liệu (hỗ trợ nút quét camera), chọn định dạng (Code 128, EAN-13...), thanh trượt điều chỉnh chiều cao và nút chuyển đổi bật tắt hiển thị mã số bên dưới. Vùng xem trước thời gian thực được đặt ngay bên dưới biểu mẫu cùng với nút chuyển hướng "TIẾP TỤC IN".
*   **Ảnh chụp thiết kế:**
    ![Barcode Printing Screen Preview](https://lh3.googleusercontent.com/aida/AP1WRLK3g59gxw1lRJj-X4I7cdcJzMf9lehyOfEJ21yd4XkuliXJJKelrVK0XXz4w36Bs6Q8gahfk4XosV8sEWhSfH_ucquk9fOKNCdA020BZ7TWXYHhx6pTdc5FmCIEGHowf1JCC00r68ztXfjNl3xb8voRdKm-QoiUZXwGyQKndKSRMvg7ENY8jLMLZn7iFJdD59WbiGwG-l_ekSID96MrK7Z_nqtnN16s4ZX9eho-XKZCMi_qoqRd95swyM)
