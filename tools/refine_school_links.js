const fs = require("fs");
const path = require("path");

const root = path.resolve(__dirname, "..");
const payloadPath = path.join(root, "data", "curated", "final-scenario-school-links.json");
const payload = JSON.parse(fs.readFileSync(payloadPath, "utf8"));
const school = "Trường Mầm non Sơn Thịnh";

const replacements = [
  ["chi bộ nhà trường", `chi bộ ${school}`],
  ["chi bộ trường", `chi bộ ${school}`],
  ["tại trường", `tại ${school}`],
  ["ở trường", `ở ${school}`],
  ["gần trường", `gần ${school}`],
  ["cho trường", `cho ${school}`]
];

for (const item of payload.items) {
  if (item.schoolApplication.includes(school)) continue;

  let updated = item.schoolApplication;
  for (const [from, to] of replacements) {
    if (updated.includes(from)) {
      updated = updated.replace(from, to);
      break;
    }
  }
  if (!updated.includes(school)) {
    updated = updated.replace(/^Ví dụ /u, `Ví dụ tại ${school}, `);
  }
  if (!updated.includes(school)) throw new Error(`Missing school name: ${item.questionId}`);
  item.schoolApplication = updated;
}

payload.purpose = "Liên hệ thực tế dạng ví dụ áp dụng cho 20 tình huống vòng cuối tại Trường Mầm non Sơn Thịnh; không khẳng định sự cố hay dữ kiện nội bộ đã xảy ra.";
fs.writeFileSync(payloadPath, `${JSON.stringify(payload, null, 2)}\n`, "utf8");
console.log(`Normalized ${payload.items.length} final-scenario applications.`);
