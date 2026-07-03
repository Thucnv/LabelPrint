# Coding Style & Design Tokens - Label Print

## 1. Design Tokens (Industrial Precision Theme)

### Bảng màu (AppColors)
* `primary`: `#4F46E5` (Indigo 600)
* `primaryLight`: `#818CF8` (Indigo 400)
* `primaryDark`: `#3730A3` (Indigo 800)
* `background`: `#F8FAFC` (Slate 50)
* `surface`: `#FFFFFF`
* `surfaceVariant`: `#F1F5F9` (Slate 100)
* `onSurface`: `#1E293B` (Slate 800)
* `onSurfaceVariant`: `#64748B` (Slate 500)
* `divider`: `#E2E8F0` (Slate 200)
* `success`: `#16A34A` (Green 600)
* `warning`: `#F59E0B` (Amber 500)
* `error`: `#DC2626` (Red 600)
* `statusIdle`: `#94A3B8` (Slate 400)

### Kiểu chữ (AppTextStyles - Google Fonts Inter)
* `headingLg`: 24sp | Bold (700)
* `headingMd`: 20sp | SemiBold (600)
* `headingSm`: 16sp | SemiBold (600)
* `bodyLg`: 16sp | Regular (400)
* `bodyMd`: 14sp | Regular (400)
* `bodySm`: 12sp | Regular (400)
* `button`: 14sp | SemiBold (600)
* `label`: 12sp | Medium (500)

---

## 2. Tiêu chuẩn viết Code (Coding Standards)

### Lớp Domain (Không phụ thuộc bên ngoài)
* Khai báo Entity kế thừa `Equatable` để so sánh trạng thái dễ dàng.
* Tất cả Use Cases chỉ chứa duy nhất một phương thức thực thi: `Future<Either<Failure, T>> call(...)`.
* Xử lý lỗi functional bằng `Either` từ package `dartz` (thất bại trả về `Left(Failure)`, thành công trả về `Right(data)`).

### Lớp Data
* Các Model kế thừa Entity, thực hiện map dữ liệu SQLite qua `fromMap()` và `toMap()`.
* Bắt Exception và chuyển đổi thành lớp `Failure` (như `DatabaseFailure`, `ConnectionFailure`) trước khi trả về lớp Domain.

### Lớp Presentation (UI & BLoC)
* Tách biệt State, Event, và BLoC/Cubit thành các file riêng biệt.
* State phải kế thừa `Equatable` để tối ưu số lần render lại widget.
* Widget tương tác chính (Button) bắt buộc có hiệu ứng nhấn (micro-animation như co giãn nhẹ 0.98 qua `AnimatedScale`) và có trạng thái loading.

### Đa ngôn ngữ (Localization)
* Không viết cứng (hardcode) chuỗi giao diện trong file UI.
* Sử dụng `AppLocalizations.of(context)!.<key>` từ file `.arb` được sinh tự động cục bộ tại thư mục `lib/core/l10n/` (import từ `package:label_print/core/l10n/app_localizations.dart`).

---

## 3. Kế hoạch & Lệnh kiểm thử (Testing Commands)

### Phân tích cú pháp & Lints
```bash
flutter analyze
```

### Chạy Unit Test toàn hệ thống
```bash
flutter test
```

### Chạy Unit Test cho từng tầng
```bash
flutter test test/data/
flutter test test/domain/
```

### Chạy thử nghiệm trên thiết bị
* Chạy chế độ debug: `flutter run`
* Tạo bản release APK: `flutter build apk --release`
