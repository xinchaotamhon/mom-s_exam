(() => {
  'use strict';

  const STORAGE_KEY = 'on-thi-bi-thu-chi-bo-v1';
  const SECTION_ORDER = [
    'van-phong',
    'tuyen-giao-dan-van',
    'noi-chinh',
    'kiem-tra-giam-sat',
    'to-chuc-xay-dung-dang'
  ];
  const STATUS_LABELS = {
    'publicly-verified': 'Đã đối chiếu nguồn công khai',
    'cross-checked': 'Đã rà soát nội dung',
    'local-source-needed': 'Nên đối chiếu thêm văn bản nội bộ',
    'editorial-support': 'Gợi ý luyện trình bày'
  };

  const elements = {};
  let bank = null;
  let sourceMap = new Map();
  let pendingMode = 'mcq';
  let toastTimer = null;
  let session = null;
  let state = loadState();

  function defaultState() {
    return {
      mcq: {},
      oral: {},
      daily: { date: todayKey(), ids: [] },
      preferences: { fontScale: 1.08 },
      lastSession: null
    };
  }

  function todayKey() {
    return new Intl.DateTimeFormat('en-CA', {
      timeZone: 'Asia/Ho_Chi_Minh',
      year: 'numeric',
      month: '2-digit',
      day: '2-digit'
    }).format(new Date());
  }

  function loadState() {
    const fallback = defaultState();
    try {
      const saved = JSON.parse(localStorage.getItem(STORAGE_KEY) || 'null');
      if (!saved || typeof saved !== 'object') return fallback;
      return {
        ...fallback,
        ...saved,
        mcq: saved.mcq || {},
        oral: saved.oral || {},
        preferences: { ...fallback.preferences, ...(saved.preferences || {}) },
        daily: saved.daily?.date === todayKey() ? saved.daily : fallback.daily
      };
    } catch {
      return fallback;
    }
  }

  function saveState() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  }

  function cacheElements() {
    document.querySelectorAll('[id]').forEach((element) => {
      elements[element.id] = element;
    });
  }

  async function init() {
    cacheElements();
    applyFontScale(state.preferences.fontScale);
    bindEvents();
    try {
      const response = await fetch('/data/question-bank.json', { cache: 'no-cache' });
      if (!response.ok) throw new Error(`Không tải được dữ liệu (${response.status})`);
      bank = await response.json();
      sourceMap = new Map(bank.sources.map((source) => [source.id, source]));
      renderSourceDialog();
      renderHome();
      restoreFromAddress();
      registerServiceWorker();
    } catch (error) {
      elements.homeTitle.textContent = 'Chưa mở được bộ câu hỏi.';
      elements.homeView.querySelector('.hero-copy').textContent = 'Vui lòng kiểm tra kết nối rồi tải lại trang. ' + error.message;
      document.querySelectorAll('.mode-card, .review-actions button').forEach((button) => { button.disabled = true; });
    }
  }

  function bindEvents() {
    document.querySelectorAll('.mode-card').forEach((button) => {
      button.addEventListener('click', () => openSectionDialog(button.dataset.mode));
    });
    elements.brandButton.addEventListener('click', leavePractice);
    elements.backButton.addEventListener('click', leavePractice);
    elements.emptyHomeButton.addEventListener('click', leavePractice);
    elements.settingsButton.addEventListener('click', () => elements.settingsDialog.showModal());
    elements.sourcesButton.addEventListener('click', () => elements.sourcesDialog.showModal());
    elements.resumeButton.addEventListener('click', resumeLastSession);
    elements.reviewWrongButton.addEventListener('click', () => startReview('mcq'));
    elements.reviewOralButton.addEventListener('click', () => startReview('oral'));
    elements.mcqForm.addEventListener('submit', checkMcqAnswer);
    elements.previousButton.addEventListener('click', () => moveQuestion(-1));
    elements.nextButton.addEventListener('click', () => moveQuestion(1));
    elements.lightHintButton.addEventListener('click', toggleLightHint);
    elements.outlineButton.addEventListener('click', toggleOutline);
    elements.rememberButton.addEventListener('click', () => rateOral('remember'));
    elements.needReviewButton.addEventListener('click', () => rateOral('review'));
    elements.resetProgressButton.addEventListener('click', resetProgress);
    document.querySelectorAll('[data-font]').forEach((button) => {
      button.addEventListener('click', () => applyFontScale(Number(button.dataset.font), true));
    });
    window.addEventListener('popstate', () => {
      if (location.hash !== '#study') showHome();
    });
  }

  function openSectionDialog(mode) {
    if (!bank) return;
    pendingMode = mode;
    elements.sectionDialogTitle.textContent = mode === 'mcq' ? 'Ôn trắc nghiệm' : 'Ôn vấn đáp';
    elements.sectionOptions.replaceChildren();
    const questions = questionsForMode(mode);
    addSectionChoice('all', 'Tất cả 5 chủ đề', questions.length);
    SECTION_ORDER.forEach((sectionId) => {
      const sectionQuestions = questions.filter((question) => question.sectionId === sectionId);
      if (!sectionQuestions.length) return;
      addSectionChoice(sectionId, friendlySection(sectionQuestions[0].section), sectionQuestions.length);
    });
    elements.sectionDialog.showModal();
  }

  function addSectionChoice(sectionId, label, count) {
    const button = document.createElement('button');
    button.type = 'button';
    button.className = 'section-choice';
    const strong = document.createElement('strong');
    strong.textContent = label;
    const span = document.createElement('span');
    span.textContent = `${count} câu`;
    button.append(strong, span);
    button.addEventListener('click', () => {
      const shuffle = elements.shuffleInput.checked;
      elements.sectionDialog.close();
      startSession(pendingMode, sectionId, { shuffle });
    });
    elements.sectionOptions.append(button);
  }

  function questionsForMode(mode) {
    return mode === 'mcq' ? bank.multipleChoice : bank.oral;
  }

  function startSession(mode, sectionId = 'all', options = {}) {
    let questions = questionsForMode(mode).filter((question) => sectionId === 'all' || question.sectionId === sectionId);
    if (options.ids) {
      const idSet = new Set(options.ids);
      questions = questions.filter((question) => idSet.has(question.id));
    }
    if (options.shuffle) questions = shuffled(questions);
    if (!questions.length) {
      showEmpty('Không còn câu nào trong nhóm ôn lại này.');
      return;
    }
    session = {
      mode,
      sectionId,
      filter: options.filter || 'all',
      shuffle: Boolean(options.shuffle),
      queue: questions,
      index: Math.min(options.index || 0, questions.length - 1),
      checked: false
    };
    persistSession();
    showPractice();
    renderQuestion();
    if (location.hash !== '#study') history.pushState({ study: true }, '', '#study');
  }

  function startReview(mode) {
    const ids = mode === 'mcq'
      ? Object.entries(state.mcq).filter(([, result]) => !result.correct).map(([id]) => id)
      : Object.entries(state.oral).filter(([, result]) => result.rating === 'review').map(([id]) => id);
    startSession(mode, 'all', { ids, shuffle: true, filter: 'review' });
  }

  function resumeLastSession() {
    const saved = state.lastSession;
    if (!saved || !bank) return;
    startSession(saved.mode, saved.sectionId, {
      ids: saved.queueIds,
      index: saved.index,
      filter: saved.filter,
      shuffle: false
    });
  }

  function persistSession() {
    if (!session) return;
    state.lastSession = {
      mode: session.mode,
      sectionId: session.sectionId,
      filter: session.filter,
      index: session.index,
      queueIds: session.queue.map((question) => question.id)
    };
    saveState();
  }

  function renderQuestion() {
    const question = session.queue[session.index];
    session.checked = false;
    elements.questionTitle.textContent = question.prompt;
    elements.sectionLabel.textContent = friendlySection(question.section);
    elements.typeBadge.textContent = session.mode === 'mcq' ? 'TRẮC NGHIỆM' : 'VẤN ĐÁP';
    elements.typeBadge.style.background = session.mode === 'mcq' ? '' : 'var(--gold-soft)';
    elements.typeBadge.style.color = session.mode === 'mcq' ? '' : 'var(--gold)';
    elements.sessionProgressText.textContent = `Câu ${session.index + 1} / ${session.queue.length}`;
    elements.sessionProgressBar.style.width = `${((session.index + 1) / session.queue.length) * 100}%`;
    elements.previousButton.disabled = session.index === 0;
    elements.nextButton.innerHTML = session.index === session.queue.length - 1
      ? 'Hoàn thành <span aria-hidden="true">✓</span>'
      : 'Câu tiếp <span aria-hidden="true">→</span>';
    elements.feedbackPanel.classList.add('is-hidden');
    elements.feedbackPanel.classList.remove('is-incorrect');
    elements.questionSources.open = false;
    if (session.mode === 'mcq') renderMcq(question);
    else renderOral(question);
    renderQuestionSources(question);
    persistSession();
    requestAnimationFrame(() => elements.questionTitle.focus({ preventScroll: true }));
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  function renderMcq(question) {
    elements.mcqForm.classList.remove('is-hidden');
    elements.oralArea.classList.add('is-hidden');
    elements.optionList.replaceChildren();
    elements.checkButton.disabled = true;
    elements.checkButton.textContent = 'Kiểm tra đáp án';
    question.options.forEach((option) => {
      const label = document.createElement('label');
      label.className = 'option-label';
      label.dataset.option = option.id;
      const input = document.createElement('input');
      input.type = 'radio';
      input.name = 'answer';
      input.value = option.id;
      input.addEventListener('change', () => { elements.checkButton.disabled = false; });
      const letter = document.createElement('span');
      letter.className = 'option-letter';
      letter.textContent = option.id;
      const text = document.createElement('span');
      text.className = 'option-text';
      text.textContent = option.text;
      label.append(input, letter, text);
      elements.optionList.append(label);
    });
  }

  function checkMcqAnswer(event) {
    event.preventDefault();
    if (session?.mode !== 'mcq' || session.checked) return;
    const question = session.queue[session.index];
    const selectedInput = elements.mcqForm.querySelector('input[name="answer"]:checked');
    if (!selectedInput) return;
    const selected = selectedInput.value;
    const correct = selected === question.correctOption;
    session.checked = true;
    elements.optionList.querySelectorAll('.option-label').forEach((label) => {
      const isCorrect = label.dataset.option === question.correctOption;
      const isSelectedWrong = label.dataset.option === selected && !correct;
      label.classList.toggle('is-correct', isCorrect);
      label.classList.toggle('is-wrong', isSelectedWrong);
      label.querySelector('input').disabled = true;
    });
    elements.checkButton.disabled = true;
    elements.checkButton.textContent = correct ? 'Đã trả lời đúng' : 'Mình xem lại đáp án nhé';
    elements.feedbackTitle.textContent = correct ? 'Đúng rồi — rất tốt! 🌿' : 'Chưa đúng, mình xem lại nhẹ nhàng nhé.';
    elements.explanationText.textContent = question.explanation;
    elements.memoryText.textContent = question.memoryCue;
    elements.feedbackPanel.classList.toggle('is-incorrect', !correct);
    elements.feedbackPanel.classList.remove('is-hidden');
    const previous = state.mcq[question.id];
    state.mcq[question.id] = {
      selected,
      correct,
      attempts: (previous?.attempts || 0) + 1,
      updatedAt: new Date().toISOString()
    };
    recordDaily(question.id);
    saveState();
    renderHome();
  }

  function renderOral(question) {
    elements.mcqForm.classList.add('is-hidden');
    elements.oralArea.classList.remove('is-hidden');
    elements.lightHintPanel.classList.add('is-hidden');
    elements.outlinePanel.classList.add('is-hidden');
    elements.lightHintButton.setAttribute('aria-expanded', 'false');
    elements.outlineButton.setAttribute('aria-expanded', 'false');
    elements.lightHintPanel.replaceChildren();
    elements.outlinePanel.replaceChildren();
    const saved = state.oral[question.id];
    elements.rememberButton.classList.toggle('is-selected', saved?.rating === 'remember');
    elements.needReviewButton.classList.toggle('is-selected', saved?.rating === 'review');
  }

  function toggleLightHint() {
    const question = session.queue[session.index];
    const willOpen = elements.lightHintPanel.classList.contains('is-hidden');
    if (willOpen && !elements.lightHintPanel.childNodes.length) {
      const strong = document.createElement('strong');
      strong.textContent = 'Mẹo nhớ';
      const cue = document.createElement('p');
      cue.textContent = question.memoryCue;
      const hint = document.createElement('p');
      hint.textContent = question.hint;
      elements.lightHintPanel.append(strong, cue, hint);
    }
    elements.lightHintPanel.classList.toggle('is-hidden', !willOpen);
    elements.lightHintButton.setAttribute('aria-expanded', String(willOpen));
  }

  function toggleOutline() {
    const question = session.queue[session.index];
    const willOpen = elements.outlinePanel.classList.contains('is-hidden');
    if (willOpen && !elements.outlinePanel.childNodes.length) {
      const strong = document.createElement('strong');
      strong.textContent = 'Khung trả lời thực tế';
      const list = document.createElement('ol');
      question.answerOutline.forEach((line) => {
        const item = document.createElement('li');
        item.textContent = line;
        list.append(item);
      });
      elements.outlinePanel.append(strong, list);
    }
    elements.outlinePanel.classList.toggle('is-hidden', !willOpen);
    elements.outlineButton.setAttribute('aria-expanded', String(willOpen));
  }

  function rateOral(rating) {
    if (session?.mode !== 'oral') return;
    const question = session.queue[session.index];
    state.oral[question.id] = { rating, updatedAt: new Date().toISOString() };
    elements.rememberButton.classList.toggle('is-selected', rating === 'remember');
    elements.needReviewButton.classList.toggle('is-selected', rating === 'review');
    recordDaily(question.id);
    saveState();
    renderHome();
    showToast(rating === 'remember' ? 'Đã ghi nhận: cô đã nhớ câu này.' : 'Đã thêm vào nhóm cần ôn lại.');
  }

  function renderQuestionSources(question) {
    elements.questionSourceContent.replaceChildren();
    const status = question.verification.status;
    const statusPill = document.createElement('span');
    statusPill.className = `status-pill${status === 'local-source-needed' ? ' needs-review' : ''}`;
    statusPill.textContent = STATUS_LABELS[status] || 'Thông tin nguồn';
    const note = document.createElement('p');
    note.textContent = question.verification.note;
    elements.questionSourceContent.append(statusPill, note);
    const sources = question.verification.sourceIds.map((id) => sourceMap.get(id)).filter(Boolean);
    if (sources.length) {
      const list = document.createElement('ul');
      sources.forEach((source) => {
        const item = document.createElement('li');
        if (isSafeUrl(source.url)) {
          const link = document.createElement('a');
          link.href = source.url;
          link.target = '_blank';
          link.rel = 'noopener noreferrer';
          link.textContent = source.title;
          item.append(link);
        } else {
          item.textContent = source.title;
        }
        list.append(item);
      });
      elements.questionSourceContent.append(list);
    }
  }

  function moveQuestion(direction) {
    if (!session) return;
    const nextIndex = session.index + direction;
    if (nextIndex < 0) return;
    if (nextIndex >= session.queue.length) {
      state.lastSession = null;
      saveState();
      showEmpty('Rất tốt! Cô đã đi hết các câu trong lượt ôn này.');
      return;
    }
    session.index = nextIndex;
    renderQuestion();
  }

  function showPractice() {
    elements.homeView.classList.add('is-hidden');
    elements.emptyView.classList.add('is-hidden');
    elements.practiceView.classList.remove('is-hidden');
  }

  function showHome() {
    elements.practiceView.classList.add('is-hidden');
    elements.emptyView.classList.add('is-hidden');
    elements.homeView.classList.remove('is-hidden');
    renderHome();
    window.scrollTo({ top: 0, behavior: 'smooth' });
  }

  function leavePractice() {
    if (location.hash === '#study') history.back();
    else showHome();
  }

  function showEmpty(message) {
    elements.homeView.classList.add('is-hidden');
    elements.practiceView.classList.add('is-hidden');
    elements.emptyView.classList.remove('is-hidden');
    elements.emptyText.textContent = message;
    if (location.hash !== '#study') history.pushState({ study: true }, '', '#study');
  }

  function renderHome() {
    if (!bank) return;
    const mcqDone = Object.keys(state.mcq).length;
    const oralDone = Object.keys(state.oral).length;
    const wrong = Object.values(state.mcq).filter((result) => !result.correct).length;
    const oralReview = Object.values(state.oral).filter((result) => result.rating === 'review').length;
    elements.mcqProgressText.textContent = `${mcqDone} / ${bank.stats.multipleChoice}`;
    elements.oralProgressText.textContent = `${oralDone} / ${bank.stats.oral}`;
    elements.todayCount.textContent = `${state.daily.ids.length} câu`;
    elements.wrongCount.textContent = wrong;
    elements.oralReviewCount.textContent = oralReview;
    elements.reviewWrongButton.disabled = wrong === 0;
    elements.reviewOralButton.disabled = oralReview === 0;
    elements.resumeButton.classList.toggle('is-hidden', !canResume());
  }

  function canResume() {
    if (!state.lastSession || !bank || !Array.isArray(state.lastSession.queueIds)) return false;
    const validIds = new Set(questionsForMode(state.lastSession.mode).map((question) => question.id));
    return state.lastSession.queueIds.some((id) => validIds.has(id));
  }

  function recordDaily(id) {
    if (state.daily.date !== todayKey()) state.daily = { date: todayKey(), ids: [] };
    if (!state.daily.ids.includes(id)) state.daily.ids.push(id);
  }

  function renderSourceDialog() {
    elements.sourceList.replaceChildren();
    bank.sources.forEach((source) => {
      const item = document.createElement('article');
      item.className = 'source-item';
      const title = document.createElement('strong');
      if (isSafeUrl(source.url)) {
        const link = document.createElement('a');
        link.href = source.url;
        link.target = '_blank';
        link.rel = 'noopener noreferrer';
        link.textContent = source.title;
        title.append(link);
      } else {
        title.textContent = source.title;
      }
      const note = document.createElement('span');
      note.textContent = source.note;
      item.append(title, note);
      elements.sourceList.append(item);
    });
  }

  function applyFontScale(scale, persist = false) {
    const safeScale = [0.95, 1.08, 1.2].includes(scale) ? scale : 1.08;
    document.documentElement.style.setProperty('--font-scale', safeScale);
    document.querySelectorAll('[data-font]').forEach((button) => {
      button.classList.toggle('is-selected', Number(button.dataset.font) === safeScale);
    });
    if (persist) {
      state.preferences.fontScale = safeScale;
      saveState();
      showToast('Đã đổi cỡ chữ.');
    }
  }

  function resetProgress() {
    if (!window.confirm('Xóa toàn bộ tiến độ đã học trên thiết bị này? Thao tác này không thể hoàn tác.')) return;
    state = defaultState();
    session = null;
    saveState();
    applyFontScale(state.preferences.fontScale);
    elements.settingsDialog.close();
    showHome();
    showToast('Đã xóa tiến độ trên thiết bị này.');
  }

  function restoreFromAddress() {
    if (location.hash === '#study' && canResume()) resumeLastSession();
    else if (location.hash === '#study') history.replaceState(null, '', location.pathname);
  }

  function friendlySection(label) {
    return String(label || '')
      .toLocaleLowerCase('vi')
      .replace(/^công tác\s+/, 'Công tác ')
      .replace(/^([a-zà-ỹ])/, (letter) => letter.toLocaleUpperCase('vi'));
  }

  function shuffled(items) {
    const copy = [...items];
    for (let index = copy.length - 1; index > 0; index -= 1) {
      const other = Math.floor(Math.random() * (index + 1));
      [copy[index], copy[other]] = [copy[other], copy[index]];
    }
    return copy;
  }

  function isSafeUrl(url) {
    if (!url) return false;
    try { return new URL(url).protocol === 'https:'; } catch { return false; }
  }

  function showToast(message) {
    clearTimeout(toastTimer);
    elements.toast.textContent = message;
    elements.toast.classList.remove('is-hidden');
    toastTimer = setTimeout(() => elements.toast.classList.add('is-hidden'), 2600);
  }

  function registerServiceWorker() {
    if ('serviceWorker' in navigator && location.protocol === 'https:') {
      navigator.serviceWorker.register('/service-worker.js').catch(() => {});
    }
  }

  document.addEventListener('DOMContentLoaded', init);
})();
