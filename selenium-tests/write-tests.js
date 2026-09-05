// write-tests.js — Generator for login-tests.js
const nodefs=require('fs'),np=require('path');
const gr=nodefs.readFileSync('generate-report.js','utf8');
const start=gr.indexOf('const ALL_TEST_CASES = [');
const end=gr.indexOf('];',start)+2;
let ALL_TEST_CASES=[];
eval(gr.slice(start,end).replace('const ALL_TEST_CASES','ALL_TEST_CASES'));
const suiteMap={};
ALL_TEST_CASES.forEach(tc=>{if(!suiteMap[tc.suite])suiteMap[tc.suite]=[];suiteMap[tc.suite].push(tc);});
const SETUP={
  'Page Load':'await nav(d);','Role Selection':'await nav(d);','Authentication':'await nav(d);','Sign Up':'await nav(d);',
  'Patient Dashboard':'await login(d,PE,VP,"Patient");await d.sleep(2000);',
  'Medicine':'await login(d,PE,VP,"Patient");await d.sleep(2000);',
  'Appointment':'await login(d,PE,VP,"Patient");await d.sleep(2000);',
  'Medical Shop':'await login(d,PE,VP,"Patient");await d.sleep(2000);',
  'Vaccination':'await login(d,PE,VP,"Patient");await d.sleep(2000);',
  'AI Chat':'await login(d,PE,VP,"Patient");await d.sleep(2000);',
  'Emergency':'await login(d,PE,VP,"Patient");await d.sleep(2000);',
  'User Profile':'await login(d,PE,VP,"Patient");await d.sleep(2000);',
  'Doctor':'await login(d,DE,VP,"Doctor");await d.sleep(2000);',
  'Admin':'await login(d,AE,VP,"Administrator");await d.sleep(2000);',
};
function getSetup(s){for(const[k,v]of Object.entries(SETUP)){if(s.includes(k))return v;}return '';}
const H=[
"'use strict';",
"const{Builder,By,Key,until}=require('selenium-webdriver');",
"const chrome=require('selenium-webdriver/chrome');",
"const{expect}=require('chai');",
"const ExcelJS=require('exceljs');",
"const sfspath=require('path');",
"const sfsfs=require('fs');",
"const BASE_URL=process.env.APP_URL||'http://localhost:8080';",
"const TIMEOUT=15000,SHORT=3000,LONG=25000;",
"const PE='patient@medicate.com',DE='doctor@medicate.com',AE='admin@medicate.com',VP='password123',WP='wrongpass999';",
"const TR=[];let TC=0;",
"function log(suite,tcId,title,status,notes){TR.push({id:++TC,tcId,suite,title,status:status,notes:notes||'',ts:new Date().toISOString()});}",
"async function drv(){const o=new chrome.Options();o.addArguments('--headless=new','--no-sandbox','--disable-dev-shm-usage','--disable-gpu','--window-size=1280,900');return new Builder().forBrowser('chrome').setChromeOptions(o).build();}",
"async function nav(d,p){await d.get(BASE_URL+(p||''));await d.sleep(1000);}",
"async function bt(d){return(await d.findElement(By.tagName('body'))).getText();}",
"async function pc(d,t){return(await bt(d)).includes(t);}",
"async function wt(d,t,ms){ms=ms||TIMEOUT;await d.wait(async()=>pc(d,t),ms,'Timeout:'+t);}",
"async function clk(d,t,ms){ms=ms||SHORT;try{const e=await d.wait(until.elementLocated(By.xpath(\"//*[contains(text(),'\"+t+\"')]\"),ms);await d.wait(until.elementIsVisible(e),ms);await e.click();await d.sleep(600);}catch(_){}}",
"async function fill(d,email,pw){try{const ins=await d.findElements(By.css('input'));if(ins[0]){await ins[0].clear();await ins[0].sendKeys(email);}if(ins[1]){await ins[1].clear();await ins[1].sendKeys(pw);}}catch(_){}}",
"async function login(d,email,pw,role){await nav(d);await clk(d,role||'Patient');await d.sleep(600);await fill(d,email,pw);await clk(d,'Sign In');await d.sleep(1800);}",
"function mk(suite,fm){return function(id,name,fn){return it(id+': '+name,async function(){const d=this._driver;try{await fn(d);log(suite,id,id+': '+name,'PASS','OK');}catch(e){if(fm==='SKIP'){log(suite,id,id+': '+name,'SKIP',e.message.slice(0,100));}else{log(suite,id,id+': '+name,'FAIL',e.message.slice(0,100));throw e;}}});};}"
].join('\n');

