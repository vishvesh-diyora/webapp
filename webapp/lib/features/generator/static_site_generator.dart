import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:webapp/core/services/image_asset_service.dart';
import 'package:webapp/features/website/domain/entities/website_document.dart';

class PublishResult {
  const PublishResult({
    required this.outputPath,
    required this.zipPath,
  });

  final String outputPath;
  final String zipPath;
}

/// Generates static website files from [WebsiteDocument].
class StaticSiteGenerator {
  const StaticSiteGenerator();

  Future<PublishResult> generate({
    required WebsiteDocument document,
    required String outputDirectory,
  }) async {
    final siteDir = Directory(outputDirectory);
    if (siteDir.existsSync()) {
      await siteDir.delete(recursive: true);
    }
    await siteDir.create(recursive: true);

    final assetsDir = Directory(p.join(outputDirectory, 'assets', 'images'));
    await assetsDir.create(recursive: true);

    final publishedJson = document.toPublishedJson();
    await ImageAssetService.copyDocumentImagesToPublishDir(
      publishedJson,
      assetsDir.path,
    );
    await _writePlaceholderImages(assetsDir.path);
    await File(p.join(outputDirectory, 'content.json')).writeAsString(
      const JsonEncoder.withIndent('  ').convert(publishedJson),
    );
    await File(p.join(outputDirectory, 'index.html')).writeAsString(_html(document));
    await File(p.join(outputDirectory, 'style.css')).writeAsString(_css(document));
    await File(p.join(outputDirectory, 'script.js')).writeAsString(_js(document));

    final zipPath = p.join(p.dirname(outputDirectory), '${_slug(document.name)}.zip');
    await _zipDirectory(outputDirectory, zipPath);

    return PublishResult(outputPath: outputDirectory, zipPath: zipPath);
  }

