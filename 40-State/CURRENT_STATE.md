---
last_verified: 2026-09-19
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
- Cấu hình Workers dùng tên `mom-s-exam` và chỉ dùng `assets.not_found_handling = single-page-application` cho định tuyến SPA; quy tắc `_redirects` gây vòng lặp đã được loại bỏ ngày 16/08/2026.
- Cả 5 cổng bắt buộc đều đạt ngày 16/08/2026; kiểm thử trình duyệt thật ở chiều rộng 390 px gần nhất đạt ngày 15/08/2026.
- Mã nguồn đã được đẩy an toàn lên nhánh `main` của `https://github.com/xinchaotamhon/mom-s_exam`; mốc xuất bản đầu tiên chứa đủ ứng dụng và giấy phép là `ab0744b`.
- Vòng thi cuối được tách riêng: 30 câu trắc nghiệm và 20 tình huống, giữ nguyên bộ 538 câu và khóa localStorage `on-thi-bi-thu-chi-bo-v1`.
- 30 câu trắc nghiệm vòng cuối là tuyển chọn lại từ 395 câu cũ; focused gate đối chiếu prompt và 4 lựa chọn với ngân hàng cũ. Có 29 đáp án vốn đã khớp; câu trùng về giám sát được hiệu chỉnh về A theo Điều 6 Quy định 21-QĐ/TW ở cả hai bản hiển thị.
- Có 3 câu vòng cuối publicly-verified (2 tình huống đảng phí và 1 MCQ giám sát), 47 câu còn lại giữ trạng thái source-provided. Các hiệu chỉnh lặp lại được lưu trong `data/curated/final-round-corrections.json`.
- Pipeline vòng cuối ghi hash corrections vào derived data và gate phát hiện dữ liệu dẫn xuất cũ; tình huống 10 đã loại số trang `11` bị dính khỏi dòng đáp án bằng quy tắc hẹp.
- Hai DOCX vòng cuối được sao chép bất biến vào `data/source`, có SHA-256 trong `FINAL_ROUND_PROVENANCE.md`; dữ liệu dẫn xuất nằm ở `data/derived/final-round.json` và trường `finalRound` trong gói site.
- Host không có LibreOffice bundled, nên nguồn được kiểm tra đầy đủ bằng python-docx/OOXML; trạng thái render chưa thực hiện được đã được ghi trong provenance.

## Đã hoàn tất

- Chuyển đổi DOCX, biên tập nội dung, xây giao diện và kiểm thử gói triển khai.
- Tích hợp khu vực “Vòng thi cuối” trên giao diện điện thoại; trắc nghiệm chấm đáp án, tình huống cho xem đáp án/gợi ý sau khi tự trả lời.

## Điểm chưa biết

- Chưa có bản chính thức của một số Quy định, Đề án và Quy chế nội bộ Tỉnh ủy Lào Cai được câu hỏi viện dẫn; 132 câu liên quan đã được nhận diện rõ trong dữ liệu.
- Bản sửa lỗi triển khai đã qua kiểm tra cục bộ; còn cần chạy lại Workers Build và kiểm tra URL thật trên điện thoại.

## Bằng chứng

- `50-Evidence/2026-08-15-release-candidate.md`
- `50-Evidence/2026-09-19-final-round.md`
