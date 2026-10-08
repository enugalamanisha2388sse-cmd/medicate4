const ExcelJS = require('exceljs');

async function generateAppTestCases() {
    const workbook = new ExcelJS.Workbook();
    workbook.creator = 'Medicate App QA Team';
    workbook.created = new Date();

    // Summary Sheet
    const summarySheet = workbook.addWorksheet('App Summary');
    summarySheet.columns = [
        { header: 'Module', key: 'module', width: 20 },
        { header: 'Total Test Cases', key: 'total', width: 15 },
        { header: 'Passed', key: 'passed', width: 10 },
        { header: 'Failed', key: 'failed', width: 10 },
        { header: 'Execution Date', key: 'date', width: 20 },
    ];
    summarySheet.addRow({ module: 'App Authentication', total: 50, passed: 49, failed: 1, date: new Date().toLocaleDateString() });
    summarySheet.addRow({ module: 'App Navigation', total: 100, passed: 98, failed: 2, date: new Date().toLocaleDateString() });
    summarySheet.addRow({ module: 'App Offline Mode', total: 150, passed: 140, failed: 10, date: new Date().toLocaleDateString() });
    
    // Details Sheet
    const detailsSheet = workbook.addWorksheet('App Test Details');
    detailsSheet.columns = [
        { header: 'Test ID', key: 'id', width: 15 },
        { header: 'Platform', key: 'platform', width: 15 },
        { header: 'Module', key: 'module', width: 20 },
        { header: 'Description', key: 'description', width: 40 },
        { header: 'Steps', key: 'steps', width: 50 },
        { header: 'Expected Result', key: 'expected', width: 30 },
        { header: 'Actual Result', key: 'actual', width: 30 },
        { header: 'Status', key: 'status', width: 15 }
    ];

    const modules = ['App Authentication', 'App Navigation', 'App Offline Mode', 'Push Notifications', 'Camera Integration'];
    const platforms = ['Android', 'iOS'];
    const statuses = ['Passed', 'Passed', 'Passed', 'Passed', 'Failed'];

    // Generate 300 test cases
    for (let i = 1; i <= 300; i++) {
        const module = modules[Math.floor(Math.random() * modules.length)];
        const platform = platforms[Math.floor(Math.random() * platforms.length)];
        const status = statuses[Math.floor(Math.random() * statuses.length)];
        
        detailsSheet.addRow({
            id: `MOB-TC-${i.toString().padStart(3, '0')}`,
            platform: platform,
            module: module,
            description: `Mobile App: Verify functionality ${i} in ${module} on ${platform}`,
            steps: `1. Open App on ${platform}\n2. Navigate to ${module}\n3. Perform action ${i}\n4. Verify result`,
            expected: `App should process action ${i} correctly without crashing`,
            actual: status === 'Passed' ? `App processed action ${i} correctly` : `App encountered an error during action ${i}`,
            status: status
        });
    }

    // Format headers
    [summarySheet, detailsSheet].forEach(sheet => {
        sheet.getRow(1).font = { bold: true };
        sheet.getRow(1).fill = { type: 'pattern', pattern: 'solid', fgColor: { argb: 'FFD3D3D3' } };
    });

    const filename = 'App_Test_Execution_Summary.xlsx';
    await workbook.xlsx.writeFile(filename);
    console.log(`Successfully generated ${filename} with 300 mobile app test cases.`);
}

generateAppTestCases().catch(err => console.error('Error generating Excel file:', err));
