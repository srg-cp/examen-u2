import assert from 'node:assert/strict';
import {mkdir} from 'node:fs/promises';
import {fileURLToPath,pathToFileURL} from 'node:url';
import {moderationFixture} from '../tests/moderation_fixture.mjs';
const runtime=await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href),{chromium}=runtime.default||runtime;
const browser=await chromium.launch({executablePath:process.env.CHROME_PATH,headless:true});
const server=await moderationFixture();
const output=new URL('../../mobile/build/ui-preview/web-login/',import.meta.url);await mkdir(output,{recursive:true});
try{
 const context=await browser.newContext({viewport:{width:1440,height:1000},reducedMotion:'reduce'}),page=await context.newPage(),errors=[];
 page.on('pageerror',e=>errors.push(e.message));page.on('console',m=>{if(/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(m.text()))errors.push(m.text());});
 const html=await (await fetch(server.origin+'/login')).text();assert.match(html,/Inicia sesión/);assert.doesNotMatch(html,/Acceso para cuentas autorizadas|Comprobando acceso/);assert.match(html,/Continúa con Google/);assert.match(html,/Continúa con Facebook/);assert.doesNotMatch(html,/PRIVATE_REPORT_REASON|PRIVATE_EVIDENCE|test-fixture-password/);
 await page.goto(server.origin+'/moderacion',{waitUntil:'networkidle'});await page.waitForURL('**/login');await page.getByRole('heading',{name:'Inicia sesión',exact:true}).waitFor();
 await page.getByLabel('Correo',{exact:true}).waitFor();
 assert.match(await page.locator('.login-screen').evaluate(el=>getComputedStyle(el).fontFamily),/Arial/);
 assert.equal(await page.locator('.login-panel').count(),0);
 await page.getByLabel('Contraseña',{exact:true}).fill('visibility-check');
 await page.getByRole('button',{name:'Mostrar contraseña',exact:true}).click();
 assert.equal(await page.getByLabel('Contraseña',{exact:true}).getAttribute('type'),'text');
 assert.equal(await page.getByLabel('Contraseña',{exact:true}).inputValue(),'visibility-check');
 await page.getByRole('button',{name:'Ocultar contraseña',exact:true}).click();
 assert.equal(await page.getByLabel('Contraseña',{exact:true}).getAttribute('type'),'password');
 await page.getByLabel('Contraseña',{exact:true}).fill('');
 for(const [name,width,height,enlarged] of [['desktop',1440,1000,false],['wide',1920,1000,false],['reference',731,1000,false],['mobile',390,844,false],['small-text',320,700,true]]){
  await page.setViewportSize({width,height});await page.evaluate(enlarged=>{document.documentElement.style.fontSize=enlarged?'200%':'100%';},enlarged);
  assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true,name+' overflow');
  await page.screenshot({path:fileURLToPath(new URL(name+'.png',output)),fullPage:true});
 }
 await page.evaluate(()=>{document.documentElement.style.fontSize='100%';});await page.setViewportSize({width:1440,height:1000});
 await page.locator('.login-form button[type=submit]').click();await page.getByRole('alert').filter({hasText:'Revisa el correo'}).waitFor();
 assert.equal(await page.getByLabel('Correo',{exact:true}).getAttribute('aria-invalid'),'true');
 await page.getByLabel('Correo',{exact:true}).fill('ordinario@example.test');await page.getByLabel('Contraseña',{exact:true}).fill('test-fixture-password');await page.getByLabel('Contraseña',{exact:true}).press('Enter');
 await page.getByRole('alert').filter({hasText:'Acceso denegado'}).waitFor();assert.equal(new URL(page.url()).pathname,'/login');assert.equal(await page.getByLabel('Contraseña',{exact:true}).inputValue(),'');
 await page.getByLabel('Correo',{exact:true}).fill('moderador@example.test');await page.getByLabel('Contraseña',{exact:true}).fill('test-fixture-password');await page.getByLabel('Contraseña',{exact:true}).press('Enter');
 await page.waitForURL('**/moderacion');await page.getByRole('button',{name:'Revisar denuncia',exact:true}).waitFor();
 await page.goto(server.origin+'/login?next=https://example.test');await page.waitForURL('**/moderacion');await page.getByRole('button',{name:'Cerrar sesión',exact:true}).waitFor();
 const other=await context.newPage();await other.goto(server.origin+'/moderacion');await other.getByRole('button',{name:'Revisar denuncia',exact:true}).waitFor();
 await page.getByRole('button',{name:'Cerrar sesión',exact:true}).click();await page.waitForURL('**/login?reason=signed-out');await other.waitForURL('**/login');assert.equal(await other.getByText('PRIVATE_REPORT_REASON').count(),0);
 await page.goto(server.origin+'/moderacion');await page.waitForURL('**/login');
 await page.route('**/api/moderation/session',route=>route.fulfill({status:503,contentType:'application/json',body:'{"error":"unavailable"}'}));
 await page.goto(server.origin+'/moderacion');await page.getByRole('button',{name:'Reintentar conexión'}).waitFor();assert.equal(new URL(page.url()).pathname,'/moderacion');
 await page.unroute('**/api/moderation/session');await page.getByRole('button',{name:'Reintentar conexión'}).click();await page.waitForURL('**/login');
 await page.getByLabel('Correo',{exact:true}).fill('moderador@example.test');await page.getByLabel('Contraseña',{exact:true}).fill('test-fixture-password');await page.locator('.login-form button[type=submit]').click();await page.waitForURL('**/moderacion');await page.getByRole('button',{name:'Revisar denuncia',exact:true}).waitFor();
 // Shorten only the browser's public session expiry; API then reports expiration.
 let expiring=true;
 await page.route('**/api/moderation/session',async route=>{
  if(!expiring)return route.fulfill({status:401,contentType:'application/json',body:'{"error":"unauthenticated"}'});
  expiring=false;const response=await route.fetch();const body=await response.json();await route.fulfill({response,json:{...body,expiresAt:Date.now()+300}});
 });
 await page.reload();await page.waitForURL('**/login?reason=expired');await page.getByRole('alert').filter({hasText:'La sesión expiró'}).waitFor();
 await page.unroute('**/api/moderation/session');await context.clearCookies();
 for(const provider of ['Google','Facebook']){
  await page.goto(server.origin+'/login');await page.getByRole('button',{name:'Continúa con '+provider,exact:true}).click();await page.waitForURL('**/moderacion');await page.getByRole('button',{name:'Revisar denuncia',exact:true}).waitFor();
  await page.getByRole('button',{name:'Cerrar sesión',exact:true}).click();await page.waitForURL('**/login?reason=signed-out');
 }
 assert.deepEqual(errors,[]);await other.close();await context.close();
 console.log('Login Chrome QA passed: stable form without skeleton/restricted note, Google/Facebook PKCE redirect and return, SSR without secrets, /moderacion to /login, 1920/1440/731/390/320 and text200%, validation, role denial, Enter login, fixed redirect target, existing session, cross-tab logout, transient failure retry, expiry redirect, CSP/hydration. Fixture backend only.');
}finally{await browser.close();await server.close();}
