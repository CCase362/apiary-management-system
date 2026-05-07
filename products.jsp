/* style.css – Sunny Day Apiary Management System (v2) */



* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

body {
  font-family: 'Inter', Arial, sans-serif;
  font-size: 14px;
  background: #fdf8f0;
  color: #333;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
}

main {
  flex: 1;
}

/* ── Navbar ─────────────────────────────────────────────── */
.navbar {
  background: linear-gradient(135deg, #f5a623, #e8920f);
  padding: 0 24px;
  display: flex;
  align-items: center;
  gap: 4px;
  height: 56px;
  box-shadow: 0 2px 8px rgba(0,0,0,.15);
  position: sticky;
  top: 0;
  z-index: 100;
}

.nav-brand {
  font-size: 17px;
  font-weight: 700;
  color: #fff;
  margin-right: auto;
  letter-spacing: -0.3px;
  text-decoration: none;
}

.navbar a {
  color: rgba(255,255,255,.9);
  text-decoration: none;
  font-weight: 500;
  font-size: 13.5px;
  padding: 6px 12px;
  border-radius: 6px;
  transition: background .15s;
}

.navbar a:hover {
  background: rgba(255,255,255,.2);
  color: #fff;
}

.navbar a.active {
  background: rgba(255,255,255,.25);
  color: #fff;
  font-weight: 600;
}

.nav-logout {
  margin-left: 8px;
  border: 1.5px solid rgba(255,255,255,.7) !important;
  padding: 5px 14px !important;
  border-radius: 6px !important;
  font-size: 13px !important;
}

.nav-logout:hover {
  background: rgba(255,255,255,.25) !important;
  border-color: #fff !important;
}

/* ── Container ───────────────────────────────────────────── */
.container {
  max-width: 1100px;
  margin: 32px auto;
  padding: 0 24px;
}

/* ── Page Titles ─────────────────────────────────────────── */
h1 {
  font-size: 22px;
  font-weight: 700;
  margin-bottom: 20px;
  color: #1a1a1a;
  padding-bottom: 12px;
  border-bottom: 2px solid #f5a623;
  display: inline-block;
}

h2 {
  font-size: 16px;
  font-weight: 600;
  margin-bottom: 14px;
  color: #333;
}

/* ── Stat Cards (Dashboard) ──────────────────────────────── */
.stat-row {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 16px;
  margin-bottom: 32px;
}

.stat-card {
  background: #fff;
  border-radius: 10px;
  padding: 20px 22px;
  box-shadow: 0 1px 4px rgba(0,0,0,.08);
  border-left: 4px solid #f5a623;
  display: flex;
  align-items: center;
  gap: 14px;
}

.stat-card-icon {
  font-size: 28px;
  line-height: 1;
}

.stat-card-body {
  display: flex;
  flex-direction: column;
}

.stat-card-value {
  font-size: 22px;
  font-weight: 700;
  color: #1a1a1a;
  line-height: 1;
}

.stat-card-label {
  font-size: 12px;
  color: #888;
  margin-top: 3px;
  font-weight: 500;
}

/* ── Login ───────────────────────────────────────────────── */
.login-container {
  max-width: 380px;
  margin: 80px auto;
  background: #fff;
  padding: 36px 32px;
  border-radius: 12px;
  box-shadow: 0 4px 24px rgba(0,0,0,.10);
  text-align: center;
}

.login-container h1 {
  font-size: 24px;
  margin-bottom: 4px;
  border: none;
  display: block;
  padding-bottom: 0;
}

.login-container h2 {
  font-size: 14px;
  font-weight: 400;
  color: #888;
  margin-bottom: 24px;
}

.login-container form {
  display: flex;
  flex-direction: column;
  gap: 14px;
  text-align: left;
}

.login-container label {
  font-size: 13px;
  font-weight: 600;
  color: #555;
  display: flex;
  flex-direction: column;
  gap: 5px;
  margin-bottom: 0;
}

/* ── Inputs ──────────────────────────────────────────────── */
input[type="text"],
input[type="email"],
input[type="password"],
input[type="number"],
input[type="date"],
select,
textarea {
  width: 100%;
  padding: 8px 11px;
  border: 1.5px solid #ddd;
  border-radius: 6px;
  font-size: 13.5px;
  font-family: 'Inter', Arial, sans-serif;
  transition: border-color .15s, box-shadow .15s;
  background: #fff;
}

input:focus, select:focus, textarea:focus {
  outline: none;
  border-color: #f5a623;
  box-shadow: 0 0 0 3px rgba(245,166,35,.15);
}

textarea {
  resize: vertical;
}

/* ── Buttons ─────────────────────────────────────────────── */
button,
.btn-primary {
  padding: 9px 20px;
  background: #f5a623;
  color: #fff;
  border: none;
  border-radius: 6px;
  font-size: 13.5px;
  font-weight: 600;
  cursor: pointer;
  font-family: 'Inter', Arial, sans-serif;
  transition: background .15s, transform .1s;
}

button:hover,
.btn-primary:hover {
  background: #d4881a;
  transform: translateY(-1px);
}

button:active,
.btn-primary:active {
  transform: translateY(0);
}

.btn-toggle {
  background: transparent;
  color: #f5a623;
  border: 1.5px solid #f5a623;
  padding: 7px 16px;
  font-size: 13px;
  margin-bottom: 0;
}

.btn-toggle:hover {
  background: #fff8ec;
  transform: none;
}

/* ── Tables ──────────────────────────────────────────────── */
.data-table {
  width: 100%;
  border-collapse: collapse;
  background: #fff;
  border-radius: 10px;
  overflow: hidden;
  box-shadow: 0 1px 6px rgba(0,0,0,.08);
  margin-bottom: 28px;
}

.data-table thead {
  background: linear-gradient(135deg, #f5a623, #e8920f);
  color: #fff;
}

.data-table th {
  padding: 11px 15px;
  text-align: left;
  font-size: 12.5px;
  font-weight: 600;
  letter-spacing: 0.3px;
  text-transform: uppercase;
}

.data-table td {
  padding: 11px 15px;
  border-bottom: 1px solid #f0ece4;
  font-size: 13.5px;
}

.data-table tbody tr:last-child td {
  border-bottom: none;
}

.data-table tbody tr:hover {
  background: #fffbf2;
}

.low-stock {
  color: #c0392b;
  font-weight: 600;
}

/* ── Badges ──────────────────────────────────────────────── */
.badge {
  padding: 3px 10px;
  border-radius: 20px;
  font-size: 11.5px;
  font-weight: 600;
  text-transform: capitalize;
  display: inline-block;
}

.badge-active    { background: #d4edda; color: #155724; }
.badge-inactive  { background: #f8d7da; color: #721c24; }
.badge-queenless { background: #fff3cd; color: #856404; }
.badge-pending   { background: #fff3cd; color: #856404; }
.badge-shipped   { background: #cce5ff; color: #004085; }
.badge-delivered { background: #d4edda; color: #155724; }
.badge-cancelled { background: #f8d7da; color: #721c24; }

/* ── Health Rating Badges ────────────────────────────────── */
.health-badge {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 28px;
  height: 28px;
  border-radius: 50%;
  font-size: 12px;
  font-weight: 700;
  color: #fff;
}

.health-high { background: #28a745; }
.health-mid  { background: #ffc107; color: #333; }
.health-low  { background: #dc3545; }

/* ── Forms ───────────────────────────────────────────────── */
.form-section {
  background: #fff;
  padding: 24px;
  border-radius: 10px;
  box-shadow: 0 1px 6px rgba(0,0,0,.08);
  margin-top: 8px;
}

.form-section-header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 0;
}

.form-section-header h2 {
  margin-bottom: 0;
}

.form-body {
  margin-top: 18px;
}

.form-row {
  display: flex;
  gap: 16px;
  margin-bottom: 14px;
  flex-wrap: wrap;
}

.form-row label {
  flex: 1;
  min-width: 160px;
  font-size: 13px;
  font-weight: 600;
  color: #555;
  display: flex;
  flex-direction: column;
  gap: 5px;
  margin-bottom: 0;
}

label {
  font-size: 13px;
  font-weight: 600;
  color: #555;
  display: flex;
  flex-direction: column;
  gap: 5px;
  margin-bottom: 14px;
}

/* ── Dashboard Cards ─────────────────────────────────────── */
.card-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
  gap: 16px;
  margin-top: 8px;
}

.card {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 10px;
  background: #fff;
  border-radius: 10px;
  padding: 28px 20px;
  text-decoration: none;
  color: #333;
  font-weight: 600;
  font-size: 14px;
  box-shadow: 0 1px 6px rgba(0,0,0,.08);
  transition: box-shadow .2s, transform .2s;
  border-bottom: 3px solid transparent;
}

.card:hover {
  box-shadow: 0 6px 18px rgba(0,0,0,.12);
  transform: translateY(-3px);
  border-bottom-color: #f5a623;
}

.card-icon {
  font-size: 34px;
}

/* ── Error / Messages ────────────────────────────────────── */
.error {
  color: #721c24;
  background: #f8d7da;
  border: 1px solid #f5c6cb;
  padding: 10px 14px;
  border-radius: 6px;
  margin-bottom: 16px;
  font-size: 13.5px;
}

/* ── Footer ──────────────────────────────────────────────── */
.footer {
  text-align: center;
  padding: 16px;
  font-size: 12px;
  color: #aaa;
  border-top: 1px solid #ede8df;
  margin-top: 40px;
}

/* ── Export Button ───────────────────────────────────────── */
.btn-export {
  display: inline-block;
  padding: 7px 16px;
  background: #fff;
  color: #f5a623;
  border: 1.5px solid #f5a623;
  border-radius: 6px;
  font-size: 13px;
  font-weight: 600;
  text-decoration: none;
  transition: background .15s;
}
.btn-export:hover { background: #fff8ec; }

/* ── Delete Button ───────────────────────────────────────── */
.btn-delete {
  padding: 5px 12px;
  background: #fff;
  color: #dc3545;
  border: 1.5px solid #dc3545;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
  cursor: pointer;
  transition: background .15s;
}
.btn-delete:hover {
  background: #fdf0f0;
  transform: none;
}
