# Xuất xứ vòng thi cuối

Hai tài liệu dưới đây được sao chép nguyên byte từ thư mục Downloads vào dự án. Không chỉnh sửa hoặc ghi đè tài liệu nguồn.

| Tài liệu | SHA-256 | Dung lượng | Đoạn | Bảng | Số trang trong `docProps/app.xml` |
| --- | --- | ---: | ---: | ---: | ---: |
| `final-30-trac-nghiem.docx` | `b2578ede8aefaee4f849a851f577b1dd07b508fb7c3d9f4c18bfbf6f991b9fc8` | 29.042 byte | 188 | 0 | 10 |
| `final-20-tinh-huong.docx` | `ab84877e02f300fd79cae48e2e010153825330f21c390338f0e9c369fc4426ba` | 35.415 byte | 162 | 0 | 12 |

## Cách kiểm tra

`tools/build_final_round.py` dùng Python bundled, `python-docx` và OOXML để đọc toàn bộ đoạn văn, tách đúng 30 câu trắc nghiệm (mỗi câu 4 lựa chọn và 1 đáp án) cùng 20 tình huống (câu hỏi và phần đáp án/gợi ý). Dữ liệu dẫn xuất nằm ở `data/derived/final-round.json` và được compiler đưa vào gói `site/data/question-bank.json` dưới trường `finalRound`.

30 câu trắc nghiệm vòng cuối là tuyển chọn lại từ bộ 395 câu cũ. `data/curated/final-round-corrections.json` giữ nguyên `sourceAnswer` của DOCX và áp dụng hiệu chỉnh có nguồn công khai cho hai tình huống đảng phí cùng câu giám sát bị lệch đáp án; 47 câu còn lại ở trạng thái `source-provided`, 3 câu ở trạng thái `publicly-verified`.

Host hiện tại không có LibreOffice bundled (`soffice.exe`), vì vậy không thể tạo ảnh render để kiểm tra trực quan. Đã thay bằng kiểm tra cấu trúc OOXML, toàn bộ nội dung, số đoạn/bảng và số trang được ghi trong `docProps/app.xml`. Có 47 câu giữ theo DOCX và chưa xác minh riêng; 3 câu đã được đối chiếu nguồn công khai chính thức. Bản gốc DOCX của các câu hiệu chỉnh vẫn được giữ trong `sourceAnswer`.
