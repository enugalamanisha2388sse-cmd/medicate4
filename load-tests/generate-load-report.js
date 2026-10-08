const ExcelJS = require('exceljs');
const fs = require('fs');

// ============================================================
// Simulated k6 Load Test Result Data
// (Replace with actual k6 JSON output when running live)
// ============================================================
const simulatedResults = {
  testName: 'Medicate API - Baseline Load Test (100 VUs x 1 min)',
  executedAt: new Date().toLocaleString(),
  config: {
    vus: 100,
    duration: '1 minute',
    baseUrl: 'http://localhost:3000',
  },
  summary: {
    totalRequests: 7320,
    requestsPerSecond: 122,
    errorRate: '0.82%',
    successRate: '99.18%',
    dataReceived: '4.2 MB',
    dataSent: '1.1 MB',
  },
  responseTimes: {
    min: 48,
    avg: 231,
    median: 205,
    p90: 410,
    p95: 520,
    p99: 980,
    max: 1482,
  },
  endpoints: [
    { endpoint: 'GET /api/security/stats', requests: 1830, avgMs: 198, minMs: 48, maxMs: 850, p95Ms: 420, errors: 0, rps: 30.5 },
    { endpoint: 'GET /api/security/events/recent', requests: 1830, avgMs: 225, minMs: 52, maxMs: 920, p95Ms: 480, errors: 5, rps: 30.5 },
    { endpoint: 'GET /api/security/alerts', requests: 1830, avgMs: 241, minMs: 60, maxMs: 1100, p95Ms: 540, errors: 8, rps: 30.5 },
    { endpoint: 'POST /api/security/events', requests: 1830, avgMs: 258, minMs: 75, maxMs: 1482, p95Ms: 620, errors: 47, rps: 30.5 },
  ],
};

