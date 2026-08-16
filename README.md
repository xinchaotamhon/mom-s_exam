# Ôn thi Bí thư chi bộ

Trang ôn tập gồm 395 câu trắc nghiệm và 143 câu vấn đáp, được chuyển từ tài liệu gia đình cung cấp. Giao diện được thiết kế để chữ dễ đọc, mỗi lần chỉ tập trung vào một câu và không có đồng hồ đếm ngược.

## Đưa lên Cloudflare

Kho mã này đã được cấu hình cho **Cloudflare Workers Static Assets** với tên Worker `mom-s-exam`:

1. Trong **Workers & Pages**, mở Worker `mom-s-exam` và kết nối kho GitHub này.
2. Chọn nhánh sản xuất `main`; để trống thư mục gốc và lệnh dựng.
3. Đặt lệnh triển khai là `npx wrangler deploy`.
4. Triển khai rồi mở địa chỉ `workers.dev` Cloudflare cấp để kiểm tra trên điện thoại.

Nếu dùng Wrangler trên máy đã cài Node.js, chạy `npx wrangler deploy` tại thư mục dự án. Không thêm quy tắc `/* /index.html 200` vào `site/_redirects`: chế độ SPA đã được khai báo trong `wrangler.jsonc`.

Nếu tạo dự án **Cloudflare Pages** riêng, để trống lệnh dựng và đặt thư mục đầu ra là `site`.

## Cập nhật nội dung

- Tài liệu gốc bất biến: `data/source/original.docx`.
- Khóa đáp án biên tập: `data/curated/content-plan.json`.
- Danh sách nguồn: `data/curated/sources.json`.
- Tạo lại dữ liệu cho trang: chạy `tools/compile_content.ps1` bằng PowerShell.

Các câu có nhãn “Nên đối chiếu thêm văn bản nội bộ” đã có đáp án dự kiến để ôn tập, nhưng nên được so lại với bản văn bản chính thức của Tỉnh ủy Lào Cai nếu gia đình có thể xin được.
