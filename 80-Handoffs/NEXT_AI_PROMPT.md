---
last_verified: 2026-09-19
verified_by: Codex
status: ready
---

# Bàn giao cho phiên AI tiếp theo

Đọc `START_HERE.md` trước, sau đó nêu mốc có bằng chứng trước khi sửa.

## Mốc đã xác minh

- DOCX trong `data/source` là đầu vào bất biến; bộ biên dịch tạo đúng 395 câu trắc nghiệm và 143 câu vấn đáp.
- Ứng dụng tĩnh trong `site` đã hoàn tất, không có máy chủ, không thu thập dữ liệu cá nhân và đã qua kiểm thử trình duyệt 390 px.
- 60 đáp án có nguồn công khai trực tiếp; 132 đáp án cần bản văn bản nội bộ Lào Cai để nâng mức xác minh.
- Vòng thi cuối đã tích hợp: 30 trắc nghiệm + 20 tình huống, tách trong `bank.finalRound`, không làm thay đổi 538 câu cũ hoặc khóa localStorage `on-thi-bi-thu-chi-bo-v1`.
- 30 MCQ vòng cuối là tuyển chọn lại từ 395 câu cũ; gate đối chiếu prompt/lựa chọn và đáp án. Ba hiệu chỉnh publicly-verified nằm trong `data/curated/final-round-corrections.json`; `sourceAnswer` giữ nguyên đáp án nguồn.
- Chạy `build_final_round.py` trước `compile_content.ps1`; derived data có hash corrections để gate phát hiện stale. Focused gate cũng kiểm tra tình huống 10 không còn số trang `11` dính sau kết luận.
- Nguồn vòng cuối bất biến trong `data/source/final-*.docx`, provenance và SHA-256 ở `data/source/FINAL_ROUND_PROVENANCE.md`; render DOCX chưa khả thi vì runtime không có LibreOffice bundled.
- Chạy toàn bộ cổng bằng `tools/run_gates.ps1`.
- Nhánh `main` đã được đẩy lên `https://github.com/xinchaotamhon/mom-s_exam`; không dùng force-push.

## Phạm vi tiếp theo

1. Chạy Workers Build và smoke trình duyệt thật cho khu vực vòng cuối; nếu có phản hồi trên điện thoại thì chỉ chỉnh UX, không sửa nguồn DOCX.
2. Nếu nhận được các văn bản nội bộ Lào Cai, đối chiếu các câu cần xác minh trong cả ngân hàng cũ và vòng cuối trước khi đổi trạng thái nguồn.

## Ranh giới

- Không sửa nguồn thô hoặc lưu bí mật.
- Không biến nội dung chưa xác minh thành đáp án khẳng định.
- Không tuyên bố thành công khi chưa chạy cổng kiểm tra trên đúng bản triển khai.

## Điều kiện hoàn tất

- Các cổng liên quan đều đạt.
- Bằng chứng, trạng thái và việc tiếp theo được cập nhật.
- Vẫn có đường quay lui rõ ràng.
