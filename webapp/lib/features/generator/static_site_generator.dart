import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:webapp/features/generator/generated_site_bundle.dart';
import 'package:webapp/features/generator/publish_image_collector.dart';
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
    final bundle = await buildSiteFiles(document);

    final siteDir = Directory(outputDirectory);
    if (siteDir.existsSync()) {
      await siteDir.delete(recursive: true);
    }
    await siteDir.create(recursive: true);

    for (final entry in bundle.files.entries) {
      final target = File(p.join(outputDirectory, entry.key));
      await target.parent.create(recursive: true);
      await target.writeAsBytes(entry.value);
    }

    final zipPath = p.join(p.dirname(outputDirectory), '${_slug(document.name)}.zip');
    await _zipDirectory(outputDirectory, zipPath);

    return PublishResult(outputPath: outputDirectory, zipPath: zipPath);
  }

  /// Builds static site files in memory (works on web and native).
  Future<GeneratedSiteBundle> buildSiteFiles(WebsiteDocument document) async {
    final publishedJson = document.toPublishedJson();
    final files = <String, List<int>>{
      'index.html': utf8.encode(_html(document)),
      'style.css': utf8.encode(_css(document)),
      'script.js': utf8.encode(_js(document)),
    };

    files.addAll(await collectPublishImages(publishedJson));
    _addPlaceholderImages(files);

    return GeneratedSiteBundle(files: files);
  }

  void _addPlaceholderImages(Map<String, List<int>> files) {
    const placeholders = [
      'assets/images/logo.png',
      'assets/images/profile.jpg',
      'assets/images/banner-1.jpg',
      'assets/images/banner-2.jpg',
      'assets/images/product-1.jpg',
      'assets/images/product-2.jpg',
      'assets/images/product-3.jpg',
      'assets/images/gallery-1.jpg',
      'assets/images/gallery-2.jpg',
      'assets/images/menu-1.jpg',
      'assets/images/menu-2.jpg',
      'assets/images/menu-3.jpg',
      'assets/images/reveal-1.jpg',
      'assets/images/reveal-2.jpg',
      'assets/images/gift-cover.jpg',
      'assets/images/project-1.jpg',
      'assets/images/team-1.jpg',
    ];
    final png = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==',
    );
    for (final path in placeholders) {
      files.putIfAbsent(path, () => png);
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
.grid-products { gap: 12px; padding: 16px; grid-template-columns: repeat(auto-fill, minmax(min(100%, 148px), 1fr)); }
.card { background: #fff; border: 1px solid #e2e8f0; border-radius: 12px; padding: 16px; overflow: hidden; }
.grid-products .card { border-radius: 8px; padding: 10px; }
.card-img-wrap { position: relative; width: 100%; aspect-ratio: 1 / 1.2; border-radius: 10px; overflow: hidden; margin-bottom: 8px; }
.card-img-wrap img { width: 100%; height: 100%; object-fit: cover; border-radius: 0; margin-bottom: 0; display: block; }
.badge-bestseller {
  position: absolute; top: 8px; left: 8px; z-index: 1;
  padding: 4px 8px; border-radius: 6px; font-size: 10px; font-weight: 700; color: #fff; letter-spacing: 0.02em;
  background: linear-gradient(135deg, var(--primary), var(--accent));
  box-shadow: 0 2px 8px rgba(99, 102, 241, 0.35);
}
.price-row { display: flex; flex-wrap: wrap; align-items: baseline; gap: 6px; margin-top: 4px; }
.price-sale { color: var(--primary); font-weight: 700; }
.price-compare { color: rgba(15, 23, 42, 0.45); text-decoration: line-through; font-size: 0.9em; }
.card img { width: 100%; height: 140px; object-fit: cover; border-radius: 8px; margin-bottom: 10px; }
.section { padding: 20px; }
.footer { padding: 20px; background: var(--secondary); color: #fff; }
.footer-store { background: #f8fafc; color: var(--text); border-top: 1px solid #e2e8f0; }
.footer-store .footer-line { margin: 0 0 10px; font-size: 14px; line-height: 1.5; }
.footer-store .footer-line a { color: var(--primary); text-decoration: none; }
.footer-social { display: flex; flex-wrap: wrap; gap: 10px; margin-top: 12px; }
.footer-social a {
  display: inline-flex; align-items: center; justify-content: center;
  width: 40px; height: 40px; border-radius: 50%;
  background: color-mix(in srgb, var(--primary) 12%, transparent);
  color: var(--primary); font-size: 12px; font-weight: 600; text-decoration: none;
}
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
    final embedded = jsonEncode(document.toPublishedJson());
    return '''
let content = $embedded;
const cartKey = 'website_cart';

function boot() {
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
  const html = contactFooterInnerHtml(primary);
  if (!html) { footer.innerHTML = ''; return; }
  footer.className = 'footer footer-store footer-' + (themeBlock().footerStyle || 'minimal');
  footer.innerHTML = html;
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
  const gridClass = (type === 5 || type === 4) ? 'grid grid-products' : 'grid';
  return `<div class="\${gridClass}">\${items.map(item => {
    const pricing = catalogItemPricing(item);
    const priceHtml = pricing.sale != null
      ? `<div class="price-row"><span class="price-sale">\${pricing.sale}</span>\${pricing.compare ? `<span class="price-compare">\${pricing.compare}</span>` : ''}</div>`
      : '';
    const id = esc(item.name || item.title || '');
    const cartBtn = (type === 5 || type === 4) ? `<button data-cart="\${id}" data-price="\${pricing.saleValue || 0}">Add</button>` : '';
    const isCatalog = type === 5 || type === 4;
    const best = item.bestSeller || item.bestseller || item.isBestSeller;
    const badge = isCatalog && best ? '<span class="badge-bestseller">Best seller</span>' : '';
    const media = item.image
      ? (isCatalog
        ? `<div class="card-img-wrap">\${badge}\${img(item.image, id)}</div>`
        : img(item.image, id))
      : (isCatalog && badge ? `<div class="card-img-wrap">\${badge}</div>` : '');
    return `<article class="card">\${media}<h3>\${id}</h3><p>\${esc(item.description || item.category || '')}</p>\${priceHtml} \${cartBtn}</article>`;
  }).join('')}</div>`;
}

function catalogItemPricing(item) {
  const listed = Number(item.price) || 0;
  const discount = Number(item.discount) || 0;
  const explicit = Number(item.originalPrice || item.compareAtPrice || item.mrp) || 0;
  let saleValue = listed;
  let compareValue = null;
  if (discount > 0 && listed > 0) {
    saleValue = listed * (1 - discount / 100);
    compareValue = listed;
  } else if (explicit > listed && listed > 0) {
    saleValue = listed;
    compareValue = explicit;
  }
  const fmt = (n) => {
    if (!n) return null;
    const r = Math.round(n * 100) / 100;
    return r % 1 === 0 ? '\$' + r : '\$' + r.toFixed(2);
  };
  return {
    sale: fmt(saleValue),
    compare: compareValue && compareValue > saleValue + 0.009 ? fmt(compareValue) : null,
    saleValue,
  };
}

function contactFooterInnerHtml(data) {
  const phone = String(data.phone || '').trim() || String(data.whatsapp || '').trim();
  const email = String(data.email || '').trim();
  const address = String(data.address || '').trim();
  const social = Array.isArray(data.socialLinks) ? data.socialLinks : [];
  if (!phone && !email && !address && !social.length) return '';

  const lines = [];
  if (phone) {
    const digits = phone.replace(/\\D/g, '');
    const tel = digits ? `<a href="tel:\${digits}">\${esc(phone)}</a>` : esc(phone);
    lines.push(`<p class="footer-line">\${tel}</p>`);
  }
  if (email) {
    lines.push(`<p class="footer-line"><a href="mailto:\${esc(email)}">\${esc(email)}</a></p>`);
  }
  if (address) {
    lines.push(`<p class="footer-line">\${esc(address)}</p>`);
  }
  if (social.length) {
    const links = social.map(item => {
      const url = esc(String(item.url || '').trim());
      if (!url) return '';
      const label = esc(String(item.platform || item.icon || 'Link').trim()).slice(0, 2).toUpperCase();
      return `<a href="\${url}" target="_blank" rel="noopener noreferrer">\${label}</a>`;
    }).filter(Boolean).join('');
    if (links) lines.push(`<div class="footer-social">\${links}</div>`);
  }
  return lines.join('');
}

function renderFooter(data) {
  const html = contactFooterInnerHtml(data);
  if (!html) return '';
  return `<footer class="footer footer-store">\${html}</footer>`;
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
  if (!items.length) {
    bar.style.display = 'none';
    return;
  }
  bar.style.display = 'flex';
  const total = items.reduce((sum, item) => sum + item.price * item.qty, 0);
  const whatsapp = block(1).whatsapp || block(1).phone || '';
  const message = encodeURIComponent(items.map(i => `\${i.name} x\${i.qty}`).join('\\n') + `\\nTotal: \$\${total.toFixed(2)}`);
  bar.innerHTML = `<span>\${items.length} item(s) · \$\${total.toFixed(2)}</span>` +
    (whatsapp ? `<a class="btn" href="https://wa.me/\${whatsapp.replace(/\\D/g,'')}?text=\${message}">WhatsApp Checkout</a>` : '');
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
