---
last_verified: 2026-08-15
verified_by: Codex
status: ready
---

# Bàn giao cho phiên AI tiếp theo

Đọc `START_HERE.md` trước, sau đó nêu mốc có bằng chứng trước khi sửa.

## Mốc đã xác minh

- DOCX trong `data/source` là đầu vào bất biến; bộ biên dịch tạo đúng 395 câu trắc nghiệm và 143 câu vấn đáp.
- Ứng dụng tĩnh trong `site` đã hoàn tất, không có máy chủ, không thu thập dữ liệu cá nhân và đã qua kiểm thử trình duyệt 390 px.
- 60 đáp án có nguồn công khai trực tiếp; 132 đáp án cần bản văn bản nội bộ Lào Cai để nâng mức xác minh.
- Chạy toàn bộ cổng bằng `tools/run_gates.ps1`.

## Phạm vi tiếp theo

1. Tiếp tục đúng việc giới hạn trong `40-State/NEXT_ACTIONS.md`; ưu tiên triển khai Cloudflare hoặc đối chiếu văn bản nội bộ nếu người dùng cung cấp.

## Ranh giới

- Không sửa nguồn thô hoặc lưu bí mật.
- Không biến nội dung chưa xác minh thành đáp án khẳng định.
- Không tuyên bố thành công khi chưa chạy cổng kiểm tra trên đúng bản triển khai.

## Điều kiện hoàn tất

- Các cổng liên quan đều đạt.
- Bằng chứng, trạng thái và việc tiếp theo được cập nhật.
- Vẫn có đường quay lui rõ ràng.
