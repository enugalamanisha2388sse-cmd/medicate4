/**
 * appium-tests/generate-report.js
 * Generates SmartMed_Appium_E2E_TestReport_<date>.xlsx
 * Complete 300+ Appium test case report for Flutter App E2E Testing
 *
 * Usage: node generate-report.js
 */

'use strict';

const ExcelJS = require('exceljs');
const path    = require('path');
const fs      = require('fs');

// Extract ALL_TC from build-tests.js
const buildScriptPath = path.join(__dirname, 'build-tests.js');
const buildScriptContent = fs.readFileSync(buildScriptPath, 'utf8');

const startIdx = buildScriptContent.indexOf('const ALL_TC = [');
const endIdx = buildScriptContent.indexOf('];', startIdx) + 2;
const tcArrayCode = buildScriptContent.slice(startIdx, endIdx).replace('const ALL_TC', 'ALL_TC');

let ALL_TC = [];
eval(tcArrayCode);

async function generateReport() {
  console.log(`\n======================================================`);
  console.log(`📱 SmartMed Appium Mobile App E2E Test Report Generator`);
  console.log(`======================================================\n`);
  console.log(`Loaded ${ALL_TC.length} Appium test cases from build-tests.js`);

  const passed  = ALL_TC.filter(r => r.status === 'PASS').length;
  const failed  = ALL_TC.filter(r => r.status === 'FAIL').length;
  const skipped = ALL_TC.filter(r => r.status === 'SKIP').length;
  const total   = ALL_TC.length;
  const passRate = total > 0 ? ((passed / total) * 100).toFixed(1) : '0.0';

  const wb = new ExcelJS.Workbook();
  wb.creator = 'SmartMed Mobile QA Team';
  wb.created = new Date();

  // Styling palette
  const headerFill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FF0F2B4E' } }; // Deep Navy
  const headerFont = { bold: true, color: { argb: 'FFFFFFFF' }, size: 11, name: 'Calibri' };
  const centerAlign = { horizontal: 'center', vertical: 'middle' };

  // ── 1. Summary Sheet ────────────────────────────────────────────────────────
  const summaryWs = wb.addWorksheet('📋 Test Summary');

  summaryWs.mergeCells('A1:G1');
  const titleCell = summaryWs.getCell('A1');
  titleCell.value = 'SmartMed Mobile App - Appium E2E Test Summary';
  titleCell.font = { bold: true, size: 18, color: { argb: 'FF0F2B4E' }, name: 'Calibri' };
  titleCell.alignment = centerAlign;
  summaryWs.getRow(1).height = 44;

  summaryWs.mergeCells('A2:G2');
  const subCell = summaryWs.getCell('A2');
  subCell.value = `Generated: ${new Date().toLocaleString()} | Appium 2.x + WebdriverIO + Mocha + Chai | Target: Flutter Android/iOS App`;
  subCell.font = { italic: true, color: { argb: 'FF555555' }, size: 10 };
  subCell.alignment = centerAlign;

  summaryWs.addRow([]);

  const metrics = [
    ['Metric', 'Value', '', 'Metric', 'Value'],
    ['Total Test Cases', total, '', 'Pass Rate', `${passRate}%`],
    ['Passed Tests', passed, '', 'Platform', 'Flutter (Android/iOS)'],
    ['Failed Tests', failed, '', 'Test Engine', 'Appium 2.x / WebdriverIO'],
    ['Skipped Tests', skipped, '', 'Runner', 'Mocha + Chai BDD'],
  ];

  metrics.forEach((row, idx) => {
    const r = summaryWs.addRow(row);
    if (idx === 0) {
      [1, 2, 4, 5].forEach(colIdx => {
        r.getCell(colIdx).fill = headerFill;
        r.getCell(colIdx).font = headerFont;
        r.getCell(colIdx).alignment = centerAlign;
      });
    } else {
      [1, 4].forEach(colIdx => { r.getCell(colIdx).font = { bold: true }; });
      r.getCell(2).font = { bold: true, color: { argb: 'FF2563EB' } };
      r.getCell(5).font = { bold: true, color: { argb: 'FF0F2B4E' } };
    }
    r.height = 24;
  });

  summaryWs.addRow([]);

  const suiteHeader = summaryWs.addRow(['Test Suite', 'Total TCs', 'Passed', 'Failed', 'Skipped', 'Pass Rate %', 'Health Status']);
  suiteHeader.eachCell(c => { c.fill = headerFill; c.font = headerFont; c.alignment = centerAlign; });
  suiteHeader.height = 26;

  const suites = [...new Set(ALL_TC.map(r => r.suite))];
  suites.forEach((suite, idx) => {
    const suiteTCs = ALL_TC.filter(r => r.suite === suite);
    const sp = suiteTCs.filter(r => r.status === 'PASS').length;
    const sf = suiteTCs.filter(r => r.status === 'FAIL').length;
    const sk = suiteTCs.filter(r => r.status === 'SKIP').length;
    const pr = ((sp / suiteTCs.length) * 100).toFixed(0);
    const health = sf === 0 && sk === 0 ? '🟢 Healthy' : sf === 0 ? '🟡 Partial' : '🔴 Review';

    const row = summaryWs.addRow([suite, suiteTCs.length, sp, sf, sk, `${pr}%`, health]);
    row.getCell(3).font = { color: { argb: 'FF16A34A' }, bold: true };
    row.getCell(4).font = { color: { argb: 'FFDC2626' }, bold: true };
    row.getCell(5).font = { color: { argb: 'FF92400E' } };
    row.getCell(7).font = { bold: true };
    row.eachCell(c => {
      c.alignment = centerAlign;
      c.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: idx % 2 === 0 ? 'FFF0F4FA' : 'FFFFFFFF' } };
      c.border = { bottom: { style: 'hair', color: { argb: 'FFDDDDDD' } } };
    });
    row.height = 22;
  });

  ['A','B','C','D','E','F','G'].forEach((colLetter, idx) => {
    summaryWs.getColumn(colLetter).width = [42, 12, 10, 10, 10, 14, 16][idx];
  });

  // ── 2. All Test Cases Sheet ──────────────────────────────────────────────────
  const detailWs = wb.addWorksheet('📄 All Test Cases', { views: [{ state: 'frozen', ySplit: 1 }] });
  detailWs.columns = [
    { header: '#',                     key: 'id',     width: 6  },
    { header: 'TC ID',                 key: 'tcId',   width: 15 },
    { header: 'Appium Test Suite',     key: 'suite',  width: 35 },
    { header: 'Test Case Title',       key: 'title',  width: 60 },
    { header: 'Target Role',           key: 'role',   width: 14 },
    { header: 'Status',                key: 'status', width: 12 },
    { header: 'Expected Result / Technical Notes', key: 'notes', width: 55 },
  ];

  const detailHeader = detailWs.getRow(1);
  detailHeader.eachCell(c => { c.fill = headerFill; c.font = headerFont; c.alignment = centerAlign; });
  detailHeader.height = 28;

  ALL_TC.forEach((tc, idx) => {
    const row = detailWs.addRow({
      id: idx + 1,
      tcId: tc.tcId,
      suite: tc.suite,
      title: tc.title,
      role: tc.role.toUpperCase(),
      status: tc.status,
      notes: tc.notes
    });
    row.height = 20;

    const statusCell = row.getCell('status');
    if (tc.status === 'PASS') {
      statusCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFD1FAE5' } };
      statusCell.font = { color: { argb: 'FF065F46' }, bold: true };
    } else if (tc.status === 'FAIL') {
      statusCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFFEE2E2' } };
      statusCell.font = { color: { argb: 'FF7F1D1D' }, bold: true };
    } else {
      statusCell.fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFFFF3CD' } };
      statusCell.font = { color: { argb: 'FF92400E' }, bold: true };
    }
    statusCell.alignment = centerAlign;

    row.getCell('id').alignment = centerAlign;
    row.getCell('tcId').alignment = centerAlign;
    row.getCell('role').alignment = centerAlign;
    row.eachCell(c => { c.border = { bottom: { style: 'hair', color: { argb: 'FFDDDDDD' } } }; });
  });

  detailWs.autoFilter = { from: 'A1', to: 'G1' };

  // ── 3. Suite Breakdown Sheet ─────────────────────────────────────────────────
  const breakdownWs = wb.addWorksheet('📊 Suite Breakdown');
  breakdownWs.columns = [
    { header: 'Suite Name',     key: 'suite',  width: 40 },
    { header: 'Total TCs',      key: 'total',  width: 12 },
    { header: 'Passed',         key: 'pass',   width: 12 },
    { header: 'Failed',         key: 'fail',   width: 12 },
    { header: 'Skipped',        key: 'skip',   width: 12 },
    { header: 'Pass Rate',      key: 'rate',   width: 14 },
    { header: 'Health Status',  key: 'health', width: 16 },
  ];

  const breakdownHeader = breakdownWs.getRow(1);
  breakdownHeader.eachCell(c => { c.fill = headerFill; c.font = headerFont; c.alignment = centerAlign; });
  breakdownHeader.height = 26;

  suites.forEach(suite => {
    const suiteTCs = ALL_TC.filter(r => r.suite === suite);
    const sp = suiteTCs.filter(r => r.status === 'PASS').length;
    const sf = suiteTCs.filter(r => r.status === 'FAIL').length;
    const sk = suiteTCs.filter(r => r.status === 'SKIP').length;
    const rate = ((sp / suiteTCs.length) * 100).toFixed(1);
    const health = sf === 0 && sk === 0 ? '🟢 Healthy' : sf === 0 ? '🟡 Partial' : '🔴 Review';

    const row = breakdownWs.addRow({
      suite,
      total: suiteTCs.length,
      pass: sp,
      fail: sf,
      skip: sk,
      rate: `${rate}%`,
      health
    });

    row.getCell('pass').font = { color: { argb: 'FF16A34A' }, bold: true };
    row.getCell('fail').font = { color: { argb: 'FFDC2626' }, bold: true };
    row.getCell('skip').font = { color: { argb: 'FF92400E' } };
    row.getCell('rate').font = { color: { argb: 'FF2563EB' }, bold: true };
    row.eachCell(c => { c.alignment = centerAlign; c.border = { bottom: { style: 'hair', color: { argb: 'FFDDDDDD' } } }; });
    row.height = 22;
  });

  const outDir = path.join(__dirname, 'reports');
  if (!fs.existsSync(outDir)) fs.mkdirSync(outDir, { recursive: true });
  const ts = new Date().toISOString().slice(0, 10);
  const outPath = path.join(outDir, `SmartMed_Appium_E2E_TestReport_${ts}.xlsx`);

  await wb.xlsx.writeFile(outPath);
  console.log(`\n✅ Appium Excel report generated successfully!`);
  console.log(`📊 File: ${outPath}`);
  console.log(`📈 Total: ${total} | ✅ Pass: ${passed} | ❌ Fail: ${failed} | ⏭ Skip: ${skipped} | Rate: ${passRate}%\n`);
}

generateReport().catch(err => {
  console.error('❌ Report generation failed:', err);
  process.exit(1);
});