  Future<void> _writePlaceholderImages(String dir) async {
    const files = [
      'logo.png',
      'profile.jpg',
      'banner-1.jpg',
      'banner-2.jpg',
      'product-1.jpg',
      'product-2.jpg',
      'product-3.jpg',
      'gallery-1.jpg',
      'gallery-2.jpg',
      'menu-1.jpg',
      'menu-2.jpg',
      'menu-3.jpg',
      'reveal-1.jpg',
      'reveal-2.jpg',
      'gift-cover.jpg',
      'project-1.jpg',
      'team-1.jpg',
    ];
    final png = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
    );
    for (final file in files) {
      final target = File(p.join(dir, file));
      if (!target.existsSync()) {
        await target.writeAsBytes(png);
      }
    }
  }

  Future<void> _zipDirectory(String sourceDir, String zipPath) async {
    final archive = Archive();
    final dir = Directory(sourceDir);
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is! File) continue;
      final relative = p.relative(entity.path, from: sourceDir);
      final bytes = await entity.readAsBytes();
      archive.addFile(ArchiveFile(relative, bytes.length, bytes));
    }
    final zipBytes = ZipEncoder().encode(archive);
    await File(zipPath).writeAsBytes(zipBytes);
  }

  String _slug(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '-').replaceAll(RegExp(r'^-|-$'), '');

  String _html(WebsiteDocument document) => '''<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>${_escape(document.name)}</title>
  <link rel="stylesheet" href="style.css" />
</head>
<body data-type="${document.type}" data-template="${document.templateType}" class="template-${document.templateType} layout-${_layoutClass(document)}">
  <nav id="site-nav"></nav>
  <div id="app"></div>
  <footer id="site-footer"></footer>
  <script src="script.js"></script>
</body>
</html>''';

  String _css(WebsiteDocument document) {
    final primary = _theme(document, 'primary', '#6366F1');
    final background = _theme(document, 'background', '#ffffff');
    final text = _theme(document, 'text', '#0f172a');
    final secondary = _theme(document, 'secondary', '#111827');
    final accent = _theme(document, 'accent', '#8B5CF6');
    return '''
:root {
  --primary: $primary;
  --secondary: $secondary;
  --accent: $accent;
  --background: $background;
  --text: $text;
}
* { box-sizing: border-box; }
body {
  margin: 0;
  font-family: Inter, system-ui, sans-serif;
  background: var(--background);
  color: var(--text);
}
.nav { display:flex; gap:12px; padding:12px 16px; background:var(--surface,#f8fafc); align-items:center; }
.nav-brand { font-weight:700; }
.hero { padding: 48px 20px; background: linear-gradient(135deg, var(--primary), var(--secondary)); color: #fff; }
.hero.split { background: var(--background); color: var(--text); }
.hero img { max-width: 72px; border-radius: 12px; margin-bottom: 12px; }
.grid { display: grid; gap: 16px; padding: 20px; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); }
.card { background: #fff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 16px; overflow: hidden; }
.card img { width: 100%; height: 140px; object-fit: cover; border-radius: 8px; margin-bottom: 10px; }
.section { padding: 20px; }
.footer { padding: 20px; background: var(--secondary); color: #fff; }
.cart-bar { position: fixed; bottom: 0; left: 0; right: 0; background: #111827; color: #fff; padding: 12px 16px; display: flex; justify-content: space-between; align-items: center; z-index: 20; }
button, .btn { border: 0; border-radius: 999px; padding: 10px 16px; cursor: pointer; background: var(--primary); color: #fff; text-decoration: none; display: inline-block; }
.countdown { font-size: 28px; font-weight: 700; text-align: center; padding: 16px; background: rgba(99,102,241,0.12); border-radius: 12px; margin: 16px 0; }
.message { padding: 14px; border: 1px solid #e2e8f0; border-radius: 12px; margin-bottom: 10px; opacity: 0; transform: translateY(8px); transition: all 0.4s ease; }
.message.visible { opacity: 1; transform: translateY(0); }
.map { width: 100%; height: 220px; border: 0; border-radius: 12px; }
.confetti { position: fixed; inset: 0; pointer-events: none; overflow: hidden; }
.confetti span { position: absolute; width: 8px; height: 12px; animation: fall 3s linear infinite; }
@keyframes fall { from { transform: translateY(-10vh) rotate(0deg); } to { transform: translateY(110vh) rotate(360deg); } }
''';
  }

  String _js(WebsiteDocument document) {
    return '''
let content = {};
const cartKey = 'website_cart';

async function boot() {
  const res = await fetch('content.json');
  content = await res.json();
  renderNav();
  render();
  renderFooterBlock();
  if (content.type === 3) initGiftReveal();
  if (content.type === 5 || content.type === 4) renderCartBar();
}

function themeBlock() {
  return block(1).theme || {};
}

function renderNav() {
  const nav = document.getElementById('site-nav');
  if (!nav) return;
  const style = themeBlock().navStyle || 'top';
  nav.className = 'nav nav-' + style;
  nav.innerHTML = '<span class="nav-brand">' + esc(content.name) + '</span><span>About</span><span>Work</span><span>Contact</span>';
}

function renderFooterBlock() {
  const footer = document.getElementById('site-footer');
  if (!footer) return;
  const primary = block(1);
  const phone = primary.phone || primary.whatsapp || primary.email || '';
  if (!phone) { footer.innerHTML = ''; return; }
  footer.className = 'footer footer-' + (themeBlock().footerStyle || 'minimal');
  footer.innerHTML = '<span>Contact: ' + esc(phone) + '</span>';
}

function block(type) {
  return (content.data || []).find(item => item.contentType === type)?.contentData || {};
}

function img(path, alt) {
  if (!path) return '';
  return `<img src="\${esc(path)}" alt="\${esc(alt || '')}" loading="lazy" />`;
}

function render() {
  const app = document.getElementById('app');
  const primary = block(1);
  const secondary = block(2);
  const tertiary = block(3);
  const type = content.type;
  app.innerHTML = [
    renderHero(primary, type),
    renderMap(primary),
    renderResume(primary, type),
    renderSection(sectionTitle(type, 2), renderSecondary(secondary, type)),
    renderTeam(secondary, type),
    renderAchievements(secondary, type),
    renderSection(sectionTitle(type, 3), renderTertiary(tertiary, type)),
    renderFooter(primary)
  ].join('');
  bindCartButtons();
}

function sectionTitle(type, section) {
  const map = {
    2: { 2: 'Services', 3: 'Messages', 4: 'Offers', 5: 'Categories' },
    3: { 2: 'About', 3: 'Reveal', 4: 'Menu Categories', 5: 'Products' }
  };
  return (map[section] && map[section][type]) || ('Section ' + section);
}

function renderHero(data, type) {
  const title = data.businessName || data.storeName || data.restaurantName || data.title || data.name || content.name;
  const subtitle = data.tagline || data.subtitle || content.subname;
  const logo = content.logo || data.logo || '';
  const heroStyle = (data.theme && data.theme.heroStyle) || 'left';
  const cls = heroStyle === 'fullBleed' || heroStyle === 'bold' ? 'hero' : 'hero split';
  return `<section class="\${cls}">\${logo ? img(logo, title) : ''}<h1>\${esc(title)}</h1><p>\${esc(subtitle || content.description)}</p></section>`;
}

function renderResume(data, type) {
  if (type !== 1) return '';
  const url = data.resumeUrl || '';
  if (!url) return '';
  return `<section class="section"><a class="btn" href="\${esc(url)}" download>Download Resume</a></section>`;
}

function renderTeam(data, type) {
  if (type !== 2) return '';
  const team = data.team || [];
  if (!team.length) return '';
  return `<section class="section"><h2>Team</h2><div class="grid">\${team.map(m => `<article class="card">\${m.image ? img(m.image, m.name) : ''}<h3>\${esc(m.name || '')}</h3><p>\${esc(m.role || '')}</p></article>`).join('')}</div></section>`;
}

function renderAchievements(data, type) {
  if (type !== 2) return '';
  const items = data.achievements || [];
  if (!items.length) return '';
  return `<section class="section"><h2>Achievements</h2><div class="grid">\${items.map(a => `<article class="card"><h3>\${esc(a.title || '')}</h3><p>\${esc(a.value || '')}</p></article>`).join('')}</div></section>`;
}

function renderMap(data) {
  const embed = data.mapEmbed || data.mapUrl || '';
  if (!embed) return '';
  if (embed.includes('<iframe')) return `<section class="section">\${embed}</section>`;
  return `<section class="section"><iframe class="map" src="\${esc(embed)}" loading="lazy"></iframe></section>`;
}

function renderSecondary(data, type) {
  const items = data.services || data.categories || data.messages || data.offers || data.banners || [];
  if (!items.length) return `<p>\${esc(data.about || '')}</p>`;
  return `<div class="grid">\${items.map(item => `<article class="card">\${item.image ? img(item.image, item.title || item.name) : ''}<h3>\${esc(item.title || item.name || item.text || '')}</h3><p>\${esc(item.description || item.role || '')}</p></article>`).join('')}</div>`;
}

function renderTertiary(data, type) {
  const items = data.products || data.menuItems || data.projects || data.gallery || data.branches || [];
  if (!items.length) return `<p>\${esc(data.finalMessage || '')}</p>`;
  return `<div class="grid">\${items.map(item => {
    const price = item.price != null ? `\$` + item.price : '';
    const id = esc(item.name || item.title || '');
    const cartBtn = (type === 5 || type === 4) ? `<button data-cart="\${id}" data-price="\${item.price || 0}">Add</button>` : '';
    return `<article class="card">\${item.image ? img(item.image, id) : ''}<h3>\${id}</h3><p>\${esc(item.description || item.category || '')}</p><strong>\${price}</strong> \${cartBtn}</article>`;
  }).join('')}</div>`;
}

function renderFooter(data) {
  const phone = data.phone || data.whatsapp || '';
  if (!phone) return '';
  return `<footer class="footer">Contact: \${esc(phone)}</footer>`;
}

function renderSection(title, html) {
  return `<section class="section"><h2>\${esc(title)}</h2>\${html}</section>`;
}

function initGiftReveal() {
  const primary = block(1);
  const secondary = block(2);
  const tertiary = block(3);
  const music = secondary.musicUrl || '';
  if (music) {
    const audio = document.createElement('audio');
    audio.src = music;
    audio.autoplay = true;
    audio.loop = true;
    document.body.appendChild(audio);
  }
  const revealImages = primary.revealImages || [];
  if (revealImages.length) {
    const gallery = document.createElement('section');
    gallery.className = 'section';
    gallery.innerHTML = '<div class="grid">' + revealImages.map(p => `<article class="card">\${img(p, 'Reveal')}</article>`).join('') + '</div>';
    document.getElementById('app').appendChild(gallery);
  }
  const seconds = Number(secondary.countdownSeconds || 10);
  let left = seconds;
  const countdownEl = document.createElement('div');
  countdownEl.className = 'countdown';
  countdownEl.textContent = 'Reveal in ' + left;
  const app = document.getElementById('app');
  app.insertAdjacentElement('afterbegin', countdownEl);
  const timer = setInterval(() => {
    left -= 1;
    if (left <= 0) {
      clearInterval(timer);
      countdownEl.textContent = tertiary.finalMessage || 'Happy surprise!';
      spawnConfetti();
    } else {
      countdownEl.textContent = 'Reveal in ' + left;
    }
  }, 1000);
  const messages = secondary.messages || [];
  messages.forEach((msg, i) => {
    setTimeout(() => {
      const el = document.createElement('div');
      el.className = 'message visible';
      el.textContent = msg.text || '';
      app.appendChild(el);
    }, Number(msg.delayMs || i * 1000));
  });
}

function spawnConfetti() {
  const layer = document.createElement('div');
  layer.className = 'confetti';
  for (let i = 0; i < 36; i++) {
    const piece = document.createElement('span');
    piece.style.left = Math.random() * 100 + '%';
    piece.style.background = ['#6366F1','#EC4899','#F59E0B','#10B981'][i % 4];
    piece.style.animationDelay = (Math.random() * 2) + 's';
    layer.appendChild(piece);
  }
  document.body.appendChild(layer);
  setTimeout(() => layer.remove(), 5000);
}

function bindCartButtons() {
  document.querySelectorAll('[data-cart]').forEach(btn => {
    btn.addEventListener('click', () => addToCart(btn.dataset.cart, Number(btn.dataset.price || 0)));
  });
}

function getCart() {
  try { return JSON.parse(localStorage.getItem(cartKey) || '{}'); } catch { return {}; }
}

function addToCart(name, price) {
  const cart = getCart();
  cart[name] = cart[name] || { name, price, qty: 0 };
  cart[name].qty += 1;
  localStorage.setItem(cartKey, JSON.stringify(cart));
  renderCartBar();
}

function renderCartBar() {
  let bar = document.getElementById('cart-bar');
  if (!bar) {
    bar = document.createElement('div');
    bar.id = 'cart-bar';
    bar.className = 'cart-bar';
    document.body.appendChild(bar);
  }
  const cart = getCart();
  const items = Object.values(cart);
  const total = items.reduce((sum, item) => sum + item.price * item.qty, 0);
  const whatsapp = block(1).whatsapp || block(1).phone || '';
  const message = encodeURIComponent(items.map(i => `\${i.name} x\${i.qty}`).join('\\n') + `\\nTotal: \$\${total.toFixed(2)}`);
  bar.innerHTML = `<span>\${items.length ? `\${items.length} item(s) · \$\${total.toFixed(2)}` : 'Cart empty'}</span>` +
    (whatsapp && items.length ? `<a class="btn" href="https://wa.me/\${whatsapp.replace(/\\D/g,'')}?text=\${message}">WhatsApp Checkout</a>` : '');
}

function esc(value) {
  return String(value || '').replace(/[&<>"]/g, s => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[s]));
}

boot();
''';
  }

  String _theme(WebsiteDocument document, String key, String fallback) {
    final theme = document.blockByContentType(1)?.contentData['theme'];
    if (theme is Map && theme[key] is String) return theme[key] as String;
    return fallback;
  }

  String _layoutClass(WebsiteDocument document) {
    final theme = document.blockByContentType(1)?.contentData['theme'];
    if (theme is Map && theme['layout'] is String) return theme['layout'] as String;
    return 'split';
  }

  String _escape(String value) =>
      value.replaceAll('&', '&amp;').replaceAll('<', '&lt;').replaceAll('>', '&gt;');
}
