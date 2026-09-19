# Bằng chứng hỗ trợ trình bày và liên hệ nơi làm việc

- Ngày kiểm tra: 2026-09-19.
- Phạm vi trắc nghiệm: đúng 395 lời giải, mỗi lời giải 40–70 từ, mở đầu bằng đúng chữ cái đáp án đã duyệt, không còn dấu ba chấm do cắt nội dung. Sáu phương án đúng quá dài được tóm tắt thủ công; 19 câu có đáp án tổng hợp như “Cả 3 phương án” được viết lại để nêu rõ các ý thành phần, thay vì dùng lời giải chung chung.
- Phạm vi vấn đáp: đúng 143 đoạn liên hệ, mỗi đoạn 63–81 từ, đều gọi tên Trường Mầm non Sơn Thịnh và trình bày như ví dụ vận dụng, không khẳng định sự việc nội bộ đã xảy ra.
- Phạm vi vòng cuối: đúng 20 đoạn liên hệ, mỗi đoạn 79–90 từ, đều gọi tên Trường Mầm non Sơn Thịnh và đi kèm lưu ý không bịa sự việc tại trường.
- Địa danh hiển thị: Trường Mầm non Sơn Thịnh, khu vực Phiêng 1, xã Văn Chấn, tỉnh Lào Cai, thuộc địa bàn tỉnh Yên Bái cũ. Nguồn địa giới là Nghị quyết 1673/NQ-UBTVQH15; bối cảnh trường học dùng hai nguồn công khai của cơ quan địa phương và cấp tỉnh, chỉ để định hướng ví dụ.
- Giao diện: sau khi chấm trắc nghiệm hiện nhãn “Giải thích ngắn — trình bày trong khoảng 20–30 giây”; phần vấn đáp có nút riêng “Liên hệ tại trường”; đáp án tình huống vòng cuối hiển thị một khối liên hệ riêng.
- Focused gate: `pwsh -NoProfile -File tests/test_exam_delivery_support.ps1`; kết quả đạt, mã thoát `0`.
- Toàn bộ cổng: `pwsh -NoProfile -File tools/run_gates.ps1`; kết quả cả 7 cổng bắt buộc đạt, mã thoát `0`.
- Nghiệm thu trình duyệt trong ứng dụng ở khung 390 × 844: trả lời một câu trắc nghiệm và thấy lời giải; mở một câu vấn đáp và thấy liên hệ tại trường; mở một tình huống vòng cuối và thấy cả đáp án cùng liên hệ. Không có cảnh báo hay lỗi trong bảng lỗi trình duyệt; bố cục không tràn ngang ở khung quan sát.
- Service worker đổi cache key thành `on-thi-chi-bo-2026-09-19-exam-delivery-support` để thiết bị không giữ bản dữ liệu cũ sau triển khai.
- Quay lui mã nguồn trước tính năng: commit `1c693e7`.
