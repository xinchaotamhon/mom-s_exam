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