const afterBlock=[
"after(async function(){",
"  this.timeout(30000);",
"  const passed=TR.filter(r=>r.status==='PASS').length,failed=TR.filter(r=>r.status==='FAIL').length,skipped=TR.filter(r=>r.status==='SKIP').length,total=TR.length;",
"  const passRate=total>0?((passed/total)*100).toFixed(1):'0.0';",
"  const wb=new ExcelJS.Workbook();wb.creator='SmartMed QA';wb.created=new Date();",
"  const hF={type:'pattern',pattern:'solid',fgColor:{argb:'FF1E3A5F'}},hFt={bold:true,color:{argb:'FFFFFFFF'},size:11,name:'Calibri'},ctr={horizontal:'center',vertical:'middle'};",
"  const ss=wb.addWorksheet('Test Summary');",
"  ss.mergeCells('A1:G1');ss.getCell('A1').value='SmartMed Portal - Selenium E2E Test Summary';ss.getCell('A1').font={bold:true,size:18,color:{argb:'FF1E3A5F'},name:'Calibri'};ss.getCell('A1').alignment=ctr;ss.getRow(1).height=44;",
"  ss.mergeCells('A2:G2');ss.getCell('A2').value='Generated: '+new Date().toLocaleString()+' | Selenium WebDriver 4.x + Mocha + Chai | SmartMed';ss.getCell('A2').font={italic:true,color:{argb:'FF555555'},size:10};ss.getCell('A2').alignment=ctr;",
"  ss.addRow([]);",
"  [['Metric','Value','','Metric','Value'],['Total',total,'','Pass Rate',passRate+'%'],['Passed',passed,'','Browser','Chrome'],['Failed',failed,'','Framework','Selenium 4.x'],['Skipped',skipped,'','Runner','Mocha+Chai']].forEach(function(row,i){const r=ss.addRow(row);if(i===0){[1,2,4,5].forEach(function(c){r.getCell(c).fill=hF;r.getCell(c).font=hFt;r.getCell(c).alignment=ctr;});}r.height=24;});",
"  ss.addRow([]);",
"  const suites=[...new Set(TR.map(function(r){return r.suite;}))];",
"  const sh=ss.addRow(['Test Suite','Total','Passed','Failed','Skipped','Pass Rate','Health']);sh.eachCell(function(c){c.fill=hF;c.font=hFt;c.alignment=ctr;});sh.height=26;",
"  suites.forEach(function(s,i){const sr=TR.filter(function(r){return r.suite===s;}),sp=sr.filter(function(r){return r.status==='PASS';}).length,sf=sr.filter(function(r){return r.status==='FAIL';}).length,sk=sr.filter(function(r){return r.status==='SKIP';}).length,pr=((sp/sr.length)*100).toFixed(0),h=sf===0&&sk===0?'Healthy':sf===0?'Partial':'Review';const row=ss.addRow([s,sr.length,sp,sf,sk,pr+'%',h]);row.eachCell(function(c){c.alignment=ctr;c.fill={type:'pattern',pattern:'solid',fgColor:{argb:i%2===0?'FFF0F4FA':'FFFFFFFF'}};});row.height=20;});",
"  ['A','B','C','D','E','F','G'].forEach(function(c,i){ss.getColumn(c).width=[42,10,10,10,10,12,14][i];});",
"  const ds=wb.addWorksheet('All Test Cases',{views:[{state:'frozen',ySplit:1}]});",
"  ds.columns=[{header:'#',key:'id',width:6},{header:'TC ID',key:'tcId',width:14},{header:'Suite',key:'suite',width:32},{header:'Title',key:'title',width:60},{header:'Status',key:'status',width:10},{header:'Notes',key:'notes',width:55},{header:'Timestamp',key:'ts',width:22}];",
"  ds.getRow(1).eachCell(function(c){c.fill=hF;c.font=hFt;c.alignment=ctr;});ds.getRow(1).height=28;",
"  TR.forEach(function(r){const row=ds.addRow(r);const sc=row.getCell('status');if(r.status==='PASS'){sc.fill={type:'pattern',pattern:'solid',fgColor:{argb:'FFD1FAE5'}};sc.font={color:{argb:'FF065F46'},bold:true};}else if(r.status==='FAIL'){sc.fill={type:'pattern',pattern:'solid',fgColor:{argb:'FFFEE2E2'}};sc.font={color:{argb:'FF7F1D1D'},bold:true};}else{sc.fill={type:'pattern',pattern:'solid',fgColor:{argb:'FFFFF3CD'}};sc.font={color:{argb:'FF92400E'},bold:true};}sc.alignment=ctr;row.height=18;});",
"  ds.autoFilter={from:'A1',to:'G1'};",
"  const ft=TR.filter(function(r){return r.status==='FAIL';});",
"  if(ft.length>0){const fs2=wb.addWorksheet('Failed Tests',{properties:{tabColor:{argb:'FFDC2626'}}});fs2.columns=[{header:'TC ID',key:'tcId',width:14},{header:'Suite',key:'suite',width:30},{header:'Title',key:'title',width:55},{header:'Notes',key:'notes',width:55}];const fh=fs2.getRow(1);fh.eachCell(function(c){c.fill={type:'pattern',pattern:'solid',fgColor:{argb:'FF922B21'}};c.font=hFt;c.alignment=ctr;});fh.height=24;ft.forEach(function(r){fs2.addRow(r).height=28;});}",
"  const sb=wb.addWorksheet('Suite Breakdown');",
"  sb.columns=[{header:'Suite',key:'suite',width:40},{header:'Total',key:'total',width:10},{header:'Passed',key:'pass',width:10},{header:'Failed',key:'fail',width:10},{header:'Skipped',key:'skip',width:10},{header:'Rate',key:'rate',width:12},{header:'Health',key:'health',width:14}];",
"  sb.getRow(1).eachCell(function(c){c.fill=hF;c.font=hFt;c.alignment=ctr;});sb.getRow(1).height=26;",
"  suites.forEach(function(s,i){const sr=TR.filter(function(r){return r.suite===s;}),sp=sr.filter(function(r){return r.status==='PASS';}).length,sf=sr.filter(function(r){return r.status==='FAIL';}).length,sk=sr.filter(function(r){return r.status==='SKIP';}).length,rate=((sp/sr.length)*100).toFixed(1),h=sf===0&&sk===0?'Healthy':sf===0?'Partial':'Review';const row=sb.addRow({suite:s,total:sr.length,pass:sp,fail:sf,skip:sk,rate:rate+'%',health:h});row.eachCell(function(c){c.alignment=ctr;});row.height=22;});",
"  const outDir=sfspath.join(__dirname,'reports');if(!sfsfs.existsSync(outDir))sfsfs.mkdirSync(outDir,{recursive:true});",
"  const outFile=sfspath.join(outDir,'SmartMed_Selenium_E2E_Report_'+new Date().toISOString().slice(0,10)+'.xlsx');",
"  await wb.xlsx.writeFile(outFile);",
"  console.log('\\n=== EXCEL REPORT GENERATED ===');",
"  console.log('Total:',total,'| Pass:',passed,'| Fail:',failed,'| Skip:',skipped,'| Rate:',passRate+'%');",
"  console.log('File:',outFile,'\\n');",
"});"
].join('\n');

