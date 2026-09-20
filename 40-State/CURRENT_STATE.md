---
last_verified: 2026-09-20
verified_by: Codex
status: active
---

# Trạng thái hiện tại

## Sự thật đã xác minh

- Bản sao DOCX bất biến có SHA-256 `c59a65312d2fbd02ec2fdc85710b435049e02cc5fe314a0777d8f2ad122e3d56` và giữ nguyên dung lượng 138.900 byte.
- Bộ dữ liệu có đúng 538 câu: 395 trắc nghiệm và 143 vấn đáp, chia thành 5 nhóm nghiệp vụ.
- Cả 395 câu trắc nghiệm có đáp án và lời giải nói ngắn 40–70 từ; lời giải nêu đúng chữ cái đáp án, không bị cắt giữa chừng, kèm mẹo nhớ và trạng thái đối chiếu nguồn.
- Cả 143 câu vấn đáp có gợi ý nhẹ, khung trả lời 5 bước, mẹo nhớ và một đoạn liên hệ thực tế 63–81 từ với Trường Mầm non Sơn Thịnh.
- Cả 20 tình huống vòng cuối có thêm đoạn liên hệ thực tế 79–90 từ với Trường Mầm non Sơn Thịnh; các đoạn đều ghi rõ là ví dụ vận dụng, không khẳng định một sự việc nội bộ đã xảy ra.
- 61 đáp án đã gắn nguồn công khai trực tiếp; 202 câu đã rà nội dung; 132 câu viện dẫn văn bản nội bộ địa phương được gắn nhãn cần đối chiếu thêm.
- Ứng dụng là trang tĩnh, không có máy chủ, không thu thông tin cá nhân và lưu tiến độ trong trình duyệt của người học.
- Gói triển khai Cloudflare nằm trong `site`; `wrangler.jsonc` trỏ trực tiếp tới thư mục này.
- Cấu hình Workers dùng tên `mom-s-exam` và chỉ dùng `assets.not_found_handling = single-page-application` cho định tuyến SPA; quy tắc `_redirects` gây vòng lặp đã được loại bỏ ngày 16/08/2026.
- Cả 7 cổng bắt buộc đều đạt ngày 19/09/2026. Kiểm thử bằng trình duyệt trong ứng dụng ở khung 390 × 844 đạt cho ba luồng: giải thích trắc nghiệm, liên hệ vấn đáp và liên hệ tình huống; bảng lỗi trình duyệt trống.
- Mã nguồn đã được đẩy an toàn lên nhánh `main` của `https://github.com/xinchaotamhon/mom-s_exam`; mốc xuất bản đầu tiên chứa đủ ứng dụng và giấy phép là `ab0744b`.
- Vòng thi cuối được tách riêng: 30 câu trắc nghiệm và 20 tình huống, giữ nguyên bộ 538 câu và khóa localStorage `on-thi-bi-thu-chi-bo-v1`.
- 30 câu trắc nghiệm vòng cuối là tuyển chọn lại từ 395 câu cũ; focused gate đối chiếu prompt và 4 lựa chọn với ngân hàng cũ. Có 29 đáp án vốn đã khớp; câu trùng về giám sát được hiệu chỉnh về A theo Điều 6 Quy định 21-QĐ/TW ở cả hai bản hiển thị.
- Toàn bộ 30 câu trắc nghiệm Vòng thi cuối đã có bộ lời giải ngắn cụ thể, chuẩn xác (55–69 từ, mở đầu bằng `Đáp án X:`, trả lời rõ tại sao đúng và phương án nhiễu sai ở đâu, không dùng văn mẫu chung chung, vượt qua phép thử Quy tắc 7), lưu độc lập tại `data/curated/final-round-mcq-explanations.json` và biên dịch trực tiếp vào `bank.finalRound.multipleChoice`.
- Có 3 câu vòng cuối publicly-verified (2 tình huống đảng phí và 1 MCQ giám sát), 47 câu còn lại giữ trạng thái source-provided. Các hiệu chỉnh lặp lại được lưu trong `data/curated/final-round-corrections.json`.
- Pipeline vòng cuối ghi hash corrections vào derived data và gate phát hiện dữ liệu dẫn xuất cũ; tình huống 10 đã loại số trang `11` bị dính khỏi dòng đáp án bằng quy tắc hẹp.
- Hai DOCX vòng cuối được sao chép bất biến vào `data/source`, có SHA-256 trong `FINAL_ROUND_PROVENANCE.md`; dữ liệu dẫn xuất nằm ở `data/derived/final-round.json` và trường `finalRound` trong gói site.
- Host không có LibreOffice bundled, nên nguồn được kiểm tra đầy đủ bằng python-docx/OOXML; trạng thái render chưa thực hiện được đã được ghi trong provenance.

## Đã hoàn tất

- Chuyển đổi DOCX, biên tập nội dung, xây giao diện và kiểm thử gói triển khai.
- Tích hợp khu vực “Vòng thi cuối” trên giao diện điện thoại; trắc nghiệm chấm đáp án, tình huống cho xem đáp án/gợi ý sau khi tự trả lời.
- Bổ sung nhãn “Giải thích ngắn — trình bày trong khoảng 20–30 giây” sau mỗi câu trắc nghiệm và nút “Liên hệ tại trường” cho mọi câu vấn đáp.
- Bổ sung nguồn công khai về địa giới hiện hành của xã Văn Chấn và bối cảnh chăm sóc, giáo dục, chuyển đổi số của Trường Mầm non Sơn Thịnh.
- Biên soạn, bình duyệt chéo và nghiệm thu toàn bộ 30 lời giải trắc nghiệm cụ thể cho Vòng thi cuối; cập nhật pipeline `compile_content.ps1` và các bài test kiểm tra.

## Điểm chưa biết

- Chưa có bản chính thức của một số Quy định, Đề án và Quy chế nội bộ Tỉnh ủy Lào Cai được câu hỏi viện dẫn; 132 câu liên quan đã được nhận diện rõ trong dữ liệu.
- Cần xác nhận Cloudflare Worker deployment và kiểm tra live site sau khi đẩy commit mới.

## Bằng chứng

- `50-Evidence/2026-08-15-release-candidate.md`
- `50-Evidence/2026-09-19-final-round.md`
- `50-Evidence/2026-09-19-exam-delivery-support.md`
- `50-Evidence/2026-09-20-final-round-mcq-explanations.md`
