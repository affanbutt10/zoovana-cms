<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Zoovana — Premium iOS Dashboard</title>
<style>
  :root{
    --primary:#3B82F6; --primary-dark:#2563EB; --primary-glow:#DBEAFE;
    --secondary:#0B1E5B; --secondary-dark:#081647; --secondary-light:#1E3A8A;
    --accent:#4ECDC4; --accent-glow:#E0F7F5;
    --highlight:#F5C842; --highlight-glow:#FEF6DC;
    --coral:#EF4444; --coral-glow:#FEE2E2;
    --ink:#0B1E5B; --slate:#475569; --slate-light:#98A2B3;
    --mist:#E7EAF0; --mist-light:#F5F6F9;
    --white:#FFFFFF;
    --ease-spring: cubic-bezier(.32,.72,0,1);
    --ease-out: cubic-bezier(.22,1,.36,1);
    --ease-tap: cubic-bezier(.4,0,.2,1);
  }
  *{margin:0;padding:0;box-sizing:border-box;-webkit-tap-highlight-color:transparent;}
  html,body{height:100%;}
  body{
    background:#e4e7ee;
    font-family:-apple-system,BlinkMacSystemFont,"SF Pro Display","SF Pro Text","Segoe UI",Helvetica,Arial,sans-serif;
    padding:34px 12px 60px;
    -webkit-font-smoothing:antialiased;
  }
  .wrap{max-width:430px;margin:0 auto;}

  /* ---------- demo-only segmented control above the phone ---------- */
  .switcher{
    display:flex;background:#d8dce6;border-radius:12px;padding:3px;gap:2px;margin-bottom:10px;
    box-shadow:inset 0 1px 2px rgba(11,30,91,.08);
  }
  .switcher button{
    flex:1;border:none;background:transparent;color:var(--slate);
    font-family:inherit;font-size:11.5px;font-weight:600;padding:8px 4px;border-radius:9px;
    cursor:pointer;transition:color .25s var(--ease-tap);white-space:nowrap;
  }
  .switcher button.active{background:#fff;color:var(--ink);box-shadow:0 1px 3px rgba(11,30,91,.18),0 1px 1px rgba(11,30,91,.06);}
  .switcher button:active{transform:scale(.96);}
  .hint{text-align:center;font-size:11.5px;color:#6b7280;margin-bottom:20px;letter-spacing:.1px;}
  .hint b{color:var(--ink);}

  /* ---------- iPhone frame ---------- */
  .frame{
    width:390px;margin:0 auto;background:var(--mist-light);border-radius:55px;overflow:hidden;
    box-shadow:0 50px 100px -20px rgba(11,30,91,.35), 0 0 0 1px rgba(255,255,255,.4) inset;
    border:7px solid #0d0e14;position:relative;height:844px;
  }
  .dynamic-island{
    position:absolute;top:12px;left:50%;transform:translateX(-50%);
    width:120px;height:34px;background:#000;border-radius:20px;z-index:20;
  }
  .statusbar{
    display:flex;justify-content:space-between;align-items:center;padding:16px 28px 2px;
    font-size:14.5px;font-weight:600;color:var(--ink);position:relative;z-index:2;letter-spacing:-.2px;
  }
  .sb-icons{display:flex;align-items:center;gap:5px;}
  .home-indicator{
    position:absolute;bottom:8px;left:50%;transform:translateX(-50%);
    width:134px;height:5px;border-radius:100px;background:rgba(11,30,91,.55);z-index:20;
  }

  /* ---------- top bar (frosted, sticky) ---------- */
  .topbar{
    display:flex;justify-content:space-between;align-items:center;padding:10px 20px 10px;
    position:sticky;top:0;z-index:5;background:rgba(245,246,249,.78);backdrop-filter:blur(20px) saturate(1.6);
    -webkit-backdrop-filter:blur(20px) saturate(1.6);
    border-bottom:1px solid rgba(11,30,91,.06);
  }
  .tb-left{display:flex;align-items:center;gap:11px;min-width:0;}
  .icon-btn{
    width:34px;height:34px;border-radius:11px;background:#fff;border:1px solid rgba(11,30,91,.07);
    display:flex;align-items:center;justify-content:center;font-size:14px;color:var(--ink);flex-shrink:0;
    cursor:pointer;transition:transform .15s var(--ease-tap),background .15s;
    box-shadow:0 1px 2px rgba(11,30,91,.05);
  }
  .icon-btn:active{transform:scale(.9);background:var(--mist-light);}
  .tb-brand{display:flex;align-items:center;gap:9px;min-width:0;}
  .tb-brand .mark{
    width:30px;height:30px;border-radius:9px;background:linear-gradient(150deg,var(--secondary),var(--primary));
    display:flex;align-items:center;justify-content:center;font-size:13px;flex-shrink:0;
  }
  .tb-titles{min-width:0;}
  .tb-titles .title{
    font-weight:700;font-size:15px;color:var(--ink);line-height:1.15;white-space:nowrap;
    overflow:hidden;text-overflow:ellipsis;letter-spacing:-.2px;transition:opacity .2s;
  }
  .tb-titles .sub{font-size:10.5px;color:var(--slate-light);white-space:nowrap;overflow:hidden;text-overflow:ellipsis;font-weight:500;}
  .tb-right{display:flex;align-items:center;gap:7px;flex-shrink:0;}

  .content{
    padding:0 18px 110px;overflow-y:auto;height:calc(100% - 62px);position:relative;
    -webkit-overflow-scrolling:touch;scrollbar-width:none;
  }
  .content::-webkit-scrollbar{display:none;}

  /* content transition (view-controller-like push/fade) */
  .view{animation:viewIn .38s var(--ease-out);}
  @keyframes viewIn{
    from{opacity:0;transform:translateY(10px) scale(.99);}
    to{opacity:1;transform:translateY(0) scale(1);}
  }

  /* ---------- hero ---------- */
  .hero{
    border-radius:28px;padding:22px 20px 22px;position:relative;overflow:hidden;color:#fff;margin-top:10px;
    transition:background .4s var(--ease-out);
    box-shadow:0 20px 40px -12px rgba(11,30,91,.45);
  }
  .hero .blob{position:absolute;width:190px;height:190px;border-radius:50%;top:-80px;right:-60px;background:radial-gradient(circle,rgba(255,255,255,.07),transparent 70%);}
  .hero .blob2{position:absolute;width:140px;height:140px;border-radius:50%;bottom:-70px;left:-40px;background:radial-gradient(circle,rgba(255,255,255,.04),transparent 70%);}
  .hero-top{display:flex;justify-content:space-between;align-items:flex-start;position:relative;margin-bottom:16px;}
  .hero-icon{
    width:42px;height:42px;border-radius:13px;background:rgba(255,255,255,.12);
    display:flex;align-items:center;justify-content:center;font-size:18px;
    border:1px solid rgba(255,255,255,.14);
  }
  .roles-pill{
    background:rgba(255,255,255,.14);border:1px solid rgba(255,255,255,.22);
    padding:8px 13px;border-radius:100px;font-size:11px;font-weight:700;color:#fff;
    display:flex;align-items:center;gap:6px;cursor:pointer;white-space:nowrap;
    transition:transform .15s var(--ease-tap),background .15s;letter-spacing:.2px;
  }
  .roles-pill:active{transform:scale(.93);background:rgba(255,255,255,.22);}
  .hero-eyebrow{font-size:10.5px;letter-spacing:1.4px;text-transform:uppercase;font-weight:700;color:rgba(255,255,255,.65);margin-bottom:8px;position:relative;}
  .hero h1{font-weight:700;font-size:22px;line-height:1.24;position:relative;margin-bottom:7px;letter-spacing:-.4px;}
  .hero p{font-size:12.5px;color:rgba(255,255,255,.62);line-height:1.5;position:relative;max-width:270px;font-weight:450;}

  /* ---------- stats ---------- */
  .stats{display:flex;gap:8px;margin-top:16px;}
  .more-stats{display:flex;gap:8px;margin-top:8px;}
  .stat-card{
    flex:1;background:rgba(255,255,255,.09);backdrop-filter:blur(6px);
    border:1px solid rgba(255,255,255,.14);border-radius:18px;padding:13px 12px;
    transition:transform .12s var(--ease-tap);
  }
  .stat-card:active{transform:scale(.95);}
  .stat-card .icon{width:26px;height:26px;border-radius:8px;display:flex;align-items:center;justify-content:center;margin-bottom:10px;font-size:12px;background:rgba(255,255,255,.14);}
  .stat-card .label{font-size:9.5px;color:rgba(255,255,255,.55);font-weight:600;margin-bottom:2px;letter-spacing:.1px;}
  .stat-card .num{font-size:17px;font-weight:700;color:#fff;letter-spacing:-.3px;}
  .stat-card .delta{font-size:8.5px;font-weight:700;margin-top:3px;color:rgba(255,255,255,.7);}

  /* ---------- section headers ---------- */
  .section-head{display:flex;align-items:center;gap:9px;margin:24px 0 2px;}
  .section-head .bar{width:4px;height:15px;border-radius:3px;}
  .section-head h2{font-weight:700;font-size:16px;color:var(--ink);letter-spacing:-.3px;}
  .section-sub{font-size:11.5px;color:var(--slate-light);margin:3px 0 12px 13px;font-weight:500;}

  /* ---------- cards (soft, layered iOS shadow) ---------- */
  .list-card, .qa-card, .empty-state, .care-tip, .capacity-card, .spark-card, .rating-card{
    background:var(--white);border:1px solid rgba(11,30,91,.06);
    box-shadow:0 1px 2px rgba(11,30,91,.04), 0 10px 24px -12px rgba(11,30,91,.12);
    transition:transform .14s var(--ease-tap),box-shadow .14s;
  }
  .list-card:active, .qa-card:active{transform:scale(.975);box-shadow:0 1px 2px rgba(11,30,91,.04),0 4px 10px -6px rgba(11,30,91,.1);}

  .list-card{border-radius:18px;padding:13px;display:flex;align-items:center;gap:12px;margin-bottom:9px;cursor:pointer;}
  .list-avatar{width:42px;height:42px;border-radius:13px;display:flex;align-items:center;justify-content:center;font-size:17px;flex-shrink:0;}
  .list-info{flex:1;min-width:0;}
  .list-info .t{font-weight:700;font-size:13.5px;color:var(--ink);margin-bottom:2px;letter-spacing:-.1px;}
  .list-info .s{font-size:11px;color:var(--slate-light);font-weight:500;}
  .list-tag{font-size:9px;font-weight:700;padding:5px 10px;border-radius:100px;white-space:nowrap;}
  .chev{color:var(--slate-light);font-size:13px;font-weight:700;margin-left:2px;}

  .empty-state{border-radius:20px;padding:32px 22px;text-align:center;}
  .empty-state .ic{font-size:26px;margin-bottom:11px;opacity:.85;}
  .empty-state h3{font-size:14.5px;font-weight:700;color:var(--ink);margin-bottom:5px;letter-spacing:-.2px;}
  .empty-state p{font-size:11.5px;color:var(--slate-light);line-height:1.55;max-width:250px;margin:0 auto;font-weight:500;}

  .signature{margin-top:14px;}

  .care-tip{border-radius:20px;padding:15px 16px;display:flex;gap:12px;align-items:flex-start;}
  .care-tip .ic{width:36px;height:36px;border-radius:11px;display:flex;align-items:center;justify-content:center;font-size:15px;flex-shrink:0;}
  .care-tip .txt .k{font-size:10px;font-weight:700;text-transform:uppercase;letter-spacing:.5px;margin-bottom:3px;}
  .care-tip .txt .t{font-size:12.5px;color:var(--ink);font-weight:600;line-height:1.45;}

  .badge-row{display:flex;gap:9px;}
  .badge{
    flex:1;background:var(--white);border:1px solid rgba(11,30,91,.06);border-radius:18px;padding:14px 8px;text-align:center;
    box-shadow:0 1px 2px rgba(11,30,91,.04),0 10px 24px -12px rgba(11,30,91,.12);
    transition:transform .14s var(--ease-tap);
  }
  .badge:active{transform:scale(.95);}
  .badge .ring{width:40px;height:40px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:15px;margin:0 auto 8px;}
  .badge .lbl{font-size:9.5px;font-weight:700;color:var(--ink);}
  .badge .sub{font-size:8.5px;color:var(--slate-light);margin-top:1px;font-weight:500;}

  .capacity-card{border-radius:20px;padding:16px 17px;}
  .capacity-head{display:flex;justify-content:space-between;align-items:baseline;margin-bottom:10px;}
  .capacity-head .t{font-size:12.5px;font-weight:700;color:var(--ink);}
  .capacity-head .v{font-size:13px;font-weight:700;}
  .meter-track{height:8px;border-radius:100px;background:var(--mist-light);overflow:hidden;}
  .meter-fill{height:100%;border-radius:100px;transition:width 1s var(--ease-out);}
  .capacity-foot{font-size:10px;color:var(--slate-light);margin-top:8px;font-weight:500;}

  .spark-card{border-radius:20px;padding:16px 17px;}
  .spark-head{display:flex;justify-content:space-between;align-items:baseline;margin-bottom:10px;}
  .spark-head .t{font-size:12.5px;font-weight:700;color:var(--ink);}
  .spark-head .v{font-size:15px;font-weight:700;}
  .spark-card svg{width:100%;height:44px;display:block;}

  .rating-card{border-radius:20px;padding:16px 17px;display:flex;align-items:center;gap:14px;}
  .rating-card .stars{width:50px;height:50px;border-radius:16px;display:flex;align-items:center;justify-content:center;font-size:21px;flex-shrink:0;}
  .rating-card .txt .n{font-size:15.5px;font-weight:700;color:var(--ink);}
  .rating-card .txt .s{font-size:11px;color:var(--slate-light);margin-top:2px;font-weight:500;}
  .rating-card .cta{
    margin-left:auto;font-size:10.5px;font-weight:700;padding:8px 13px;border-radius:100px;white-space:nowrap;
    transition:transform .15s var(--ease-tap);cursor:pointer;
  }
  .rating-card .cta:active{transform:scale(.92);}

  .qa-grid{display:flex;gap:9px;}
  .qa-card{flex:1;border-radius:20px;padding:16px 14px;cursor:pointer;}
  .qa-card .icon{width:30px;height:30px;border-radius:10px;display:flex;align-items:center;justify-content:center;margin-bottom:16px;font-size:12px;}
  .qa-card h3{font-size:13px;font-weight:700;color:var(--ink);margin-bottom:2px;letter-spacing:-.1px;}
  .qa-card .desc{font-size:10.5px;color:var(--slate-light);font-weight:500;}

  /* ---------- bottom tab bar ---------- */
  .navbar{
    position:absolute;bottom:0;left:0;right:0;
    background:rgba(255,255,255,.82);backdrop-filter:blur(24px) saturate(1.7);-webkit-backdrop-filter:blur(24px) saturate(1.7);
    border-top:1px solid rgba(11,30,91,.07);
    display:flex;justify-content:space-around;padding:11px 8px 26px;z-index:2;
  }
  .nav-item{
    display:flex;flex-direction:column;align-items:center;gap:4px;font-size:10px;font-weight:600;
    color:var(--slate-light);flex:1;transition:transform .15s var(--ease-tap);cursor:pointer;
  }
  .nav-item:active{transform:scale(.88);}
  .nav-item.active{color:var(--primary);}
  .nav-item .nib{width:34px;height:23px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:13px;transition:background .2s;}
  .nav-item.active .nib{background:var(--primary-glow);}

  /* ---------- iOS-style bottom sheet (replaces old dropdown) ---------- */
  .sheet-backdrop{
    position:absolute;inset:0;background:rgba(11,30,91,.4);opacity:0;pointer-events:none;
    transition:opacity .3s var(--ease-out);z-index:8;
  }
  .sheet-backdrop.open{opacity:1;pointer-events:auto;}
  .sheet{
    position:absolute;left:0;right:0;bottom:0;background:#fff;border-radius:26px 26px 0 0;
    box-shadow:0 -20px 50px rgba(11,30,91,.3);z-index:9;
    transform:translateY(100%);transition:transform .42s var(--ease-spring);
    padding:10px 8px 30px;
  }
  .sheet.open{transform:translateY(0);}
  .sheet-handle{width:36px;height:5px;border-radius:100px;background:var(--mist);margin:6px auto 14px;}
  .sheet-title{font-size:13px;font-weight:700;color:var(--slate-light);text-transform:uppercase;letter-spacing:.6px;padding:0 14px 10px;}
  .role-row{
    display:flex;align-items:center;gap:12px;padding:13px 14px;border-radius:14px;cursor:pointer;
    transition:background .15s var(--ease-tap),transform .12s var(--ease-tap);
  }
  .role-row:active{transform:scale(.98);background:var(--mist-light);}
  .role-row .ic{width:36px;height:36px;border-radius:11px;display:flex;align-items:center;justify-content:center;font-size:15px;flex-shrink:0;}
  .role-row .lbl{flex:1;font-size:14px;font-weight:600;color:var(--ink);letter-spacing:-.1px;}
  .role-row .check{color:var(--primary);font-size:15px;font-weight:700;}
  .sheet-cancel{
    margin:8px 6px 0;padding:14px;text-align:center;font-size:14.5px;font-weight:700;color:var(--ink);
    background:var(--mist-light);border-radius:16px;cursor:pointer;transition:transform .12s var(--ease-tap);
  }
  .sheet-cancel:active{transform:scale(.97);}
</style>
</head>
<body>
<div class="wrap">
  <div class="switcher">
    <button class="active" onclick="setRole('owner',this)">Owner</button>
    <button onclick="setRole('volunteer',this)">Volunteer</button>
    <button onclick="setRole('shelter',this)">Shelter</button>
    <button onclick="setRole('shop',this)">Shop</button>
    <button onclick="setRole('provider',this)">Provider</button>
  </div>
  <div class="hint">Same premium chrome across every role — tap <b>ROLES</b> in the hero for the new sheet-style switcher.</div>

  <div class="frame">
    <div class="dynamic-island"></div>
    <div class="statusbar">
      <span>9:41</span>
      <div class="sb-icons">
        <svg width="17" height="11" viewBox="0 0 17 11" fill="none"><rect x="0" y="7" width="3" height="4" rx="0.6" fill="#0B1E5B"/><rect x="4.5" y="5" width="3" height="6" rx="0.6" fill="#0B1E5B"/><rect x="9" y="3" width="3" height="8" rx="0.6" fill="#0B1E5B"/><rect x="13.5" y="0" width="3" height="11" rx="0.6" fill="#0B1E5B"/></svg>
        <svg width="15" height="11" viewBox="0 0 15 11" fill="none"><path d="M7.5 2.2C10 2.2 12.2 3.3 13.8 5L15 3.7C13 1.7 10.4 0.5 7.5 0.5C4.6 0.5 2 1.7 0 3.7L1.2 5C2.8 3.3 5 2.2 7.5 2.2Z" fill="#0B1E5B"/><path d="M7.5 5.4C8.9 5.4 10.2 6 11.1 7L7.5 10.5L3.9 7C4.8 6 6.1 5.4 7.5 5.4Z" fill="#0B1E5B"/></svg>
        <svg width="25" height="12" viewBox="0 0 25 12" fill="none"><rect x="0.75" y="0.75" width="20.5" height="10.5" rx="2.5" stroke="#0B1E5B" stroke-opacity="0.4"/><rect x="2" y="2" width="18" height="8" rx="1.5" fill="#0B1E5B"/><rect x="22" y="4" width="1.6" height="4" rx="0.8" fill="#0B1E5B" fill-opacity="0.4"/></svg>
      </div>
    </div>

    <div class="topbar">
      <div class="tb-left">
        <div class="icon-btn">☰</div>
        <div class="tb-brand">
          <div class="mark">🐞</div>
          <div class="tb-titles"><div class="title" id="tbTitle">My Zoovana</div><div class="sub" id="tbSub">Pet care dashboard</div></div>
        </div>
      </div>
      <div class="tb-right">
        <div class="icon-btn">💬</div>
        <div class="icon-btn">⚙️</div>
      </div>
    </div>

    <div class="content" id="contentArea"></div>

    <div class="navbar">
      <div class="nav-item"><div class="nib">🤝</div>Services</div>
      <div class="nav-item"><div class="nib">🐾</div>Adopt</div>
      <div class="nav-item active"><div class="nib">🏠</div>Home</div>
      <div class="nav-item"><div class="nib">👤</div>Profile</div>
    </div>

    <div class="home-indicator"></div>

    <div class="sheet-backdrop" id="sheetBackdrop" onclick="closeRoles()"></div>
    <div class="sheet" id="roleSheet">
      <div class="sheet-handle"></div>
      <div class="sheet-title">Switch dashboard</div>
      <div class="role-row" onclick="setRole('owner')"><div class="ic" style="background:var(--primary-glow);color:var(--primary);">🐾</div><div class="lbl">Animal Owner</div><div class="check" id="check-owner"></div></div>
      <div class="role-row" onclick="setRole('volunteer')"><div class="ic" style="background:var(--highlight-glow);color:#B45309;">🤝</div><div class="lbl">Volunteer</div><div class="check" id="check-volunteer"></div></div>
      <div class="role-row" onclick="setRole('shelter')"><div class="ic" style="background:var(--accent-glow);color:#0D9488;">🏠</div><div class="lbl">Shelter Owner</div><div class="check" id="check-shelter"></div></div>
      <div class="role-row" onclick="setRole('shop')"><div class="ic" style="background:rgba(11,30,91,0.08);color:var(--secondary);">🏬</div><div class="lbl">Shop Owner</div><div class="check" id="check-shop"></div></div>
      <div class="role-row" onclick="setRole('provider')"><div class="ic" style="background:var(--coral-glow);color:var(--coral);">🛠️</div><div class="lbl">Service Provider</div><div class="check" id="check-provider"></div></div>
      <div class="sheet-cancel" onclick="closeRoles()">Cancel</div>
    </div>
  </div>
</div>

<script>
const theme = {
  owner:     {title:'My Zoovana', sub:'Pet care dashboard', accent:'#3B82F6', accentGlow:'#DBEAFE',
              heroBg:'linear-gradient(150deg,#0B1E5B 0%,#15347F 55%,#1D4ED8 130%)', icon:'🐾'},
  volunteer: {title:'Volunteer Hub', sub:'Shifts & impact', accent:'#F0A93A', accentGlow:'#FEF6DC',
              heroBg:'linear-gradient(150deg,#0B1E5B 0%,#40361B 70%,#6B4E12 140%)', icon:'🤝'},
  shelter:   {title:'Shelter Operations', sub:'Care, housing & intake', accent:'#2FD9CC', accentGlow:'#E0F7F5',
              heroBg:'linear-gradient(150deg,#0B1E5B 0%,#0F3A46 65%,#0D6E63 140%)', icon:'🏠'},
  shop:      {title:'Shop Owner', sub:'Commerce & inventory', accent:'#6C8EF5', accentGlow:'#E7ECFB',
              heroBg:'linear-gradient(150deg,#0B1E5B 0%,#122A6E 60%,#1E3A8A 130%)', icon:'🏬'},
  provider:  {title:'Service Provider', sub:'Bookings & earnings', accent:'#FF6B6B', accentGlow:'#FEE2E2',
              heroBg:'linear-gradient(150deg,#0B1E5B 0%,#3E1B2E 70%,#7A1F2B 140%)', icon:'🛠️'},
};

// stat card accents on the dark hero use white-on-glass, not the light-mode accent glows
let currentRole = 'owner';

function heroFor(role){
  const h = {
    owner: {eyebrow:'PET CARE DASHBOARD', title:'Good to see you, Affan', body:'Your pets, bookings, and trusted services are all gathered in one calm place.'},
    volunteer: {eyebrow:'YOUR VOLUNTEER IMPACT', title:'Ready when your shelter needs you', body:'Track your time, manage upcoming shifts, and keep your shelter team in sync.'},
    shelter: {eyebrow:'SHELTER COMMAND CENTER', title:'Care that stays on schedule', body:"Today's care, housing, and community work are together in one clear view."},
    shop: {eyebrow:'COMMERCE COMMAND CENTER', title:'Sell smarter across every shop', body:'Track revenue, inventory pressure, order flow, and category performance in one view.'},
    provider: {eyebrow:'PROVIDER STUDIO', title:'Your services are ready to sell', body:'Keep revenue, response quality, active services, and client requests in one polished view.'},
  };
  return h[role];
}

function statsFor(role){
  const sets = {
    owner: { primary: [
        {icon:'🐾', label:'Pets', num:'1'},
        {icon:'📅', label:'Bookings', num:'0'},
        {icon:'💬', label:'Messages', num:'0'},
      ], more: [] },
    volunteer: { primary: [
        {icon:'📋', label:'Total shifts', num:'0'},
        {icon:'⏱', label:'Hours served', num:'0'},
        {icon:'⚡', label:'Needs action', num:'0'},
      ], more: [] },
    shelter: { primary: [
        {icon:'🐾', label:'Total animals', num:'0', delta:'+0 this week'},
        {icon:'🏡', label:'Available', num:'0', delta:'Ready for adoption'},
        {icon:'💉', label:'Vaccinations due', num:'0', delta:'Next 30 days'},
      ], more: [ {icon:'🩺', label:'Need medical care', num:'0'} ] },
    shop: { primary: [
        {icon:'💰', label:'Total revenue', num:'SAR 0'},
        {icon:'🛒', label:'Total orders', num:'0'},
        {icon:'🏬', label:'Active shops', num:'0'},
      ], more: [] },
    provider: { primary: [
        {icon:'💰', label:'Monthly revenue', num:'SAR 0'},
        {icon:'📅', label:'Total bookings', num:'0'},
        {icon:'⭐', label:'Profile rating', num:'N/A'},
      ], more: [
        {icon:'📈', label:'Response rate', num:'0%'},
        {icon:'💼', label:'Completed jobs', num:'0'},
        {icon:'🛠️', label:'Active services', num:'1'},
      ] },
  };
  return sets[role];
}

function statCardHTML(s){
  return `<div class="stat-card">
    <div class="icon">${s.icon}</div>
    <div class="label">${s.label}</div>
    <div class="num">${s.num}</div>
    ${s.delta ? `<div class="delta">${s.delta}</div>` : ''}
  </div>`;
}

function signatureFor(role){
  const t = theme[role];
  if(role==='owner') return `
    <div class="signature"><div class="care-tip">
      <div class="ic" style="background:${t.accentGlow};color:${t.accent};">💡</div>
      <div class="txt">
        <div class="k" style="color:${t.accent};">Care tip</div>
        <div class="t">Dasd is due for a wellness check-up — booking now keeps their record up to date.</div>
      </div>
    </div></div>
  `;
  if(role==='volunteer') return `
    <div class="signature"><div class="badge-row">
      <div class="badge"><div class="ring" style="background:${t.accentGlow};color:${t.accent};">🥉</div><div class="lbl">10 hrs</div><div class="sub">Locked</div></div>
      <div class="badge"><div class="ring" style="background:${t.accentGlow};color:${t.accent};">🥈</div><div class="lbl">25 hrs</div><div class="sub">Locked</div></div>
      <div class="badge"><div class="ring" style="background:${t.accentGlow};color:${t.accent};">🥇</div><div class="lbl">50 hrs</div><div class="sub">Locked</div></div>
    </div></div>
  `;
  if(role==='shelter') return `
    <div class="signature"><div class="capacity-card">
      <div class="capacity-head"><div class="t">Shelter capacity</div><div class="v" style="color:${t.accent};">0 / 50</div></div>
      <div class="meter-track"><div class="meter-fill" style="width:0%;background:${t.accent};"></div></div>
      <div class="capacity-foot">Kennels currently occupied</div>
    </div></div>
  `;
  if(role==='shop') return `
    <div class="signature"><div class="spark-card">
      <div class="spark-head"><div class="t">Revenue — this week</div><div class="v" style="color:${t.accent};">SAR 0</div></div>
      <svg viewBox="0 0 280 44" preserveAspectRatio="none">
        <path d="M0,42 L280,42" stroke="${t.accent}" stroke-width="3" stroke-linecap="round" fill="none"/>
      </svg>
    </div></div>
  `;
  if(role==='provider') return `
    <div class="signature"><div class="rating-card">
      <div class="stars" style="background:${t.accentGlow};color:${t.accent};">⭐</div>
      <div class="txt"><div class="n">N/A rating</div><div class="s">0 reviews yet</div></div>
      <div class="cta" style="background:${t.accentGlow};color:${t.accent};">Get started</div>
    </div></div>
  `;
}

function bodyFor(role){
  const t = theme[role];
  if(role==='owner') return `
    <div class="section-head"><div class="bar" style="background:${t.accent};"></div><h2>My companions</h2></div>
    <div class="section-sub">Health & care at a glance</div>
    <div class="list-card"><div class="list-avatar" style="background:${t.accentGlow};">🐶</div><div class="list-info"><div class="t">dasd</div><div class="s">dog · asdasd · 2 years</div></div><div class="list-tag" style="background:${t.accentGlow};color:${t.accent};">Vaccinated</div><div class="chev">›</div></div>
    <div class="section-head"><div class="bar" style="background:${t.accent};"></div><h2>Quick actions</h2></div>
    <div class="section-sub">Everything your pet care journey needs</div>
    <div class="qa-grid">
      <div class="qa-card"><div class="icon" style="background:${t.accentGlow};color:${t.accent};">🔍</div><h3>Services</h3><div class="desc">Browse providers</div></div>
      <div class="qa-card"><div class="icon" style="background:${t.accentGlow};color:${t.accent};">📅</div><h3>Book service</h3><div class="desc">Schedule a visit</div></div>
    </div>
  `;
  if(role==='volunteer') return `
    <div class="section-head"><div class="bar" style="background:${t.accent};"></div><h2>Your shifts</h2></div>
    <div class="section-sub">Approved shifts will appear here</div>
    <div class="empty-state">
      <div class="ic">🗓️</div>
      <h3>No shifts scheduled</h3>
      <p>When your shelter assigns a shift, it will appear here with attendance actions.</p>
    </div>
    <div class="section-head"><div class="bar" style="background:${t.accent};"></div><h2>Make a difference nearby</h2></div>
    <div class="section-sub">Shelters near you are looking for help</div>
    <div class="qa-grid">
      <div class="qa-card"><div class="icon" style="background:${t.accentGlow};color:${t.accent};">🔎</div><h3>Find a shift</h3><div class="desc">Browse openings</div></div>
      <div class="qa-card"><div class="icon" style="background:${t.accentGlow};color:${t.accent};">✍️</div><h3>Log hours</h3><div class="desc">Track your time</div></div>
    </div>
  `;
  if(role==='shelter') return `
    <div class="section-head"><div class="bar" style="background:${t.accent};"></div><h2>Animal care</h2></div>
    <div class="section-sub">Health, housing and daily operations</div>
    <div class="empty-state">
      <div class="ic">🐾</div>
      <h3>No animals yet</h3>
      <p>Animals you add for intake will show up here with care status.</p>
    </div>
    <div class="section-head"><div class="bar" style="background:${t.accent};"></div><h2>Quick actions</h2></div>
    <div class="section-sub">Keep intake and outcomes moving</div>
    <div class="qa-grid">
      <div class="qa-card"><div class="icon" style="background:${t.accentGlow};color:${t.accent};">➕</div><h3>Add animal</h3><div class="desc">New intake</div></div>
      <div class="qa-card"><div class="icon" style="background:${t.accentGlow};color:${t.accent};">📋</div><h3>Review requests</h3><div class="desc">0 pending</div></div>
    </div>
  `;
  if(role==='shop') return `
    <div class="section-head"><div class="bar" style="background:${t.accent};"></div><h2>Revenue trend</h2></div>
    <div class="section-sub">Last 6 months</div>
    <div class="empty-state">
      <div class="ic">📈</div>
      <h3>No revenue data yet</h3>
      <p>Once orders start coming in, your trend will build here automatically.</p>
    </div>
    <div class="section-head"><div class="bar" style="background:${t.accent};"></div><h2>Recent orders</h2></div>
    <div class="section-sub">Latest customer activity</div>
    <div class="empty-state">
      <div class="ic">🧾</div>
      <h3>No orders yet</h3>
      <p>New orders across all your shops will show up here.</p>
    </div>
  `;
  if(role==='provider') return `
    <div class="section-head"><div class="bar" style="background:${t.accent};"></div><h2>Active services</h2></div>
    <div class="section-sub">Manage listings</div>
    <div class="list-card"><div class="list-avatar" style="background:${t.accentGlow};">✂️</div><div class="list-info"><div class="t">Nice grooming</div><div class="s">SAR 6,700 / day</div></div><div class="chev">›</div></div>
    <div class="section-head"><div class="bar" style="background:${t.accent};"></div><h2>Quick actions</h2></div>
    <div class="section-sub">Keep bookings and availability current</div>
    <div class="qa-grid">
      <div class="qa-card"><div class="icon" style="background:${t.accentGlow};color:${t.accent};">🗓️</div><h3>Update schedule</h3><div class="desc">Set availability</div></div>
      <div class="qa-card"><div class="icon" style="background:${t.accentGlow};color:${t.accent};">💳</div><h3>View payouts</h3><div class="desc">Track earnings</div></div>
    </div>
  `;
}

function render(){
  const t = theme[currentRole];
  document.getElementById('tbTitle').textContent = t.title;
  document.getElementById('tbSub').textContent = t.sub;

  ['owner','volunteer','shelter','shop','provider'].forEach(r=>{
    document.getElementById('check-'+r).textContent = (r===currentRole) ? '✓' : '';
  });

  const h = heroFor(currentRole);
  const stats = statsFor(currentRole);
  let statsHTML = `<div class="stats">${stats.primary.map(s=>statCardHTML(s)).join('')}</div>`;
  if(stats.more.length) statsHTML += `<div class="more-stats">${stats.more.map(s=>statCardHTML(s)).join('')}</div>`;

  const content = document.getElementById('contentArea');
  content.innerHTML = `
    <div class="view">
      <div class="hero" style="background:${t.heroBg};">
        <div class="blob"></div><div class="blob2"></div>
        <div class="hero-top">
          <div class="hero-icon">${t.icon}</div>
          <div class="roles-pill" onclick="openRoles(event)">⟨ ROLES</div>
        </div>
        <div class="hero-eyebrow">${h.eyebrow}</div>
        <h1>${h.title}</h1>
        <p>${h.body}</p>
        ${statsHTML}
      </div>
      ${signatureFor(currentRole)}
      ${bodyFor(currentRole)}
    </div>
  `;
  content.scrollTop = 0;
}

function setRole(role, btn){
  currentRole = role;
  if(btn){
    document.querySelectorAll('.switcher button').forEach(b=>b.classList.remove('active'));
    btn.classList.add('active');
  } else {
    document.querySelectorAll('.switcher button').forEach(b=>{
      const map = {owner:'owner',volunteer:'volunteer',shelter:'shelter',shop:'shop',provider:'provider'};
      b.classList.toggle('active', b.textContent.trim().toLowerCase() === role);
    });
  }
  render();
  closeRoles();
}
function openRoles(e){ e.stopPropagation(); document.getElementById('roleSheet').classList.add('open'); document.getElementById('sheetBackdrop').classList.add('open'); }
function closeRoles(){ document.getElementById('roleSheet').classList.remove('open'); document.getElementById('sheetBackdrop').classList.remove('open'); }
render();
</script>
</body>
</html>