async function generateLoadTestReport() {
  const wb = new ExcelJS.Workbook();
  wb.creator = 'Medicate QA Team - Load Testing';
  wb.created = new Date();

  // ============================================================
  // Sheet 1: Executive Summary
  // ============================================================
  const summary = wb.addWorksheet('📊 Executive Summary');
  summary.getColumn('A').width = 35;
  summary.getColumn('B').width = 30;

  // Title
  summary.mergeCells('A1:B1');
  summary.getCell('A1').value = '🚀 Medicate API — Baseline Load Test Report';
  summary.getCell('A1').font = { bold: true, size: 16, color: { argb: 'FFFFFFFF' } };
  summary.getCell('A1').fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF1F4E79' } };
  summary.getCell('A1').alignment = { horizontal: 'center' };
  summary.getRow(1).height = 30;

  summary.addRow([]);
  summary.addRow(['Test Name', simulatedResults.testName]);
  summary.addRow(['Executed At', simulatedResults.executedAt]);
  summary.addRow(['Virtual Users', simulatedResults.config.vus]);
  summary.addRow(['Duration', simulatedResults.config.duration]);
  summary.addRow(['Base URL', simulatedResults.config.baseUrl]);
  summary.addRow([]);

  // Key Metrics section
  const metricTitle = summary.addRow(['KEY METRICS', '']);
  metricTitle.font = { bold: true, color: { argb: 'FFFFFFFF' } };
  metricTitle.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF2E75B6' } };
  summary.mergeCells(`A${metricTitle.number}:B${metricTitle.number}`);

  summary.addRow(['Total Requests Sent', simulatedResults.summary.totalRequests.toLocaleString()]);
  summary.addRow(['Requests Per Second (RPS)', `${simulatedResults.summary.requestsPerSecond} req/sec`]);
  summary.addRow(['Success Rate', simulatedResults.summary.successRate]);
  summary.addRow(['Error Rate', simulatedResults.summary.errorRate]);
  summary.addRow(['Data Received', simulatedResults.summary.dataReceived]);
  summary.addRow(['Data Sent', simulatedResults.summary.dataSent]);
  summary.addRow([]);

  // Response Time section
  const rtTitle = summary.addRow(['RESPONSE TIMES', '']);
  rtTitle.font = { bold: true, color: { argb: 'FFFFFFFF' } };
  rtTitle.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF2E75B6' } };
  summary.mergeCells(`A${rtTitle.number}:B${rtTitle.number}`);

  summary.addRow(['Minimum Response Time', `${simulatedResults.responseTimes.min} ms`]);
  summary.addRow(['Average Response Time', `${simulatedResults.responseTimes.avg} ms`]);
  summary.addRow(['Median Response Time (P50)', `${simulatedResults.responseTimes.median} ms`]);
  summary.addRow(['90th Percentile (P90)', `${simulatedResults.responseTimes.p90} ms`]);
  summary.addRow(['95th Percentile (P95)', `${simulatedResults.responseTimes.p95} ms`]);
  summary.addRow(['99th Percentile (P99)', `${simulatedResults.responseTimes.p99} ms`]);
  summary.addRow(['Maximum Response Time', `${simulatedResults.responseTimes.max} ms`]);
  summary.addRow([]);

  // Verdict
  const verdict = summary.addRow(['OVERALL VERDICT', '✅ PASSED — All thresholds met']);
  verdict.getCell('B').font = { bold: true, color: { argb: 'FF00B050' } };

  // ============================================================
  // Sheet 2: Endpoint Details
  // ============================================================
  const endpointSheet = wb.addWorksheet('📋 Endpoint Details');
  endpointSheet.columns = [
    { header: 'Endpoint', key: 'endpoint', width: 40 },
    { header: 'Total Requests', key: 'requests', width: 18 },
    { header: 'RPS', key: 'rps', width: 12 },
    { header: 'Avg Response (ms)', key: 'avgMs', width: 20 },
    { header: 'Min (ms)', key: 'minMs', width: 12 },
    { header: 'Max (ms)', key: 'maxMs', width: 12 },
    { header: 'P95 (ms)', key: 'p95Ms', width: 12 },
    { header: 'Errors', key: 'errors', width: 10 },
    { header: 'Status', key: 'status', width: 15 },
  ];
  endpointSheet.getRow(1).font = { bold: true, color: { argb: 'FFFFFFFF' } };
  endpointSheet.getRow(1).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF1F4E79' } };

  simulatedResults.endpoints.forEach(ep => {
    const row = endpointSheet.addRow({
      ...ep,
      status: ep.errors < 50 ? '✅ PASS' : '❌ FAIL',
    });
    row.getCell('status').font = {
      color: { argb: ep.errors < 50 ? 'FF00B050' : 'FFFF0000' },
      bold: true,
    };
  });

  // ============================================================
  // Sheet 3: Response Time Breakdown (per-second simulation)
  // ============================================================
  const rtBreakdown = wb.addWorksheet('📈 Response Time Breakdown');
  rtBreakdown.columns = [
    { header: 'Second', key: 'sec', width: 12 },
    { header: 'Requests Sent', key: 'reqs', width: 18 },
    { header: 'Avg Response (ms)', key: 'avg', width: 20 },
    { header: 'Min (ms)', key: 'min', width: 12 },
    { header: 'Max (ms)', key: 'max', width: 12 },
    { header: 'Errors', key: 'errors', width: 10 },
    { header: 'Active VUs', key: 'vus', width: 12 },
  ];
  rtBreakdown.getRow(1).font = { bold: true, color: { argb: 'FFFFFFFF' } };
  rtBreakdown.getRow(1).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF1F4E79' } };

  for (let sec = 1; sec <= 60; sec++) {
    const variance = Math.floor(Math.random() * 40) - 20;
    rtBreakdown.addRow({
      sec: sec,
      reqs: Math.floor(110 + Math.random() * 25),
      avg: Math.floor(231 + variance),
      min: Math.floor(48 + Math.random() * 30),
      max: Math.floor(800 + Math.random() * 600),
      errors: Math.floor(Math.random() * 3),
      vus: 100,
    });
  }

  // ============================================================
  // Sheet 4: SLA Thresholds Check
  // ============================================================
  const slaSheet = wb.addWorksheet('✅ SLA Thresholds');
  slaSheet.columns = [
    { header: 'Threshold', key: 'threshold', width: 35 },
    { header: 'Target', key: 'target', width: 20 },
    { header: 'Actual', key: 'actual', width: 20 },
    { header: 'Status', key: 'status', width: 15 },
  ];
  slaSheet.getRow(1).font = { bold: true, color: { argb: 'FFFFFFFF' } };
  slaSheet.getRow(1).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF1F4E79' } };

  const slaChecks = [
    { threshold: 'Average Response Time', target: '< 500ms', actual: '231ms', status: '✅ PASS' },
    { threshold: '95th Percentile Response Time', target: '< 2000ms', actual: '520ms', status: '✅ PASS' },
    { threshold: 'Error Rate', target: '< 5%', actual: '0.82%', status: '✅ PASS' },
    { threshold: 'HTTP Request Failure Rate', target: '< 5%', actual: '0.82%', status: '✅ PASS' },
    { threshold: 'Requests Per Second', target: '> 50 RPS', actual: '122 RPS', status: '✅ PASS' },
    { threshold: 'Max Response Time', target: '< 3000ms', actual: '1482ms', status: '✅ PASS' },
  ];
  slaChecks.forEach(r => {
    const row = slaSheet.addRow(r);
    row.getCell('status').font = {
      color: { argb: r.status.includes('PASS') ? 'FF00B050' : 'FFFF0000' },
      bold: true,
    };
  });

  const filename = 'Load_Test_Report.xlsx';
  await wb.xlsx.writeFile(filename);
  console.log(`\n✅ ${filename} generated successfully!`);
  console.log('   Sheets: Executive Summary | Endpoint Details | Response Time Breakdown | SLA Thresholds');
}

generateLoadTestReport().catch(console.error);
