import { ReadCase } from '/client/domain/read_case.mjs';
import { HttpCaseRepository } from '/client/data/http_case_repository.mjs';
import { ReaderViewModel } from '/client/presentation/reader_view_model.mjs';
import { ReaderView } from '/client/presentation/reader_view.mjs';

const model = new ReaderViewModel(new ReadCase(new HttpCaseRepository()));
const view = new ReaderView(model, document, navigator);
const slug = /^\/c\/([0-9a-f]{64})\/?$/.exec(location.pathname)?.[1] || '';
view.mount(slug);
const refresh = () => { if (!document.hidden) model.load(slug); };
document.addEventListener('visibilitychange', refresh);
const timer = setInterval(refresh, 60000);
window.addEventListener('pagehide', () => { clearInterval(timer); document.removeEventListener('visibilitychange', refresh); view.dispose(); model.dispose(); }, { once: true });
window.addEventListener('pageshow', (event) => { if (event.persisted) location.reload(); });
