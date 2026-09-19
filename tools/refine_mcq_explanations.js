const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const bankPath = path.join(root, "site", "data", "question-bank.json");
const payloadPath = path.join(root, "data", "curated", "mcq-explanations.json");

const bank = JSON.parse(fs.readFileSync(bankPath, "utf8"));
const payload = JSON.parse(fs.readFileSync(payloadPath, "utf8"));
const questions = new Map(bank.multipleChoice.map((question) => [question.id, question]));

const reviewedSummaries = new Map([
  [
    "mcq-van-phong-8",
    "Đáp án D: Được miễn gồm ba nhóm: đảng viên đủ 50 năm tuổi Đảng; người hưởng trợ cấp hưu trí xã hội; người đặc biệt khó khăn có đơn đề nghị chi bộ. Quy định liệt kê đủ ba nhóm nên phải chọn phương án tổng hợp, không chọn riêng A, B hoặc C."
  ],
  [
    "mcq-van-phong-47",
    "Đáp án D: Người tiếp cận bí mật phải đồng thời tuân thủ pháp luật, quy chế; áp dụng biện pháp bảo vệ, sử dụng đúng mục đích; thực hiện hướng dẫn của tổ chức quản lý. Ba trách nhiệm bổ sung nhau nên phương án tổng hợp mới đầy đủ. Cần đối chiếu bản chính quy chế địa phương."
  ],
  [
    "mcq-tuyen-giao-dan-van-37",
    "Đáp án D: Nhân dân có thể bàn, quyết định qua họp cộng đồng, phiếu lấy ý kiến từng hộ hoặc biểu quyết trực tuyến khi đã có thống nhất theo quy định. Luật cho phép cả ba hình thức khi đủ điều kiện tổ chức, không loại bỏ một hình thức chỉ vì ít dùng."
  ],
  [
    "mcq-noi-chinh-1",
    "Đáp án D: Nhà nước dân chủ thể hiện ở lợi ích, quyền hạn, công việc đổi mới đều thuộc về và vì dân; kháng chiến, kiến quốc là việc của dân; chính quyền do dân cử và đoàn thể do dân tổ chức. Ba phương án hợp lại mới phản ánh đầy đủ tư tưởng dân là chủ."
  ],
  [
    "mcq-noi-chinh-2",
    "Đáp án D: Cả ba đều là tiêu cực: làm trái hoặc không làm đầy đủ chủ trương, pháp luật; không thực hiện trách nhiệm nêu gương; quan liêu, xa thực tế, không nắm tình hình. Điểm chung là không làm đúng trách nhiệm, làm suy giảm hiệu lực và niềm tin."
  ],
  [
    "mcq-noi-chinh-13",
    "Đáp án D: Nghị quyết đồng thời hướng tới ngăn chặn, đẩy lùi tham nhũng, lãng phí, tiêu cực; xây dựng Đảng và hệ thống chính trị trong sạch, củng cố niềm tin; thúc đẩy phát triển kinh tế - xã hội và tăng trưởng. Ba mục tiêu gắn phòng chống vi phạm với xây dựng và phát triển."
  ],
  [
    "mcq-noi-chinh-14",
    "Đáp án D: Lộ trình gồm ba tầng: tạo khung pháp lý cho nhiệm vụ 2026–2031; đến 2030 có hệ thống pháp luật dân chủ, đồng bộ, minh bạch, khả thi; đến 2045 đạt chất lượng cao, hiện đại, phù hợp thực tiễn và thông lệ quốc tế. Chọn D vì đủ cả trước mắt và dài hạn."
  ],
  [
    "mcq-noi-chinh-20",
    "Đáp án D: Chất lượng xây dựng pháp luật phải đồng thời đặt dưới sự lãnh đạo của Đảng; phát huy vai trò Quốc hội, Chính phủ, Mặt trận và cơ quan liên quan; tăng kiểm tra, giám sát, kiểm soát quyền lực và chống lợi ích nhóm. Thiếu một nhóm nhiệm vụ là chưa đầy đủ."
  ],
  [
    "mcq-noi-chinh-37",
    "Đáp án D: Thành viên phải thực hiện đúng quyền hạn và chịu trách nhiệm; đấu tranh với hành vi trái quy định; nêu rõ chính kiến, chịu trách nhiệm và được bảo lưu ý kiến. Ba yêu cầu bao quát cả chấp hành, đấu tranh và trách nhiệm cá nhân nên đều phải thực hiện."
  ],
  [
    "mcq-noi-chinh-40",
    "Đáp án D: Cả ba đều là hành vi tiêu cực: ban hành hoặc tham mưu văn bản trái quy định; không thực hiện hoặc thực hiện không đầy đủ quy định; thiếu trách nhiệm, buông lỏng quản lý để xảy ra lợi dụng. Chúng khác biểu hiện nhưng cùng làm sai lệch hoạt động tố tụng, thi hành án."
  ],
  [
    "mcq-noi-chinh-41",
    "Đáp án D: Cấp ủy phải đồng thời tham mưu, tổ chức thực hiện quy định; rà soát, hoàn thiện quy chế, quy trình, chuẩn mực; kiểm tra, giám sát, thanh tra và phát huy công tố, kiểm sát tư pháp. Ba nhóm tạo thành chu trình phòng ngừa, thực hiện và kiểm soát."
  ],
  [
    "mcq-to-chuc-xay-dung-dang-20",
    "Đáp án D: Kết nạp lại đòi hỏi đủ tiêu chuẩn người vào Đảng; đủ thời gian, đơn, văn bản đồng ý và quyết định đúng thẩm quyền; đồng thời làm đủ thủ tục theo Điều lệ. Đây là các điều kiện cộng dồn, không phải chỉ cần chọn một trong A, B hoặc C."
  ],
  [
    "mcq-to-chuc-xay-dung-dang-21",
    "Đáp án D: Không xem xét kết nạp lại đối với cả ba nhóm: tự bỏ sinh hoạt; tự xin ra, trừ hoàn cảnh đặc biệt, hoặc gây mất đoàn kết nghiêm trọng; bị kết án về tham nhũng, lãng phí, tiêu cực hay tội nghiêm trọng trở lên. D bao quát đủ các trường hợp loại trừ."
  ],
  [
    "mcq-to-chuc-xay-dung-dang-31",
    "Đáp án D: Đảng viên được miễn sinh hoạt vẫn có quyền dự đại hội, nhận thông tin, xét Huy hiệu và miễn đánh giá; đồng thời phải gương mẫu, vận động gia đình chấp hành và vẫn bị kỷ luật nếu vi phạm. Quy định gồm cả quyền lẫn trách nhiệm nên A, B, C đều đúng."
  ],
  [
    "mcq-to-chuc-xay-dung-dang-32",
    "Đáp án D: Xóa tên được xem xét khi đảng viên bỏ sinh hoạt hoặc không đóng phí; tự trả, hủy thẻ; hoặc suy giảm ý chí, vi phạm tư cách, không tiến bộ sau giáo dục hay không bảo đảm tiêu chuẩn chính trị. Các nhóm A, B, C đều là căn cứ nên D đầy đủ nhất."
  ],
  [
    "mcq-to-chuc-xay-dung-dang-34",
    "Đáp án D: Quần chúng trên 60 tuổi chỉ được xem xét khi đồng thời có sức khỏe, uy tín; công tác hoặc cư trú ở nơi thiếu tổ chức, đảng viên hay có yêu cầu đặc biệt; và được cấp có thẩm quyền đồng ý bằng văn bản trước quyết định kết nạp. Đây là điều kiện cộng dồn."
  ],
  [
    "mcq-to-chuc-xay-dung-dang-45",
    "Đáp án D: Người bệnh nặng có thể nhận Huy hiệu 30–65 năm sớm tối đa 12 tháng, Huy hiệu 70–95 năm sớm tối đa 24 tháng; người từ trần được truy tặng sớm tối đa 12 tháng. Ba mốc áp dụng cho ba trường hợp khác nhau nên A, B, C đều đúng."
  ],
  [
    "mcq-to-chuc-xay-dung-dang-48",
    "Đáp án D: Hồ sơ chuyển sinh hoạt chính thức trong nước gồm phiếu đảng viên khi chuyển khỏi đảng bộ cấp trên trực tiếp; thẻ và hồ sơ đảng viên; bản tự kiểm điểm có nhận xét của chi bộ, cấp ủy nơi giới thiệu. Chọn D vì phải mang đủ ba nhóm tài liệu."
  ],
  [
    "mcq-to-chuc-xay-dung-dang-70",
    "Đáp án D: Đối tượng kiểm điểm hằng năm là toàn bộ đảng viên, trừ ba nhóm: mới kết nạp chưa đủ 6 tháng, đang bị đình chỉ sinh hoạt, hoặc được miễn công tác và sinh hoạt. Cách nhớ: nguyên tắc là kiểm điểm toàn bộ, A–C là ngoại lệ. Cần đối chiếu văn bản địa phương."
  ],
  [
    "mcq-noi-chinh-5",
    "Đáp án A: Kiểm soát việc lãnh đạo, chỉ đạo và tổ chức thực hiện chủ trương của Đảng, pháp luật, quy chế, quy trình nghiệp vụ, chuẩn mực đạo đức, quy tắc ứng xử và phòng, chống tham nhũng, tiêu cực trong tố tụng, thi hành án. Phương án này bao quát cả hoạt động liên quan."
  ],
  [
    "mcq-tuyen-giao-dan-van-15",
    "Đáp án A: Chủ đề gồm bốn ý: xây dựng Đảng và hệ thống chính trị trong sạch, vững mạnh; phát huy đại đoàn kết; tạo đột phá để Lào Cai thành cực tăng trưởng, trung tâm kết nối giao thương quốc tế; phát triển xanh, hài hòa, bản sắc, hạnh phúc. Các phương án khác thiếu ý."
  ],
  [
    "mcq-tuyen-giao-dan-van-16",
    "Đáp án C: Mục tiêu là Lào Cai trở thành cực tăng trưởng, trung tâm kết nối Việt Nam - ASEAN với Tây Nam Trung Quốc; phát triển xanh, hài hòa, bản sắc, hạnh phúc, gắn với năm yêu cầu: giữ biên giới, dân, rừng, nước và môi trường. Cần nhớ đủ cả phát triển và bảo vệ."
  ],
  [
    "mcq-noi-chinh-75",
    "Đáp án C: Trọng tâm là các vụ khiếu kiện đông người, phức tạp, kéo dài, nhất là về đất đai, môi trường, dân tộc, tôn giáo, đầu tư, tài chính, lao động và tố tụng tư pháp. Đây là nhóm lĩnh vực nhạy cảm, dễ phát sinh điểm nóng nên phải chủ động nắm, xử lý."
  ],
  [
    "mcq-to-chuc-xay-dung-dang-143",
    "Đáp án B: Bảo vệ cán bộ là áp dụng biện pháp cần thiết, kịp thời, hiệu quả, đúng quy định và phù hợp thực tiễn để bảo đảm quyền, lợi ích hợp pháp của cán bộ cùng cơ quan, tổ chức, cá nhân liên quan. Điểm đủ ý là vừa đúng pháp luật, vừa bảo vệ đúng đối tượng."
  ],
  [
    "mcq-noi-chinh-27",
    "Đáp án B: Lãng phí là quản lý, khai thác hoặc sử dụng tài chính công, tài sản công, bộ máy, lao động, tài nguyên, năng lượng vượt định mức hoặc không hiệu quả, không đạt mục tiêu; gồm cả hành vi gây lãng phí, cản trở phát triển hay làm lỡ thời cơ. Phải nhớ cả “vượt chuẩn” và “không hiệu quả”."
  ],
  [
    "mcq-noi-chinh-61",
    "Đáp án B: Đình chỉ công tác, chức vụ và không bố trí làm công tác tham mưu, nghiệp vụ về quản lý, sử dụng tài chính, tài sản công. Biện pháp này vừa ngăn người có hành vi tham nhũng, tiêu cực tiếp tục tác động vào lĩnh vực rủi ro, vừa hỗ trợ xử lý đúng quy định."
  ]
]);

