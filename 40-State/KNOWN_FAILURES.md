---
last_verified: 2026-08-15
verified_by: Codex
status: active
---

# Các lỗi đã biết

## MEM-001 — Nguồn chuẩn toàn cục chưa truy cập được

- Ngày: 2026-08-15.
- Hiện tượng: không tìm thấy đường dẫn Vault chuẩn được kỹ năng chỉ định.
- Ảnh hưởng: chưa thể ghi hàm băm chính xác vào hồ sơ áp dụng tiêu chuẩn.
- Tái hiện: đọc `D:/mydata/my-project/00-AI-Resource-Vault-v2/20-First-Party/project-standard/START_HERE.md` trả về không tồn tại.
- Nguyên nhân: chưa xác định; kho Vault không tồn tại ở đường dẫn dự kiến.
- Xử lý: chấp nhận tạm thời, dùng phiên bản tiêu chuẩn ghi trong kỹ năng và đánh dấu `provisional`.
- Cổng hồi quy: chưa khả thi vì phụ thuộc tài nguyên ngoài dự án.

## CONTENT-001 — Thiếu bản công khai của một số văn bản nội bộ Lào Cai

- Ngày: 2026-08-15.
- Hiện tượng: 132 câu viện dẫn Quy định, Đề án hoặc Quy chế nội bộ địa phương nhưng không tìm được toàn văn chính thức công khai.
- Ảnh hưởng: vẫn có đáp án để học, nhưng không được gắn nhãn “đã đối chiếu nguồn công khai”.
- Xử lý: hiển thị nhãn “Nên đối chiếu thêm văn bản nội bộ”, lưu nguồn câu hỏi và giữ khóa đáp án tách riêng để sửa dễ dàng.
- Cách đóng: xin bản văn bản chính thức từ Ban Tổ chức hoặc Tỉnh ủy, đối chiếu từng câu rồi chuyển trạng thái trong `data/curated/content-plan.json`.
- Cổng hồi quy: `content.curated-complete` bảo đảm không mất đáp án hoặc gợi ý trong quá trình cập nhật.

## DEPLOY-001 — Vòng lặp trong cấu hình `_redirects`

- Ngày: 2026-08-16.
- Hiện tượng: Workers Build tải đủ tài nguyên nhưng API từ chối tạo phiên bản với mã `100324`, báo quy tắc dòng 1 gây vòng lặp vô hạn.
- Tái hiện: triển khai gói có đồng thời `site/_redirects` chứa `/* /index.html 200` và `assets.not_found_handling = single-page-application` trong `wrangler.jsonc`.
- Nguyên nhân: quy tắc viết lại thủ công về `index.html` trùng với định tuyến SPA và xung đột với chuẩn hóa URL HTML của Workers Static Assets.
- Xử lý: đã xóa `site/_redirects`, giữ cơ chế SPA chính thức trong `wrangler.jsonc`, đồng thời đổi tên Worker thành `mom-s-exam` để khớp Workers Build.
- Cổng hồi quy: `deploy.cloudflare-static-assets-config` từ chối tái xuất hiện quy tắc `/* /index.html 200` và kiểm tra tên Worker cùng cấu hình SPA.
- Trạng thái: đã đóng; bản sửa đã được đẩy và một lần triển khai Cloudflare thành công đã được xác nhận ngày 19/09/2026. Cổng hồi quy vẫn bắt buộc để ngăn lỗi quay lại.
