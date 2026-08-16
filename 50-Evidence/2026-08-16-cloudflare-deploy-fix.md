---
verified_at: 2026-08-16
verified_by: Codex
status: local-fix-passed
---

# Sửa lỗi triển khai Cloudflare Workers

## Lỗi quan sát được

- Workers Build đọc đủ 10 tệp và tải thành công 7 tài nguyên thay đổi.
- API từ chối tạo phiên bản Worker với mã `100324`.
- Thông báo xác định dòng 1 của `_redirects` tạo vòng lặp vô hạn.
- Build cũng cảnh báo tên trong `wrangler.jsonc` là `on-thi-bi-thu-chi-bo`, không khớp Worker `mom-s-exam` do CI cung cấp.

## Thay đổi

- Xóa `site/_redirects` có quy tắc `/* /index.html 200`.
- Giữ `assets.not_found_handling = single-page-application` làm cơ chế SPA duy nhất.
- Đồng bộ `name` trong `wrangler.jsonc` thành `mom-s-exam`.
- Cập nhật `site.static-integrity` để `_redirects` không còn là tệp bắt buộc.
- Thêm cổng hồi quy `deploy.cloudflare-static-assets-config` để ngăn cấu hình vòng lặp quay lại.

## Kiểm chứng và quay lui

- Mốc trước sửa: cả 4 cổng bắt buộc đạt, nhưng Cloudflare từ chối triển khai do cấu hình vòng lặp.
- Thử âm: tạm khôi phục đúng quy tắc lỗi rồi chạy `pwsh -NoProfile -File tests/test_cloudflare_deploy_config.ps1`; cổng thất bại như dự kiến với thông báo chặn `/* /index.html 200`.
- Lệnh: `pwsh -NoProfile -File tools/run_gates.ps1`; quan sát: cả 5 cổng bắt buộc đạt, mã thoát `0`.
- Lệnh: `wrangler@4.123.0 deploy --dry-run`; môi trường: Windows cục bộ, gói sau sửa; quan sát: đọc 9 tệp, không còn `_redirects`, mã thoát `0`.
- Lệnh: `audit_project_memory.py <project-root>`; quan sát: quét 20 tệp Markdown, mã thoát `0`.
- Xác nhận Cloudflare thật vẫn cần lần chạy lại Workers Build vì chế độ dry-run không gọi API xuất bản.
- Quay lui mã nguồn: commit `7419358`. Không quay lui riêng `_redirects` vì đó là nguyên nhân đã xác định.
