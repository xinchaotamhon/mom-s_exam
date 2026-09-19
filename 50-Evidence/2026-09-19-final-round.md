# Bằng chứng tích hợp vòng thi cuối

- Ngày: 2026-09-19.
- `final-30-trac-nghiem.docx`: SHA-256 `b2578ede8aefaee4f849a851f577b1dd07b508fb7c3d9f4c18bfbf6f991b9fc8`, 188 đoạn, 0 bảng, 10 trang trong `app.xml`.
- `final-20-tinh-huong.docx`: SHA-256 `ab84877e02f300fd79cae48e2e010153825330f21c390338f0e9c369fc4426ba`, 162 đoạn, 0 bảng, 12 trang trong `app.xml`.
- Trích xuất bằng Python bundled `tools/build_final_round.py`: đúng 30 trắc nghiệm (mỗi câu 4 lựa chọn và một đáp án) và đúng 20 tình huống có phần câu hỏi cùng đáp án/gợi ý theo nguồn.
- Đối chiếu nội dung cho thấy 30 MCQ vòng cuối là tuyển chọn lại từ bộ 395 câu: cả 30 prompt và 4 lựa chọn đều trùng nội dung; 29 đáp án khớp sẵn. Câu giám sát tương ứng `final-mcq-22` / `mcq-kiem-tra-giam-sat-23` được hiệu chỉnh về A theo Điều 6 Quy định 21-QĐ/TW; đáp án DOCX cũ của bản ngân hàng được giữ tại `sourceAnswer`.
- `data/curated/final-round-corrections.json` áp dụng lặp lại được 3 hiệu chỉnh công khai: tình huống 1, tình huống 2 và MCQ giám sát. Kết quả trạng thái là 47 `source-provided`, 3 `publicly-verified`.
- Bộ trích xuất loại bỏ số trang `11` bị dính sau kết luận của tình huống 10 bằng quy tắc hẹp chỉ áp dụng cho dòng `Đáp án`, và focused gate kiểm tra không còn chuỗi `Quan điểm 2 đúng. 11`; số hợp lệ trong nội dung thường không bị xóa.
- `final-round.json` ghi SHA-256 của file corrections; focused gate đối chiếu hash để phát hiện dữ liệu dẫn xuất bị cũ nếu corrections thay đổi mà chưa chạy lại build.
- `tools/run_gates.ps1` đạt các cổng nền, pipeline cũ, nội dung cũ, `content.final-round-complete`, site tĩnh và cấu hình Cloudflare.
- Node bundled kiểm tra cú pháp đạt cho `site/app.js` và `site/service-worker.js`.
- Browser smoke tự động đã bổ sung thao tác cho cả hai thẻ vòng cuối (`tests/browser_smoke.js`), nhưng chưa chạy được qua cổng CDP `127.0.0.1:9222` trên host này. Nghiệm thu thủ công bằng trình duyệt trong ứng dụng ở khung 390 × 844 đã đạt: hai thẻ vòng cuối mở đúng chế độ, không bật nhầm hộp chọn phần, trắc nghiệm chấm đáp án, tình huống mở lời giải đã đối chiếu, nguồn liên kết hiển thị đúng, tiến độ còn nguyên sau khi tải lại và không có tràn ngang.
- Render DOCX không khả thi trên host do không có `soffice.exe` trong runtime bundled; không dùng LibreOffice desktop. Đã thay bằng kiểm tra cấu trúc OOXML và toàn bộ nội dung.
- Khóa tiến độ cũ `on-thi-bi-thu-chi-bo-v1` không đổi; vòng cuối thêm trạng thái dưới `finalRound` trong cùng localStorage.
