const fs = require('node:fs');
const path = require('node:path');

const devtoolsPort = process.env.DEVTOOLS_PORT || 9222;
const baseUrl = `http://127.0.0.1:${devtoolsPort}`;
const evidenceDir = path.resolve(__dirname, '..', '50-Evidence');

function delay(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function connect() {
  const pages = await fetch(`${baseUrl}/json/list`).then((response) => response.json());
  const page = pages.find((item) => item.type === 'page');
  if (!page) throw new Error('No browser page is available.');
  const socket = new WebSocket(page.webSocketDebuggerUrl);
  await new Promise((resolve, reject) => {
    socket.addEventListener('open', resolve, { once: true });
    socket.addEventListener('error', reject, { once: true });
  });
  let nextId = 1;
  const pending = new Map();
  const browserErrors = [];
  socket.addEventListener('message', (event) => {
    const message = JSON.parse(event.data);
    if (message.id && pending.has(message.id)) {
      const { resolve, reject } = pending.get(message.id);
      pending.delete(message.id);
      if (message.error) reject(new Error(message.error.message));
      else resolve(message.result);
      return;
    }
    if (message.method === 'Runtime.exceptionThrown') {
      browserErrors.push(message.params.exceptionDetails.text || 'Unhandled browser exception');
    }
    if (message.method === 'Log.entryAdded' && message.params.entry.level === 'error') {
      browserErrors.push(message.params.entry.text);
    }
  });
  function send(method, params = {}) {
    const id = nextId++;
    return new Promise((resolve, reject) => {
      pending.set(id, { resolve, reject });
      socket.send(JSON.stringify({ id, method, params }));
    });
  }
  return { socket, send, browserErrors };
}

async function main() {
  const cdp = await connect();
  const { send } = cdp;
  await send('Runtime.enable');
  await send('Log.enable');
  await send('Page.enable');
  await send('Emulation.setDeviceMetricsOverride', {
    width: 390,
    height: 844,
    deviceScaleFactor: 1,
    mobile: true,
    screenWidth: 390,
    screenHeight: 844
  });

  async function evaluate(expression) {
    const result = await send('Runtime.evaluate', {
      expression,
      awaitPromise: true,
      returnByValue: true
    });
    if (result.exceptionDetails) throw new Error(result.exceptionDetails.text || expression);
    return result.result.value;
  }

  async function waitFor(expression, timeout = 7000) {
    const started = Date.now();
    while (Date.now() - started < timeout) {
      if (await evaluate(expression)) return;
      await delay(80);
    }
    throw new Error(`Timed out waiting for: ${expression}`);
  }

  await send('Page.navigate', { url: 'http://127.0.0.1:8788/' });
  await waitFor(`document.readyState === 'complete' && document.querySelector('#mcqProgressText')?.textContent.includes('395')`);
  const layout = await evaluate(`({
    title: document.title,
    width: innerWidth,
    scrollWidth: document.documentElement.scrollWidth,
    h1: document.querySelector('#homeTitle').textContent,
    modeCards: document.querySelectorAll('[data-mode]').length,
    finalRoundCards: document.querySelectorAll('[data-final-mode]').length
  })`);
  if (layout.title !== 'Ôn thi Bí thư chi bộ') throw new Error('Unexpected page title.');
  if (layout.modeCards !== 2) throw new Error('Expected two study modes.');
  if (layout.finalRoundCards !== 2) throw new Error('Expected two final-round study modes.');
  if (layout.scrollWidth > layout.width + 1) throw new Error(`Mobile page overflows horizontally: ${layout.scrollWidth}/${layout.width}.`);

  const mobileShot = await send('Page.captureScreenshot', { format: 'png', captureBeyondViewport: false });
  fs.writeFileSync(path.join(evidenceDir, 'home-mobile-cdp.png'), Buffer.from(mobileShot.data, 'base64'));

  await evaluate(`document.querySelector('[data-mode="mcq"]').click()`);
  await waitFor(`document.querySelector('#sectionDialog').open`);
  const sectionCount = await evaluate(`document.querySelectorAll('#sectionOptions .section-choice').length`);
  if (sectionCount !== 6) throw new Error(`Expected six section choices, found ${sectionCount}.`);
  await evaluate(`document.querySelector('#sectionOptions .section-choice').click()`);
  await waitFor(`!document.querySelector('#practiceView').classList.contains('is-hidden') && document.querySelectorAll('#optionList input').length === 4`);
  await evaluate(`(() => { const input = document.querySelector('#optionList input[value="A"]'); input.checked = true; input.dispatchEvent(new Event('change', { bubbles: true })); document.querySelector('#mcqForm').requestSubmit(); })()`);
  await waitFor(`!document.querySelector('#feedbackPanel').classList.contains('is-hidden')`);
  const mcqResult = await evaluate(`({
    feedback: document.querySelector('#feedbackTitle').textContent,
    correctMarked: document.querySelectorAll('.option-label.is-correct').length,
    saved: Boolean(JSON.parse(localStorage.getItem('${'on-thi-bi-thu-chi-bo-v1'}')).mcq['mcq-van-phong-1'])
  })`);
  if (!mcqResult.feedback.includes('Đúng rồi') || mcqResult.correctMarked !== 1 || !mcqResult.saved) {
    throw new Error('MCQ interaction did not complete correctly.');
  }
  const practiceShot = await send('Page.captureScreenshot', { format: 'png', captureBeyondViewport: false });
  fs.writeFileSync(path.join(evidenceDir, 'practice-mobile.png'), Buffer.from(practiceShot.data, 'base64'));

  await evaluate(`document.querySelector('#brandButton').click()`);
  await waitFor(`!document.querySelector('#homeView').classList.contains('is-hidden')`);
  await evaluate(`document.querySelector('[data-mode="oral"]').click()`);
  await waitFor(`document.querySelector('#sectionDialog').open`);
  await evaluate(`document.querySelector('#sectionOptions .section-choice').click()`);
  await waitFor(`!document.querySelector('#oralArea').classList.contains('is-hidden')`);
  await evaluate(`document.querySelector('#lightHintButton').click(); document.querySelector('#outlineButton').click();`);
  const oralResult = await evaluate(`({
    lightOpen: !document.querySelector('#lightHintPanel').classList.contains('is-hidden'),
    outlineOpen: !document.querySelector('#outlinePanel').classList.contains('is-hidden'),
    outlineItems: document.querySelectorAll('#outlinePanel li').length
  })`);
  if (!oralResult.lightOpen || !oralResult.outlineOpen || oralResult.outlineItems < 4) {
    throw new Error('Oral hint interaction did not complete correctly.');
  }
  const oralShot = await send('Page.captureScreenshot', { format: 'png', captureBeyondViewport: false });
  fs.writeFileSync(path.join(evidenceDir, 'oral-hints-mobile.png'), Buffer.from(oralShot.data, 'base64'));
  await evaluate(`document.querySelector('#needReviewButton').click()`);
  const oralSaved = await evaluate(`Boolean(Object.keys(JSON.parse(localStorage.getItem('${'on-thi-bi-thu-chi-bo-v1'}')).oral).length)`);
  if (!oralSaved) throw new Error('Oral review status was not saved.');

  await evaluate(`document.querySelector('#brandButton').click()`);
  await waitFor(`!document.querySelector('#homeView').classList.contains('is-hidden')`);
  await evaluate(`document.querySelector('[data-final-mode="mcq"]').click()`);
  await waitFor(`!document.querySelector('#practiceView').classList.contains('is-hidden') && document.querySelectorAll('#optionList input').length === 4`);
  if (await evaluate(`document.querySelector('#sectionDialog').open`)) throw new Error('Final-round MCQ opened the old section dialog.');
  await evaluate(`(() => { const input = document.querySelector('#optionList input[value="A"]'); input.checked = true; input.dispatchEvent(new Event('change', { bubbles: true })); document.querySelector('#mcqForm').requestSubmit(); })()`);
  await waitFor(`!document.querySelector('#feedbackPanel').classList.contains('is-hidden')`);
  const finalMcqSaved = await evaluate(`Boolean(JSON.parse(localStorage.getItem('${'on-thi-bi-thu-chi-bo-v1'}')).finalRound.mcq['final-mcq-1'])`);
  if (!finalMcqSaved) throw new Error('Final-round MCQ answer was not saved.');

  await evaluate(`document.querySelector('#brandButton').click()`);
  await waitFor(`!document.querySelector('#homeView').classList.contains('is-hidden')`);
  await evaluate(`document.querySelector('[data-final-mode="scenario"]').click()`);
  await waitFor(`!document.querySelector('#finalScenarioArea').classList.contains('is-hidden')`);
  if (await evaluate(`document.querySelector('#sectionDialog').open`)) throw new Error('Final-round scenario opened the old section dialog.');
  await evaluate(`document.querySelector('#finalScenarioAnswerButton').click()`);
  const finalScenarioResult = await evaluate(`({ open: !document.querySelector('#finalScenarioAnswerPanel').classList.contains('is-hidden'), text: document.querySelector('#finalScenarioAnswerPanel').textContent, saved: Boolean(JSON.parse(localStorage.getItem('${'on-thi-bi-thu-chi-bo-v1'}')).finalRound.scenarios['final-scenario-1']) })`);
  if (!finalScenarioResult.open || !finalScenarioResult.text.includes('Đáp án đã đối chiếu văn bản') || !finalScenarioResult.saved) throw new Error('Final-round corrected scenario answer did not open with verified label.');
  if (cdp.browserErrors.length) throw new Error(`Browser errors: ${cdp.browserErrors.join(' | ')}`);

  console.log(JSON.stringify({
    result: 'passed',
    mobileViewport: `${layout.width}px`,
    horizontalOverflow: false,
    mcq: 'passed',
    oralHints: 'passed',
    finalRound: 'passed',
    persistence: 'passed'
  }, null, 2));
  await send('Browser.close');
  cdp.socket.close();
}

main().catch((error) => {
  console.error(error.stack || error.message);
  process.exitCode = 1;
});
