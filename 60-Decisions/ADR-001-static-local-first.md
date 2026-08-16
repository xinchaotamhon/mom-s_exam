# ADR-001 — Trang tĩnh và lưu tiến độ tại thiết bị

- Ngày: 2026-08-15
- Trạng thái: chấp nhận

## Bối cảnh

Người học cần giao diện nhẹ, dễ dùng trên điện thoại, không đăng nhập và có thể triển khai nhanh bằng Cloudflare.

## Quyết định

Dùng HTML, CSS và JavaScript thuần; đóng gói toàn bộ câu hỏi vào tệp JSON tĩnh; lưu tiến độ bằng `localStorage` trên thiết bị. Không dùng máy chủ, cơ sở dữ liệu hoặc dịch vụ theo dõi.

## Hệ quả

- Trang tải nhanh, ít điểm lỗi, không gửi dữ liệu cá nhân.
- Có thể ôn ngoại tuyến sau lần tải đầu nhờ service worker.
- Tiến độ không tự đồng bộ giữa điện thoại và máy tính; xóa dữ liệu trình duyệt sẽ làm mất tiến độ.

## Quay lui

Nếu sau này cần đồng bộ, giữ nguyên giao diện và bổ sung lớp lưu trữ phía máy chủ sau khi có quyết định riêng về tài khoản, quyền riêng tư và chi phí vận hành.
