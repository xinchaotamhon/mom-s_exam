# Ôn thi Bí thư chi bộ

Trang ôn tập gồm 395 câu trắc nghiệm và 143 câu vấn đáp, được chuyển từ tài liệu gia đình cung cấp. Giao diện được thiết kế để chữ dễ đọc, mỗi lần chỉ tập trung vào một câu và không có đồng hồ đếm ngược. Khu vực **Vòng thi cuối** có 30 câu trắc nghiệm chốt được tuyển chọn lại từ bộ 395 câu (không phải 30 câu hoàn toàn mới) và 20 tình huống thực tế (tự trả lời rồi mở đáp án/gợi ý).

- Sau khi chấm mỗi câu trắc nghiệm, trang hiện một lời giải ngắn 40–70 từ để có thể trình bày trong khoảng 20–30 giây.
- Mỗi câu vấn đáp và mỗi tình huống vòng cuối có phần liên hệ riêng với Trường Mầm non Sơn Thịnh, xã Văn Chấn, tỉnh Lào Cai (địa bàn tỉnh Yên Bái cũ). Các đoạn này là ví dụ vận dụng, không phải ghi nhận sự việc đã xảy ra tại trường.

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
- Tài liệu vòng thi cuối bất biến: `data/source/final-30-trac-nghiem.docx` và `data/source/final-20-tinh-huong.docx`; SHA-256 và giới hạn kiểm tra nằm trong `data/source/FINAL_ROUND_PROVENANCE.md`.
- Hiệu chỉnh có nguồn công khai cho hai tình huống đảng phí và câu trắc nghiệm trùng về giám sát nằm trong `data/curated/final-round-corrections.json`; đáp án gốc của DOCX vẫn được lưu trong `sourceAnswer`.
- Khóa đáp án biên tập: `data/curated/content-plan.json`.
- Danh sách nguồn: `data/curated/sources.json`.
- Lời giải nói ngắn: `data/curated/mcq-explanations.json`; liên hệ nơi làm việc: `data/curated/oral-school-links.json` và `data/curated/final-scenario-school-links.json`.
- Tạo lại dữ liệu vòng cuối trước, bằng Python bundled: `C:\Users\vhiep\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe tools/build_final_round.py`; sau đó chạy `tools/compile_content.ps1` bằng PowerShell để dựng lại toàn bộ gói trang. Gate sẽ báo lỗi nếu dữ liệu dẫn xuất cũ hơn file hiệu chỉnh.

Các câu có nhãn “Nên đối chiếu thêm văn bản nội bộ” đã có đáp án dự kiến để ôn tập, nhưng nên được so lại với bản văn bản chính thức của Tỉnh ủy Lào Cai nếu gia đình có thể xin được.

Dữ liệu vòng cuối có 47 câu giữ theo DOCX và chưa được xác minh riêng; 3 câu có nhãn `publicly-verified` đã được đối chiếu nguồn chính thức. Bản đáp án DOCX gốc của các câu hiệu chỉnh vẫn được lưu trong `sourceAnswer`.
