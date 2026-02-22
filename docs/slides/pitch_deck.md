---
marp: true
theme: default
paginate: false
backgroundColor: #0f172a
color: #f1f5f9
style: |
  @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;600;700;800;900&display=swap');

  * {
    font-family: 'Inter', sans-serif;
    box-sizing: border-box;
  }

  section {
    background-color: #0f172a;
    color: #f1f5f9;
    padding: 52px 64px;
    font-size: 18px;
    line-height: 1.5;
  }

  /* ─── PORTADA ─── */
  section.cover {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: flex-start;
    background: linear-gradient(135deg, #0f172a 0%, #1e1b4b 50%, #0f172a 100%);
    padding: 64px 80px;
  }
  section.cover .logo {
    font-size: 68px;
    font-weight: 900;
    letter-spacing: -2px;
    background: linear-gradient(90deg, #818cf8, #c084fc);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    margin-bottom: 8px;
  }
  section.cover .tagline {
    font-size: 26px;
    font-weight: 300;
    color: #94a3b8;
    margin-bottom: 32px;
    max-width: 600px;
    line-height: 1.4;
  }
  section.cover .pill {
    display: inline-block;
    background: rgba(129, 140, 248, 0.15);
    border: 1px solid rgba(129, 140, 248, 0.4);
    color: #a5b4fc;
    padding: 8px 20px;
    border-radius: 100px;
    font-size: 14px;
    font-weight: 600;
    letter-spacing: 0.5px;
  }
  section.cover .accentline {
    width: 64px;
    height: 4px;
    background: linear-gradient(90deg, #818cf8, #c084fc);
    border-radius: 2px;
    margin-bottom: 28px;
  }

  /* ─── TÍTULO DE SECCIÓN ─── */
  h1 {
    font-size: 38px;
    font-weight: 800;
    letter-spacing: -0.5px;
    color: #f1f5f9;
    margin-bottom: 8px;
    line-height: 1.2;
  }
  h1 span.accent {
    background: linear-gradient(90deg, #818cf8, #c084fc);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
  }
  h2 {
    font-size: 22px;
    font-weight: 600;
    color: #818cf8;
    margin-bottom: 24px;
    margin-top: 0;
  }
  h3 {
    font-size: 17px;
    font-weight: 700;
    color: #c084fc;
    margin-bottom: 8px;
    margin-top: 0;
  }

  /* ─── DIVISOR ─── */
  .divider {
    width: 48px;
    height: 3px;
    background: linear-gradient(90deg, #818cf8, #c084fc);
    border-radius: 2px;
    margin-bottom: 28px;
  }

  /* ─── CARDS ─── */
  .cards {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 20px;
    margin-top: 8px;
  }
  .cards.two {
    grid-template-columns: repeat(2, 1fr);
  }
  .card {
    background: rgba(129, 140, 248, 0.07);
    border: 1px solid rgba(129, 140, 248, 0.2);
    border-radius: 16px;
    padding: 24px 22px;
  }
  .card .icon {
    font-size: 32px;
    margin-bottom: 10px;
    display: block;
  }
  .card .card-title {
    font-size: 15px;
    font-weight: 700;
    color: #e2e8f0;
    margin-bottom: 6px;
  }
  .card .card-body {
    font-size: 13.5px;
    color: #94a3b8;
    line-height: 1.5;
  }

  /* ─── STAT GRANDE ─── */
  .stats-row {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 24px;
    margin-top: 16px;
  }
  .stat-box {
    text-align: center;
    background: rgba(192, 132, 252, 0.07);
    border: 1px solid rgba(192, 132, 252, 0.2);
    border-radius: 16px;
    padding: 28px 16px;
  }
  .stat-box .stat-num {
    font-size: 44px;
    font-weight: 900;
    letter-spacing: -1px;
    background: linear-gradient(90deg, #818cf8, #c084fc);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    line-height: 1;
    margin-bottom: 6px;
  }
  .stat-box .stat-label {
    font-size: 13px;
    color: #94a3b8;
    font-weight: 500;
  }

  /* ─── TABLA COMPARATIVA ─── */
  table {
    width: 100%;
    border-collapse: collapse;
    font-size: 14px;
    margin-top: 8px;
  }
  th {
    background: rgba(129, 140, 248, 0.15);
    color: #a5b4fc;
    font-weight: 700;
    padding: 12px 16px;
    text-align: left;
    border-bottom: 1px solid rgba(129, 140, 248, 0.2);
  }
  td {
    padding: 11px 16px;
    border-bottom: 1px solid rgba(255,255,255,0.05);
    color: #cbd5e1;
    vertical-align: middle;
  }
  tr:last-child td { border-bottom: none; }
  tr:hover td { background: rgba(129,140,248,0.05); }
  td:first-child { font-weight: 600; color: #e2e8f0; }

  /* ─── BADGE ─── */
  .badge {
    display: inline-block;
    background: rgba(34, 197, 94, 0.15);
    border: 1px solid rgba(34, 197, 94, 0.3);
    color: #4ade80;
    padding: 3px 10px;
    border-radius: 100px;
    font-size: 12px;
    font-weight: 600;
  }
  .badge.amber {
    background: rgba(251,191,36,0.12);
    border-color: rgba(251,191,36,0.3);
    color: #fbbf24;
  }
  .badge.red {
    background: rgba(248,113,113,0.12);
    border-color: rgba(248,113,113,0.3);
    color: #f87171;
  }

  /* ─── CHECKLIST ─── */
  .checklist {
    list-style: none;
    padding: 0;
    margin: 0;
  }
  .checklist li {
    padding: 8px 0;
    padding-left: 28px;
    position: relative;
    color: #cbd5e1;
    font-size: 15.5px;
    border-bottom: 1px solid rgba(255,255,255,0.05);
  }
  .checklist li:before {
    content: "✓";
    position: absolute;
    left: 0;
    color: #4ade80;
    font-weight: 700;
  }

  /* ─── STEPS (cómo funciona) ─── */
  .steps {
    display: grid;
    grid-template-columns: 1fr 40px 1fr 40px 1fr;
    gap: 0;
    align-items: start;
    margin-top: 16px;
  }
  .step {
    background: rgba(129,140,248,0.07);
    border: 1px solid rgba(129,140,248,0.2);
    border-radius: 16px;
    padding: 24px 20px;
    text-align: center;
  }
  .step .step-icon { font-size: 36px; margin-bottom: 12px; }
  .step .step-num {
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 2px;
    color: #818cf8;
    text-transform: uppercase;
    margin-bottom: 6px;
  }
  .step .step-title {
    font-size: 16px;
    font-weight: 700;
    color: #e2e8f0;
    margin-bottom: 8px;
  }
  .step .step-body {
    font-size: 13px;
    color: #94a3b8;
    line-height: 1.5;
  }
  .arrow {
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 22px;
    color: #6366f1;
    padding-top: 48px;
  }

  /* ─── TIMELINE ─── */
  .timeline {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 16px;
    margin-top: 16px;
    position: relative;
  }
  .timeline-item {
    position: relative;
  }
  .timeline-item .tl-phase {
    font-size: 11px;
    font-weight: 700;
    letter-spacing: 2px;
    color: #818cf8;
    text-transform: uppercase;
    margin-bottom: 6px;
  }
  .timeline-item .tl-time {
    font-size: 20px;
    font-weight: 800;
    color: #f1f5f9;
    margin-bottom: 8px;
  }
  .timeline-item .tl-body {
    font-size: 13px;
    color: #94a3b8;
    line-height: 1.5;
  }
  .tl-bar {
    height: 3px;
    background: linear-gradient(90deg, #818cf8, #c084fc);
    border-radius: 2px;
    margin-bottom: 16px;
  }

  /* ─── QUOTE ─── */
  blockquote {
    border-left: 3px solid #818cf8;
    margin: 20px 0 0 0;
    padding: 16px 24px;
    background: rgba(129,140,248,0.07);
    border-radius: 0 12px 12px 0;
    color: #cbd5e1;
    font-size: 16px;
    font-style: italic;
  }

  /* ─── CTA FINAL ─── */
  section.cta {
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    text-align: center;
    background: linear-gradient(135deg, #1e1b4b 0%, #0f172a 60%, #1e1b4b 100%);
  }
  section.cta h1 {
    font-size: 44px;
    margin-bottom: 16px;
  }
  section.cta .sub {
    font-size: 20px;
    color: #94a3b8;
    max-width: 620px;
    margin-bottom: 40px;
    line-height: 1.5;
  }
  section.cta .contact {
    background: rgba(129,140,248,0.1);
    border: 1px solid rgba(129,140,248,0.3);
    border-radius: 16px;
    padding: 20px 48px;
    font-size: 16px;
    color: #a5b4fc;
  }

  /* ─── NÚMERO DE PÁGINA ─── */
  section::after {
    content: attr(data-marpit-pagination) " / " attr(data-marpit-pagination-total);
    position: absolute;
    bottom: 24px;
    right: 40px;
    font-size: 12px;
    color: rgba(148,163,184,0.4);
  }
  section.cover::after, section.cta::after { display: none; }
---

<!-- _class: cover -->
<!-- paginate: false -->

<div class="logo">DiaBeaty</div>
<div class="accentline"></div>
<div class="tagline">El páncreas digital para familias<br>con Diabetes Tipo 1</div>
<div class="pill">🩸 Calculamos la dosis de insulina exacta en cada comida · En segundos</div>

---
<!-- paginate: true -->

# El <span class="accent">Problema</span>

<div class="divider"></div>

<div class="cards">
  <div class="card">
    <span class="icon">🧮</span>
    <div class="card-title">4–6 cálculos al día</div>
    <div class="card-body">Un paciente con Diabetes Tipo 1 calcula su dosis de insulina varias veces al día, todos los días del año, sin descanso ni margen de error.</div>
  </div>
  <div class="card">
    <span class="icon">👨‍👩‍👧</span>
    <div class="card-title">Los padres llevan la carga</div>
    <div class="card-body">Cuando el paciente es un niño, la responsabilidad recae al 100% en los padres: en el colegio, en cumpleaños, a las 3 de la madrugada.</div>
  </div>
  <div class="card">
    <span class="icon">⚠️</span>
    <div class="card-title">Un error puede ser mortal</div>
    <div class="card-body">Una hipoglucemia severa fruto de un cálculo incorrecto puede causar pérdida de conciencia o riesgo vital.</div>
  </div>
</div>

<blockquote>8,4 millones de personas con Diabetes Tipo 1 en el mundo. Ninguna tiene un páncreas que funcione. Todas necesitan una solución.</blockquote>

---

# La <span class="accent">Solución</span>

<div class="divider"></div>

<div class="cards">
  <div class="card">
    <span class="icon">📱</span>
    <div class="card-title">Calcula el bolo en segundos</div>
    <div class="card-body">Introduce los alimentos de tu comida y obtén la dosis exacta de insulina con codificación de color inmediata: verde · naranja · rojo.</div>
  </div>
  <div class="card">
    <span class="icon">🎮</span>
    <div class="card-title">Modo Héroe para niños</div>
    <div class="card-body">El control glucémico se convierte en una aventura RPG con puntos de experiencia, niveles y misiones diarias. La adherencia como motivación.</div>
  </div>
  <div class="card">
    <span class="icon">👨‍👩‍👧</span>
    <div class="card-title">Gestión familiar completa</div>
    <div class="card-body">Un guardián controla múltiples perfiles de pacientes, cada uno con sus ratios médicos personales protegidos por PIN.</div>
  </div>
</div>

<blockquote>DiaBeaty no sustituye al médico. Elimina el error humano en el cálculo rutinario.</blockquote>

---

# ¿Cómo <span class="accent">Funciona</span>?

<div class="divider"></div>

## Tres pasos · Menos de 60 segundos

<div class="steps">
  <div class="step">
    <div class="step-icon">🍽️</div>
    <div class="step-num">Paso 1</div>
    <div class="step-title">Construyes tu plato</div>
    <div class="step-body">Selecciona ingredientes y gramajes. Base de datos con 165+ alimentos y su Índice Glucémico validado.</div>
  </div>
  <div class="arrow">→</div>
  <div class="step">
    <div class="step-icon">⚡</div>
    <div class="step-num">Paso 2</div>
    <div class="step-title">DiaBeaty calcula</div>
    <div class="step-body">Algoritmo Bolus Wizard: carbohidratos totales + glucemia actual + tus ratios personales (ICR / ISF).</div>
  </div>
  <div class="arrow">→</div>
  <div class="step">
    <div class="step-icon">💉</div>
    <div class="step-num">Paso 3</div>
    <div class="step-title">Administras con confianza</div>
    <div class="step-body">Dosis recomendada en pantalla con código de color. Registro automático en el historial del paciente.</div>
  </div>
</div>

---

# <span class="accent">Mercado</span>

<div class="divider"></div>

<div class="stats-row">
  <div class="stat-box">
    <div class="stat-num">8,4M</div>
    <div class="stat-label">pacientes con Diabetes Tipo 1 en el mundo</div>
  </div>
  <div class="stat-box">
    <div class="stat-num">1,2M</div>
    <div class="stat-label">pacientes con Diabetes Tipo 1 en Europa</div>
  </div>
  <div class="stat-box">
    <div class="stat-num">+9%</div>
    <div class="stat-label">CAGR del mercado digital diabetes</div>
  </div>
</div>

<br>

El mercado global de apps de gestión de diabetes supera los **6.000M€ en 2025** y proyecta alcanzar los **12.000M€ en 2030**. La Diabetes Tipo 1 es el segmento de mayor adherencia digital: los pacientes interactúan con la app varias veces al día, generando datos de alto valor clínico y comercial.

<br>

<div style="display:flex; gap:12px; flex-wrap:wrap;">
  <span class="badge">IDF Diabetes Atlas 2023</span>
  <span class="badge">Grand View Research 2024</span>
  <span class="badge amber">Mercado en expansión constante</span>
</div>

---

# <span class="accent">Diferenciación</span>

<div class="divider"></div>

| Característica | **DiaBeaty** | Apps genéricas | Calculadoras de bomba |
|:---|:---:|:---:|:---:|
| Cálculo de bolo integrado | ✅ | ❌ | ✅ |
| Base de datos con Índice Glucémico | ✅ | Parcial | ❌ |
| Modo pediátrico gamificado | ✅ | ❌ | ❌ |
| Gestión multi-perfil familiar | ✅ | ❌ | ❌ |
| Datos PHI cifrados (Fernet AES) | ✅ | ❌ | Parcial |
| Sin hardware adicional | ✅ | ✅ | ❌ |

<blockquote>DiaBeaty es la única solución que combina precisión clínica, UX pediátrica y gestión familiar en una sola app gratuita.</blockquote>

---

# <span class="accent">Tecnología</span>

<div class="divider"></div>

<div class="cards">
  <div class="card">
    <span class="icon">🏗️</span>
    <div class="card-title">Clean Architecture</div>
    <div class="card-body"><strong>FastAPI + Python 3.12</strong> en backend. <strong>Flutter</strong> en mobile/web. <strong>PostgreSQL 16</strong> como base de datos. Separación estricta de capas en ambos lados.</div>
  </div>
  <div class="card">
    <span class="icon">🔒</span>
    <div class="card-title">Seguridad PHI por diseño</div>
    <div class="card-body">Todos los datos médicos sensibles (ISF, ICR, dosis) se cifran con <strong>Fernet AES-128-CBC</strong> antes de persistirse. Ni el admin de la BD puede leerlos.</div>
  </div>
  <div class="card">
    <span class="icon">🧪</span>
    <div class="card-title">Calidad certificada</div>
    <div class="card-body"><strong>146 tests automatizados</strong> (110 backend + 36 Flutter). TDD estricto: ninguna funcionalidad sin test previo. Cobertura &gt;90%.</div>
  </div>
</div>

<br>

<div style="display:flex; gap:10px; flex-wrap:wrap;">
  <span class="badge">FastAPI</span>
  <span class="badge">Flutter</span>
  <span class="badge">PostgreSQL 16</span>
  <span class="badge">Docker · Coolify CI/CD</span>
  <span class="badge">JWT · Bcrypt · Fernet</span>
</div>

---

# <span class="accent">Tracción</span>

<div class="divider"></div>

## MVP en producción · No es una demo

<ul class="checklist">
  <li>Motor de cálculo de bolo completo (algoritmo Bolus Wizard con ICR + ISF)</li>
  <li>Base de datos de 165+ alimentos con Índice Glucémico validado internacionalmente</li>
  <li>Sistema de gamificación XP / niveles / logros funcional y persistido en BD</li>
  <li>Gestión familiar multi-perfil con PIN de protección para menores</li>
  <li>Historial de glucosa y comidas con filtros por fecha y paginación</li>
  <li>Despliegue continuo automatizado — GitHub push → producción en minutos</li>
  <li>Cifrado PHI Fernet AES-128 activo en producción desde el día 1</li>
</ul>

<br>

<div style="display:flex; gap:12px;">
  <span class="badge">🌐 diabetics.jljimenez.es</span>
  <span class="badge">⚙️ diabetics-api.jljimenez.es/docs</span>
  <span class="badge amber">95% MVP completado</span>
</div>

---

# Modelo de <span class="accent">Negocio</span>

<div class="divider"></div>

<div class="cards">
  <div class="card">
    <span class="icon">🆓</span>
    <div class="card-title">Freemium</div>
    <div class="card-body">App gratuita con funcionalidad completa. Revenue por <strong>features premium</strong>: sincronización CGM, exportación PDF médico, backup en la nube.</div>
  </div>
  <div class="card">
    <span class="icon">🏥</span>
    <div class="card-title">B2B Clínico</div>
    <div class="card-body">Licencias SaaS para clínicas, hospitales y educadores en diabetes. <strong>Dashboard de adherencia</strong> de pacientes. Contrato recurrente de alto valor.</div>
  </div>
  <div class="card">
    <span class="icon">📊</span>
    <div class="card-title">Datos Clínicos</div>
    <div class="card-body">Datos epidemiológicos <strong>anonimizados y agregados</strong> para industria farmacéutica e investigación clínica. Siempre GDPR compliant.</div>
  </div>
</div>

<blockquote>Con 10.000 usuarios activos y 5% de conversión premium: <strong>60.000€ ARR</strong>. El canal B2B escala sin límite de usuarios.</blockquote>

---

# <span class="accent">Roadmap</span>

<div class="divider"></div>

<div class="timeline">
  <div class="timeline-item">
    <div class="tl-bar"></div>
    <div class="tl-phase">Hoy</div>
    <div class="tl-time">MVP Live</div>
    <div class="tl-body">Motor de bolus · 165+ ingredientes · Gamificación · Gestión familiar · CI/CD · PHI cifrado</div>
  </div>
  <div class="timeline-item">
    <div class="tl-bar" style="background:linear-gradient(90deg,#6366f1,#818cf8)"></div>
    <div class="tl-phase">6 meses</div>
    <div class="tl-time">CGM & Push</div>
    <div class="tl-body">Integración con Libre y Dexcom · Notificaciones de glucosa · Primer piloto con clínica</div>
  </div>
  <div class="timeline-item">
    <div class="tl-bar" style="background:linear-gradient(90deg,#818cf8,#a78bfa)"></div>
    <div class="tl-phase">12 meses</div>
    <div class="tl-time">SaMD</div>
    <div class="tl-body">Certificación EU MDR como Software as a Medical Device · Primer contrato B2B firmado</div>
  </div>
  <div class="timeline-item">
    <div class="tl-bar" style="background:linear-gradient(90deg,#a78bfa,#c084fc)"></div>
    <div class="tl-phase">24 meses</div>
    <div class="tl-time">Escala</div>
    <div class="tl-body">Expansión internacional · API pública para wearables · Serie A</div>
  </div>
</div>

<br>

> **SaMD** — *Software as a Medical Device*. Regulación europea EU MDR 2017/745.

---

# El <span class="accent">Equipo</span>

<div class="divider"></div>

<div class="cards two" style="max-width:680px;">
  <div class="card" style="padding:28px 26px;">
    <span class="icon">👨‍💻</span>
    <div class="card-title" style="font-size:17px;">José Luis Jiménez</div>
    <div class="card-body">Fullstack Engineer · Máster en Ingeniería y Arquitectura de Software con IA<br><br>
    Backend · Mobile · DevOps<br>
    Clean Architecture · TDD · Privacy by Design</div>
  </div>
  <div class="card" style="padding:28px 26px;">
    <span class="icon">🎯</span>
    <div class="card-title" style="font-size:17px;">Por qué este equipo</div>
    <div class="card-body">Construido por alguien que <strong>entiende el problema y domina la tecnología</strong>. 146 tests. 13 migraciones. 15 ADRs. Sistema en producción desde el primer sprint.</div>
  </div>
</div>

<blockquote>"Este proyecto nació de entender que el problema no es médico — es de ingeniería. La solución ya existe. Falta escalarla."</blockquote>

---
<!-- _class: cta -->
<!-- paginate: false -->

<h1>DiaBeaty <span class="accent">ya funciona.</span><br>Lo que viene es escala.</h1>

<div class="sub">Buscamos inversión seed de 150.000€ para certificación SaMD, integración CGM y primer contrato B2B clínico.<br>¿Nos acompañas?</div>

<div class="contact">
  🌐 diabetics.jljimenez.es &nbsp;·&nbsp; ⚙️ diabetics-api.jljimenez.es/docs<br><br>
  📩 <strong>contacto@jljimenez.es</strong>
</div>
