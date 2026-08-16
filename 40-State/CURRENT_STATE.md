---
last_verified: 2026-08-16
verified_by: Codex
status: active
---

# Trạng thái hiện tại

## Sự thật đã xác minh

- Bản sao DOCX bất biến có SHA-256 `c59a65312d2fbd02ec2fdc85710b435049e02cc5fe314a0777d8f2ad122e3d56` và giữ nguyên dung lượng 138.900 byte.
- Bộ dữ liệu có đúng 538 câu: 395 trắc nghiệm và 143 vấn đáp, chia thành 5 nhóm nghiệp vụ.
- Cả 395 câu trắc nghiệm có đáp án, lời giải ngắn, mẹo nhớ và trạng thái đối chiếu nguồn.
- Cả 143 câu vấn đáp có gợi ý nhẹ, khung trả lời 5 bước và mẹo nhớ theo tình huống.
- 60 đáp án đã gắn nguồn công khai trực tiếp; 203 câu đã rà nội dung; 132 câu viện dẫn văn bản nội bộ địa phương được gắn nhãn cần đối chiếu thêm.
- Ứng dụng là trang tĩnh, không có máy chủ, không thu thông tin cá nhân và lưu tiến độ trong trình duyệt của người học.
- Gói triển khai Cloudflare nằm trong `site`; `wrangler.jsonc` trỏ trực tiếp tới thư mục này.
- Bốn cổng bắt buộc và kiểm thử trình duyệt thật ở chiều rộng 390 px đều đạt ngày 15/08/2026.
- Mã nguồn đã được đẩy an toàn lên nhánh `main` của `https://github.com/xinchaotamhon/mom-s_exam`; mốc xuất bản đầu tiên chứa đủ ứng dụng và giấy phép là `ab0744b`.

## Đã hoàn tất

- Chuyển đổi DOCX, biên tập nội dung, xây giao diện và kiểm thử gói triển khai.

## Điểm chưa biết

- Chưa có bản chính thức của một số Quy định, Đề án và Quy chế nội bộ Tỉnh ủy Lào Cai được câu hỏi viện dẫn; 132 câu liên quan đã được nhận diện rõ trong dữ liệu.
- Trang chưa được đẩy lên tài khoản Cloudflare của người dùng trong phiên này.

## Bằng chứng

- `50-Evidence/2026-08-15-release-candidate.md`
