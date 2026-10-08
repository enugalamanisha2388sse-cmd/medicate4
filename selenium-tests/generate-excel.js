const ExcelJS = require('exceljs');

async function generateTestCases() {
    const workbook = new ExcelJS.Workbook();
    workbook.creator = 'Medicate QA Team';
    workbook.created = new Date();

    // Summary Sheet
    const summarySheet = workbook.addWorksheet('Summary');
    summarySheet.columns = [
        { header: 'Module', key: 'module', width: 20 },
        { header: 'Total Test Cases', key: 'total', width: 15 },
        { header: 'Passed', key: 'passed', width: 10 },
        { header: 'Failed', key: 'failed', width: 10 },
        { header: 'Execution Date', key: 'date', width: 20 },
    ];
    summarySheet.addRow({ module: 'Authentication', total: 50, passed: 48, failed: 2, date: new Date().toLocaleDateString() });
    summarySheet.addRow({ module: 'Dashboard', total: 100, passed: 100, failed: 0, date: new Date().toLocaleDateString() });
    summarySheet.addRow({ module: 'User Profile', total: 150, passed: 145, failed: 5, date: new Date().toLocaleDateString() });
    
    // Details Sheet
    const detailsSheet = workbook.addWorksheet('Test Details');
    detailsSheet.columns = [
        { header: 'Test ID', key: 'id', width: 15 },
        { header: 'Module', key: 'module', width: 20 },
        { header: 'Description', key: 'description', width: 40 },
        { header: 'Steps', key: 'steps', width: 50 },
        { header: 'Expected Result', key: 'expected', width: 30 },
        { header: 'Actual Result', key: 'actual', width: 30 },
        { header: 'Status', key: 'status', width: 15 }
    ];

    const modules = ['Authentication', 'Dashboard', 'User Profile', 'Settings', 'Payments', 'Appointments'];
    const statuses = ['Passed', 'Passed', 'Passed', 'Failed', 'Passed'];

    // Generate 300 test cases
    for (let i = 1; i <= 300; i++) {
        const module = modules[Math.floor(Math.random() * modules.length)];
        const status = statuses[Math.floor(Math.random() * statuses.length)];
        
        detailsSheet.addRow({
            id: `TC-${i.toString().padStart(3, '0')}`,
            module: module,
            description: `Verify functionality ${i} in ${module} module`,
            steps: `1. Navigate to ${module}\n2. Perform action ${i}\n3. Verify result`,
            expected: `System should process action ${i} correctly`,
            actual: status === 'Passed' ? `System processed action ${i} correctly` : `System encountered an error during action ${i}`,
            status: status
        });
    }

    // Format headers
    [summarySheet, detailsSheet].forEach(sheet => {
        sheet.getRow(1).font = { bold: true };
        sheet.getRow(1).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFD3D3D3' } };
    });

    const filename = 'Test_Execution_Summary.xlsx';
    await workbook.xlsx.writeFile(filename);
    console.log(`Successfully generated ${filename} with 300 test cases.`);
}

generateTestCases().catch(err => console.error('Error generating Excel file:', err));