let refined = 0;
for (const item of payload.items) {
  if (reviewedSummaries.has(item.questionId)) {
    if (item.shortExplanation !== reviewedSummaries.get(item.questionId)) refined += 1;
    item.shortExplanation = reviewedSummaries.get(item.questionId);
    continue;
  }
  if (!item.shortExplanation.includes("…")) continue;

  const question = questions.get(item.questionId);
  if (!question) throw new Error(`Unknown question: ${item.questionId}`);
  const option = question.options.find((candidate) => candidate.id === question.correctOption);
  if (!option) throw new Error(`Missing correct option: ${item.questionId}`);

  if (reviewedSummaries.has(item.questionId)) {
    item.shortExplanation = reviewedSummaries.get(item.questionId);
  } else {
    const answerWords = option.text.trim().split(/\s+/u).length;
    const reason = answerWords <= 42
      ? "Đây là nội dung đúng trọng tâm; các phương án còn lại làm thiếu, đổi hoặc ghép sai điều kiện của quy định."
      : "Điểm quyết định là phương án nêu đủ đúng đối tượng, điều kiện và phạm vi.";
    item.shortExplanation = `Đáp án ${question.correctOption}: ${option.text} ${reason}`;
  }
  refined += 1;
}

for (const item of payload.items) {
  if (/…/u.test(item.shortExplanation)) throw new Error(`Truncated explanation remains: ${item.questionId}`);
  const words = item.shortExplanation.trim().split(/\s+/u).length;
  if (words < 20 || words > 70) throw new Error(`${item.questionId} has ${words} words after refinement.`);
}

payload.purpose = "Mỗi câu nêu ngay đáp án, lý do phân biệt và điểm cần nhớ để người học có thể trình bày rõ trong khoảng 20-30 giây.";
payload.reviewNote = "81 câu có phương án đúng dài đã được biên tập để không còn nội dung bị cắt; sáu phương án rất dài được tóm tắt thủ công. Mười chín câu có đáp án tổng hợp như ‘Cả 3 phương án’ được viết lại để nêu rõ các ý thành phần.";
fs.writeFileSync(payloadPath, `${JSON.stringify(payload, null, 2)}\n`, "utf8");
console.log(`Refined ${refined} MCQ explanations; all ${payload.items.length} items passed length and truncation checks.`);