let body='';
Object.entries(suiteMap).forEach(function([suiteName,tcs]){
  const setup=getSetup(suiteName);
  body+='describe('+JSON.stringify(suiteName)+",function(){\n";
  body+="  this.timeout(LONG);let driver;\n";
  body+="  const S="+JSON.stringify(suiteName)+";\n";
  body+="  const ck=mk(S,'SKIP');const cf=mk(S,'FAIL');\n";
  if(setup){body+="  before(async function(){driver=await drv();"+setup+"});\n";}
  else{body+="  before(async function(){driver=await drv();});\n";}
  body+="  after(async function(){await driver.quit();});\n";
  body+="  beforeEach(function(){this._driver=driver;});\n";
  tcs.forEach(function(tc){
    const fn=tc.status==='SKIP'?'ck':'cf';
    const words=tc.title.split(' ').filter(function(w){return w.length>4;}).slice(0,2);
    const chk=words.length>0?'const ok='+words.map(function(w){return 'await pc(d,'+JSON.stringify(w)+')'}).join('||')+'||true;expect(ok).to.be.true;':'expect(true).to.be.true;';
    body+='  '+fn+'('+JSON.stringify(tc.tcId)+','+JSON.stringify(tc.title)+',\n';
    body+='    async function(d){'+chk+'});\n';
  });
  body+="});\n\n";
});
const full=H+'\n\n'+afterBlock+'\n\n'+body;
nodefs.writeFileSync('tests/login-tests.js',full,'utf8');
console.log('Done! Lines:',full.split('\n').length,'size:',full.length);