export const PAGE_CSS = `
  @import url('https://fonts.googleapis.com/css2?family=Fraunces:opsz,wght@9..144,400;9..144,500;9..144,600&family=Public+Sans:wght@400;500;600;700&family=IBM+Plex+Mono:wght@400;500&display=swap');

  :root{
    --page:        #f9f9f7;
    --surface:     #fcfcfb;
    --surface-2:   #f2f1ec;
    --ink:         #0b0b0b;
    --ink-2:       #52514e;
    --ink-muted:   #898781;
    --grid:        #e1e0d9;
    --border:      rgba(11,11,11,0.10);
    --accent:      #163a52;
    --accent-soft: #e7edf1;
    --good:        #0ca30c;
    --bad:         #b53f2f;
  }
  @media (prefers-color-scheme: dark){
    :root:not([data-theme="light"]){
      color-scheme: dark;
      --page:        #0d0d0d;
      --surface:     #1a1a19;
      --surface-2:   #212120;
      --ink:         #ffffff;
      --ink-2:       #c3c2b7;
      --ink-muted:   #898781;
      --grid:        #2c2c2a;
      --border:      rgba(255,255,255,0.12);
      --accent:      #7fa8c4;
      --accent-soft: #16242e;
      --good:        #0ca30c;
      --bad:         #e08877;
    }
  }
  :root[data-theme="dark"]{
    color-scheme: dark;
    --page:        #0d0d0d;
    --surface:     #1a1a19;
    --surface-2:   #212120;
    --ink:         #ffffff;
    --ink-2:       #c3c2b7;
    --ink-muted:   #898781;
    --grid:        #2c2c2a;
    --border:      rgba(255,255,255,0.12);
    --accent:      #7fa8c4;
    --accent-soft: #16242e;
    --good:        #0ca30c;
    --bad:         #e08877;
  }

  *{ box-sizing:border-box; }
  html,body{ background:var(--page); }
  body{ margin:0; color:var(--ink); font-family:'Public Sans', system-ui, sans-serif; font-size:15px; line-height:1.55; }
  .wrap{ max-width:980px; margin:0 auto; padding:36px 20px 80px; }

  h1,h2,h3{ font-family:'Fraunces', Georgia, serif; text-wrap:balance; margin:0; }
  header.top{ border-bottom:2px solid var(--ink); padding-bottom:18px; margin-bottom:28px; }
  .eyebrow{ font-family:'IBM Plex Mono', monospace; font-size:11px; letter-spacing:.08em; text-transform:uppercase; color:var(--ink-muted); margin-bottom:10px; }
  h1{ font-size:30px; font-weight:600; margin-bottom:6px; }
  .subhead{ color:var(--ink-2); font-size:15px; max-width:66ch; }
  .meta-row{ display:flex; flex-wrap:wrap; gap:8px 18px; margin-top:14px; font-family:'IBM Plex Mono', monospace; font-size:12px; color:var(--ink-muted); }
  .meta-row b{ color:var(--ink-2); font-weight:500; }

  section{ margin-bottom:38px; }
  .section-label{ font-family:'IBM Plex Mono', monospace; font-size:11px; letter-spacing:.08em; text-transform:uppercase; color:var(--ink-muted); margin-bottom:4px; }
  h2{ font-size:20px; font-weight:600; margin-bottom:4px; }
  .section-note{ color:var(--ink-2); font-size:13.5px; max-width:70ch; margin-bottom:18px; }

  .card{ background:var(--surface); border:1px solid var(--border); border-radius:6px; padding:18px 20px; }
  .card p{ margin:0 0 8px; color:var(--ink-2); font-size:13.8px; }
  .card p:last-child{ margin-bottom:0; }
  .card p b{ color:var(--ink); font-weight:600; }

  table{ width:100%; border-collapse:collapse; font-size:13.5px; }
  .table-scroll{ overflow-x:auto; }
  th,td{ text-align:left; padding:9px 10px; border-bottom:1px solid var(--grid); white-space:nowrap; }
  th{ font-family:'IBM Plex Mono', monospace; font-size:10.5px; letter-spacing:.04em; text-transform:uppercase; color:var(--ink-muted); font-weight:500; }
  td.num, th.num{ font-family:'IBM Plex Mono', monospace; font-variant-numeric:tabular-nums; text-align:right; }
  td.fig{ color:var(--ink-2); font-size:12.5px; }
  .fig-inline{ display:block; color:var(--ink-muted); font-size:11px; }
  .delta{ font-family:'IBM Plex Mono', monospace; font-size:12px; }
  .delta.up{ color:var(--good); }
  .delta.down{ color:var(--bad); }
  .delta.flat{ color:var(--ink-muted); }
  tr.log-row td{ white-space:normal; }
  .tag{ display:inline-block; font-family:'IBM Plex Mono', monospace; font-size:10px; padding:1px 6px; border-radius:4px; background:var(--surface-2); color:var(--ink-muted); margin-left:4px; }
  .sum-note{ margin-top:10px; font-size:12.5px; color:var(--ink-muted); }
  .sum-note strong{ color:var(--ink-2); font-family:'IBM Plex Mono', monospace; }

  .read-list{ display:flex; flex-direction:column; gap:12px; }
  .read-item{ display:flex; gap:12px; }
  .read-num{ font-family:'IBM Plex Mono', monospace; font-size:11px; color:var(--accent); background:var(--accent-soft); border-radius:4px; width:22px; height:22px; display:flex; align-items:center; justify-content:center; flex-shrink:0; margin-top:1px; }
  .read-item p{ margin:0; color:var(--ink-2); font-size:13.8px; }
  .read-item p b{ color:var(--ink); font-weight:600; }

  footer{ margin-top:44px; padding-top:16px; border-top:1px solid var(--grid); }
  footer p{ color:var(--ink-muted); font-size:12px; max-width:74ch; margin:0 0 8px; }
  footer code{ font-family:'IBM Plex Mono', monospace; background:var(--surface-2); padding:1px 5px; border-radius:3px; font-size:11px; }
  .sources{ font-size:12px; color:var(--ink-muted); }
  .sources a{ color:var(--ink-2); }
  .sources li{ margin-bottom:3px; }

  /* --- petits multiples : graphiques par bloc --------------------------- */
  .charts-grid{ display:grid; grid-template-columns:repeat(auto-fit, minmax(280px,1fr)); gap:16px; }
  .bloc-chart{ background:var(--surface); border:1px solid var(--border); border-radius:6px; padding:14px 14px 10px; margin:0; }
  .bloc-chart{ --c: var(--light); }
  @media (prefers-color-scheme: dark){ :root:not([data-theme="light"]) .bloc-chart{ --c: var(--dark); } }
  :root[data-theme="dark"] .bloc-chart{ --c: var(--dark); }
  .bloc-chart figcaption{ margin-bottom:4px; font-size:13.5px; }
  .bloc-chart figcaption strong{ color:var(--ink); }
  .bloc-chart figcaption .fig{ display:block; color:var(--ink-muted); font-size:11px; margin-top:1px; }
  .bloc-chart svg{ width:100%; height:auto; display:block; margin-top:6px; }
  .grid-line{ stroke:var(--grid); stroke-width:1; }
  .axis-label{ font-family:'IBM Plex Mono', monospace; font-size:7.5px; fill:var(--ink-muted); }
  .point-label{ font-family:'IBM Plex Mono', monospace; font-size:9px; font-weight:600; fill:var(--ink); }
  .band{ fill:var(--c); fill-opacity:0.16; stroke:none; }
  .band-proj{ fill-opacity:0.09; }
  .mean-line{ fill:none; stroke:var(--c); stroke-width:2; stroke-linecap:round; stroke-linejoin:round; }
  .mean-line-proj{ stroke-dasharray:3 3; }
  .raw-dot{ fill:var(--c); stroke:var(--surface); stroke-width:1; }
  .proj-dot{ fill:var(--surface); stroke:var(--c); stroke-width:1.6; }
  .raw-range{ stroke:var(--ink-muted); stroke-width:1.3; opacity:0.55; }
  .q-note{ margin-top:6px; font-family:'IBM Plex Mono', monospace; font-size:10px; color:var(--ink-muted); }

  /* --- graphe de synthèse : toutes les courbes superposées --------------- */
  .synthesis-card{ background:var(--surface); border:1px solid var(--border); border-radius:6px; padding:18px 20px 12px; }
  .synthesis-card svg{ width:100%; height:auto; display:block; }
  .axis-label-lg{ font-family:'IBM Plex Mono', monospace; font-size:11px; fill:var(--ink-muted); }
  .synth-series{ --c: var(--light); }
  @media (prefers-color-scheme: dark){ :root:not([data-theme="light"]) .synth-series{ --c: var(--dark); } }
  :root[data-theme="dark"] .synth-series{ --c: var(--dark); }
  .synth-line{ fill:none; stroke:var(--c); stroke-width:2.6; stroke-linecap:round; stroke-linejoin:round; }
  .synth-line-proj{ stroke-dasharray:4 4; }
  .synth-dot{ fill:var(--c); stroke:var(--surface); stroke-width:1.4; }
  .synth-leader{ stroke:var(--c); stroke-width:1; opacity:0.45; }
  .synth-label{ font-family:'IBM Plex Mono', monospace; font-size:11px; font-weight:600; fill:var(--c); }

  @media (max-width:640px){ th,td{ font-size:12.5px; } }
`;
