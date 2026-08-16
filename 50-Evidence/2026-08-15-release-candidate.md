---
verified_at: 2026-08-15T21:12:00+07:00
verified_by: Codex
status: passed
---

# Bằng chứng bản sẵn sàng triển khai

## Dữ liệu

- DOCX nguồn và bản sao có cùng SHA-256: `c59a65312d2fbd02ec2fdc85710b435049e02cc5fe314a0777d8f2ad122e3d56`.
- 2.407 đoạn văn được bóc tách thành 395 câu trắc nghiệm và 143 câu vấn đáp.
- 395/395 câu trắc nghiệm có một đáp án A–D và lời giải ngắn.
- 143/143 câu vấn đáp có gợi ý nhẹ, mẹo nhớ và khung trả lời 5 bước.
- Trạng thái đối chiếu: 60 nguồn công khai trực tiếp, 203 rà nội dung, 132 cần văn bản nội bộ.

## Cổng bắt buộc

- `foundation.start-here-exists`: đạt.
- `content.source-pipeline`: đạt.
- `content.curated-complete`: đạt.
- `site.static-integrity`: đạt.

## Kiểm thử trình duyệt

- Trình duyệt: Microsoft Edge 151, chế độ headless.
- Khung nhìn: 390 × 844 px, mô phỏng thiết bị di động.
- Không tràn ngang.
- Chọn đáp án, kiểm tra đúng/sai và lưu tiến độ: đạt.
- Mở gợi ý nhẹ, mở khung trả lời và đánh dấu cần ôn lại: đạt.
- Không ghi nhận lỗi JavaScript trong luồng kiểm thử.

## Triển khai

- `site/index.html` ở đúng cấp gốc của thư mục xuất bản.
- `wrangler.jsonc` dùng `assets.directory = ./site` và chế độ `single-page-application`.
- Hướng dẫn Pages và Wrangler nằm trong `README.md`.
