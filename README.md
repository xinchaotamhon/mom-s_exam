# Ôn thi Bí thư chi bộ

Trang ôn tập gồm 395 câu trắc nghiệm và 143 câu vấn đáp, được chuyển từ tài liệu gia đình cung cấp. Giao diện được thiết kế để chữ dễ đọc, mỗi lần chỉ tập trung vào một câu và không có đồng hồ đếm ngược.

## Đưa lên Cloudflare

Cách dễ nhất bằng trang quản lý Cloudflare:

1. Tạo một dự án **Workers & Pages** mới và kết nối thư mục mã nguồn này.
2. Chọn triển khai dưới dạng tài nguyên tĩnh.
3. Đặt lệnh dựng trang là `exit 0` (hoặc để trống nếu giao diện Cloudflare cho phép).
4. Đặt thư mục đầu ra là `site`.
5. Triển khai và mở địa chỉ Cloudflare cấp để kiểm tra trên điện thoại.

Nếu dùng Wrangler trên máy đã cài Node.js, chạy `npx wrangler deploy` tại thư mục dự án.

## Cập nhật nội dung

- Tài liệu gốc bất biến: `data/source/original.docx`.
- Khóa đáp án biên tập: `data/curated/content-plan.json`.
- Danh sách nguồn: `data/curated/sources.json`.
- Tạo lại dữ liệu cho trang: chạy `tools/compile_content.ps1` bằng PowerShell.

Các câu có nhãn “Nên đối chiếu thêm văn bản nội bộ” đã có đáp án dự kiến để ôn tập, nhưng nên được so lại với bản văn bản chính thức của Tỉnh ủy Lào Cai nếu gia đình có thể xin được.
