<%-- charts.jsp --%>
<%@ page contentType="text/html;charset=UTF-8" import="java.util.*" %>
<%
  if (session.getAttribute("userId") == null) {
      response.sendRedirect("login.jsp");
      return;
  }

  List<String>  hiveLabels  = (List<String>)  request.getAttribute("hiveLabels");
  List<Double>  hiveHealths = (List<Double>)  request.getAttribute("hiveHealths");
  List<String>  monthLabels = (List<String>)  request.getAttribute("monthLabels");
  List<Integer> monthCounts = (List<Integer>) request.getAttribute("monthCounts");
  List<String>  stockLabels = (List<String>)  request.getAttribute("stockLabels");
  List<Integer> stockCounts = (List<Integer>) request.getAttribute("stockCounts");

  // Build JSON arrays for Chart.js
  StringBuilder hiveLabelJson  = new StringBuilder("[");
  StringBuilder hiveHealthJson = new StringBuilder("[");
  if (hiveLabels != null) {
    for (int i = 0; i < hiveLabels.size(); i++) {
      if (i > 0) { hiveLabelJson.append(","); hiveHealthJson.append(","); }
      hiveLabelJson.append("\"").append(hiveLabels.get(i)).append("\"");
      hiveHealthJson.append(hiveHealths.get(i));
    }
  }
  hiveLabelJson.append("]");
  hiveHealthJson.append("]");

  StringBuilder monthLabelJson = new StringBuilder("[");
  StringBuilder monthCountJson = new StringBuilder("[");
  if (monthLabels != null) {
    for (int i = 0; i < monthLabels.size(); i++) {
      if (i > 0) { monthLabelJson.append(","); monthCountJson.append(","); }
      monthLabelJson.append("\"").append(monthLabels.get(i)).append("\"");
      monthCountJson.append(monthCounts.get(i));
    }
  }
  monthLabelJson.append("]");
  monthCountJson.append("]");

  StringBuilder stockLabelJson = new StringBuilder("[");
  StringBuilder stockCountJson = new StringBuilder("[");
  if (stockLabels != null) {
    for (int i = 0; i < stockLabels.size(); i++) {
      if (i > 0) { stockLabelJson.append(","); stockCountJson.append(","); }
      stockLabelJson.append("\"").append(stockLabels.get(i)).append("\"");
      stockCountJson.append(stockCounts.get(i));
    }
  }
  stockLabelJson.append("]");
  stockCountJson.append("]");
%>
<!DOCTYPE html>
<html>
<head>
  <title>Charts – Sunny Day Apiary</title>
  <link rel="stylesheet" href="css/style.css">
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
  <style>
    .chart-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(480px, 1fr));
      gap: 24px;
      margin-top: 8px;
    }
    .chart-card {
      background: #fff;
      border-radius: 10px;
      padding: 24px;
      box-shadow: 0 1px 6px rgba(0,0,0,.08);
    }
    .chart-card h2 {
      margin-bottom: 16px;
      font-size: 15px;
      color: #444;
    }
    .chart-wrapper {
      position: relative;
      height: 260px;
    }
  </style>
</head>
<body>
  <%@ include file="navbar.jsp" %>
  <main class="container">
    <h1>Apiary Analytics</h1>

    <div class="chart-grid">

      <!-- Chart 1: Avg health rating per hive -->
      <div class="chart-card">
        <h2>Average Health Rating by Hive</h2>
        <div class="chart-wrapper">
          <canvas id="healthChart"></canvas>
        </div>
      </div>

      <!-- Chart 2: Inspections per month -->
      <div class="chart-card">
        <h2>Inspections Per Month</h2>
        <div class="chart-wrapper">
          <canvas id="monthChart"></canvas>
        </div>
      </div>

      <!-- Chart 3: Product stock by category -->
      <div class="chart-card">
        <h2>Product Stock by Category</h2>
        <div class="chart-wrapper">
          <canvas id="stockChart"></canvas>
        </div>
      </div>

    </div>
  </main>
  <footer class="footer">Sunny Day Apiary Management System &copy; 2025</footer>

  <script>
    const amberGradient = (ctx) => {
      const g = ctx.createLinearGradient(0, 0, 0, 260);
      g.addColorStop(0, 'rgba(245,166,35,0.85)');
      g.addColorStop(1, 'rgba(245,166,35,0.25)');
      return g;
    };

    // Chart 1 – Health ratings
    const hCtx = document.getElementById('healthChart').getContext('2d');
    new Chart(hCtx, {
      type: 'bar',
      data: {
        labels: <%= hiveLabelJson %>,
        datasets: [{
          label: 'Avg Health (1–10)',
          data: <%= hiveHealthJson %>,
          backgroundColor: amberGradient(hCtx),
          borderColor: '#f5a623',
          borderWidth: 2,
          borderRadius: 6
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          y: { min: 0, max: 10, ticks: { stepSize: 2 } }
        },
        plugins: { legend: { display: false } }
      }
    });

    // Chart 2 – Inspections per month
    const mCtx = document.getElementById('monthChart').getContext('2d');
    new Chart(mCtx, {
      type: 'line',
      data: {
        labels: <%= monthLabelJson %>,
        datasets: [{
          label: 'Inspections',
          data: <%= monthCountJson %>,
          backgroundColor: 'rgba(245,166,35,0.15)',
          borderColor: '#f5a623',
          borderWidth: 2,
          pointBackgroundColor: '#f5a623',
          fill: true,
          tension: 0.35
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        scales: {
          y: { beginAtZero: true, ticks: { stepSize: 1 } }
        },
        plugins: { legend: { display: false } }
      }
    });

    // Chart 3 – Stock by category
    const sCtx = document.getElementById('stockChart').getContext('2d');
    new Chart(sCtx, {
      type: 'doughnut',
      data: {
        labels: <%= stockLabelJson %>,
        datasets: [{
          data: <%= stockCountJson %>,
          backgroundColor: ['#f5a623','#e8920f','#ffc86b','#d4881a','#ffdf99'],
          borderWidth: 2,
          borderColor: '#fff'
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: { position: 'bottom' }
        }
      }
    });
  </script>
</body>
</html>
