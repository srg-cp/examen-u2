const labels = {
  dog: 'Perro', cat: 'Gato', other: 'Otra especie', small: 'Pequeño', medium: 'Mediano', large: 'Grande', male: 'Macho', female: 'Hembra',
};
const dateLabel = (value) => new Intl.DateTimeFormat('es-PE', { dateStyle: 'long' }).format(new Date(value));

export class ReaderView {
  constructor(model, document, navigator) {
    Object.assign(this, { model, document, navigator });
    this.root = document.querySelector('#view'); this.notice = document.querySelector('#notice');
    this.skeleton = this.root.firstElementChild.cloneNode(true);
  }
  node(tag, className, text) {
    const element = this.document.createElement(tag);
    if (className) element.className = className;
    if (text != null) element.textContent = text;
    return element;
  }
  button(text, onClick, className = 'secondary') {
    const button = this.node('button', className, text); button.type = 'button'; button.addEventListener('click', onClick); return button;
  }
  mount(slug) {
    this.slug = slug;
    this.document.querySelector('#notice-close').onclick = () => this.hideNotice();
    this.unsubscribe = this.model.subscribe((state) => this.render(state));
    this.model.load(slug);
  }
  showNotice(message, retry, error = true) {
    clearTimeout(this.noticeTimer);
    this.document.querySelector('#notice-message').textContent = message;
    const action = this.document.querySelector('#notice-retry'); action.hidden = !retry; action.onclick = retry || null;
    this.notice.setAttribute('role', error ? 'alert' : 'status'); this.notice.hidden = false;
    this.noticeTimer = setTimeout(() => this.hideNotice(), 6500);
  }
  hideNotice() { this.notice.hidden = true; clearTimeout(this.noticeTimer); }
  render(state) {
    this.root.classList.toggle('refreshing', state.refreshing);
    this.root.setAttribute('aria-busy', String(state.phase === 'loading' || state.refreshing));
    if (state.notice && state.noticeId !== this.noticeId) {
      this.noticeId = state.noticeId;
      this.showNotice(state.notice === 'rate_limited' ? 'Espera un momento antes de volver a consultar.' : 'No pudimos actualizar el caso.', () => this.model.load(this.slug));
    }
    if (this.refreshButton) {
      this.refreshButton.disabled = state.refreshing; this.refreshButton.classList.toggle('working', state.refreshing);
      this.refreshButton.setAttribute('aria-busy', String(state.refreshing));
    }
    if (state.value === this.presented && state.phase === this.phase) return;
    const animate = this.phase !== state.phase;
    this.presented = state.value; this.phase = state.phase;
    if (state.phase === 'loading') { this.root.replaceChildren(this.skeleton.cloneNode(true)); return; }
    if (state.phase === 'active') { this.renderCase(state.value, animate); return; }
    const section = this.node('section', `neutral${animate ? ' reveal' : ''}`);
    section.append(this.node('p', 'eyebrow', 'Entre Huellas'));
    if (state.phase === 'closed') {
      section.append(this.node('h1', '', 'Este caso ya fue cerrado'), this.node('p', 'description', 'La búsqueda ya no está activa y no admite nuevos avistamientos.'));
      if (state.value.closedAt) section.append(this.node('p', 'muted', `Cierre registrado el ${dateLabel(state.value.closedAt)}.`));
    } else if (state.phase === 'error') {
      section.append(this.node('h1', '', 'Consulta el caso'), this.button('Reintentar', () => this.model.load(this.slug), 'primary'));
    } else {
      section.append(this.node('h1', '', 'Este enlace no está disponible'), this.node('p', 'description', 'No hay información del caso para mostrar desde este enlace.'));
    }
    this.root.replaceChildren(section);
  }
  renderCase(value, animate) {
    const section = this.node('article', `case${animate ? ' reveal' : ''}`);
    const header = this.node('div', 'case-heading');
    header.append(this.node('p', 'eyebrow', value.kind === 'lost' ? 'Ayudemos a que vuelva a casa' : 'Una mascota espera reencontrarse'));
    const title = value.name || (value.kind === 'lost' ? 'Mascota perdida' : 'Mascota encontrada');
    header.append(this.node('h1', '', title));
    const chips = this.node('div', 'chips');
    chips.append(this.node('span', 'chip active', 'Caso abierto'), this.node('span', 'chip', value.species === 'other' && value.speciesDetail ? value.speciesDetail : labels[value.species]));
    if (value.size) chips.append(this.node('span', 'chip', labels[value.size]));
    if (value.sex) chips.append(this.node('span', 'chip', labels[value.sex]));
    header.append(chips); section.append(header);

    const gallery = this.node('section', 'gallery'); gallery.setAttribute('aria-label', 'Fotos de la mascota');
    const image = this.node('img', 'pet-photo'); image.width = 720; image.height = 720; image.decoding = 'async'; image.alt = `Foto de ${title}`;
    let index = 0;
    const counter = this.node('span', 'photo-count'); counter.setAttribute('aria-live', 'polite');
    const update = () => {
      image.classList.remove('photo-failed'); image.src = `/api/c/${this.slug}/photos/${index}?v=${value.revision}`;
      counter.textContent = `${index + 1} / ${value.photoCount}`;
      previous.disabled = index === 0; next.disabled = index === value.photoCount - 1;
    };
    const previous = this.button('‹', () => { index--; update(); }, 'glass photo-previous'); previous.setAttribute('aria-label', 'Foto anterior');
    const next = this.button('›', () => { index++; update(); }, 'glass photo-next'); next.setAttribute('aria-label', 'Foto siguiente');
    image.onerror = () => {
      image.classList.add('photo-failed');
      this.showNotice('No se pudo mostrar la foto.', () => { image.src = `/api/c/${this.slug}/photos/${index}?v=${value.revision}&retry=${Date.now()}`; this.model.load(this.slug); });
      this.model.load(this.slug);
    };
    gallery.append(image);
    if (value.photoCount > 1) gallery.append(previous, next, counter);
    update(); section.append(gallery);

    const details = this.node('div', 'details');
    details.append(this.node('p', 'eyebrow', 'Cada detalle ayuda'), this.node('h2', '', 'Cómo reconocerle'), this.node('p', 'traits', value.traits));
    const area = this.node('section', 'area');
    area.append(this.node('h2', '', value.kind === 'lost' ? 'Última ubicación conocida' : 'Área del encuentro'),
      this.node('p', 'muted', `${dateLabel(value.occurredAt)} · Referencia aproximada`),
      this.node('p', 'privacy', 'Esta referencia indica el área del caso. No muestra una dirección ni el punto exacto.'));
    const link = this.node('a', 'secondary area-link', 'Ver área aproximada');
    link.href = `https://www.google.com/maps/search/?api=1&query=${value.area.latitude},${value.area.longitude}`;
    link.target = '_blank'; link.rel = 'noopener noreferrer'; area.append(link); details.append(area);
    const collaborate = this.node('section', 'collaborate');
    collaborate.append(this.node('h2', '', 'Ayuda a que alguien le reconozca'), this.node('p', 'muted', 'Compartir esta ficha puede acercar el reencuentro.'));
    const actions = this.node('div', 'actions');
    actions.append(this.button('Compartir caso', () => this.share(title), 'primary'), this.button('Copiar enlace', () => this.copy()));
    collaborate.append(actions); details.append(collaborate);
    this.refreshButton = this.button('Actualizar estado', () => this.model.load(this.slug), 'text-button');
    details.append(this.refreshButton); section.append(details); this.root.replaceChildren(section);
  }
  url() { return new URL(`/c/${this.slug}`, this.document.location.origin).href; }
  async copy() {
    try { await this.navigator.clipboard.writeText(this.url()); this.showNotice('Enlace copiado', null, false); }
    catch { this.showNotice('No se pudo copiar. Puedes compartir el enlace desde tu navegador.'); }
  }
  async share(title) {
    if (!this.navigator.share) { await this.copy(); return; }
    try { await this.navigator.share({ title: `${title} · Entre Huellas`, url: this.url() }); }
    catch (error) { if (error.name !== 'AbortError') this.showNotice('No se pudo compartir. Intenta copiar el enlace.'); }
  }
  dispose() { this.unsubscribe?.(); this.hideNotice(); }
}
