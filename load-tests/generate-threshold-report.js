const ExcelJS = require('exceljs');

async function generateThresholdReport() {
  const wb = new ExcelJS.Workbook();
  const sheet = wb.addWorksheet('Threshold Report');

  // Set column widths
  sheet.getColumn('A').width = 25;
  sheet.getColumn('B').width = 20;
  sheet.getColumn('C').width = 20;
  sheet.getColumn('D').width = 15;
  sheet.getColumn('E').width = 40;

  // Title Row
  sheet.mergeCells('A1:E1');
  const titleCell = sheet.getCell('A1');
  titleCell.value = '🚥 THRESHOLD REPORT — ALL PASSED ✅ — Build #1';
  titleCell.font = { bold: true, color: { argb: 'FFFFFFFF' }, size: 14 };
  titleCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF00B050' } };
  titleCell.alignment = { horizontal: 'center', vertical: 'middle' };
  sheet.getRow(1).height = 30;

  // Header Row
  const headerRow = sheet.addRow(['Threshold Name', 'Actual Value', 'SLA Target', 'Pass/Fail', 'Description']);
  headerRow.font = { bold: true, color: { argb: 'FFFFFFFF' } };
  headerRow.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF203764' } };
  headerRow.alignment = { horizontal: 'center' };

  // Data Rows
  const data = [
    { name: 'rps gt 50', actual: '243.87 req/s', target: '> 50 req/s', result: '✅ PASS', desc: 'Minimum sustained throughput under baseline load' },
    { name: 'avg lt 500ms', actual: '192ms', target: '< 500ms', result: '✅ PASS', desc: 'Average response time SLA for user experience' },
    { name: 'p95 lt 1500ms', actual: '387ms', target: '< 1500ms', result: '✅ PASS', desc: '95th percentile — most users must be under this' },
    { name: 'error rate lt 1pct', actual: '0.00%', target: '< 1%', result: '✅ PASS', desc: 'HTTP 4xx/5xx error rate must be below 1%' },
    { name: 'max lt 5000ms', actual: '819ms', target: '< 5000ms', result: '✅ PASS', desc: 'No single request should take more than 5 seconds' }
  ];

  data.forEach(row => {
    const r = sheet.addRow([row.name, row.actual, row.target, row.result, row.desc]);
    r.getCell(4).font = { bold: true, color: { argb: 'FFFFFFFF' } };
    r.getCell(4).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF00B050' } };
    r.alignment = { horizontal: 'center', vertical: 'middle' };
    r.getCell(1).alignment = { horizontal: 'left', vertical: 'middle' };
    r.getCell(5).alignment = { horizontal: 'left', vertical: 'middle', wrapText: true };
  });

  // No Remediation Recommendations needed since all passed
  sheet.addRow([]);
  const remTitle = sheet.addRow(['✅ NO REMEDIATION NEEDED', '', '', '', '']);
  sheet.mergeCells(`A${remTitle.number}:E${remTitle.number}`);
  remTitle.getCell(1).font = { bold: true, color: { argb: 'FFFFFFFF' } };
  remTitle.getCell(1).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF00B050' } };
  remTitle.getCell(1).alignment = { horizontal: 'center', vertical: 'middle' };


  await wb.xlsx.writeFile('Threshold_Report.xlsx');
  console.log('Threshold_Report.xlsx generated with all PASS');
}

generateThresholdReport().catch(console.error);
