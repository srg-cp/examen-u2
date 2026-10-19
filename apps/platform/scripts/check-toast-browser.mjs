import assert from 'node:assert/strict';
import {mkdir} from 'node:fs/promises';
import {pathToFileURL,fileURLToPath} from 'node:url';
import {productionFixture} from '../tests/server_fixture.mjs';
const runtime=await import(pathToFileURL(process.env.PLAYWRIGHT_MODULE).href),{chromium}=runtime.default||runtime;
const browser=await chromium.launch({executablePath:process.env.CHROME_PATH,headless:true}),server=await productionFixture();
const output=new URL('../../mobile/build/ui-preview/web-toast/',import.meta.url);await mkdir(output,{recursive:true});
try{
 const page=await browser.newPage({viewport:{width:1440,height:1000}}),errors=[];
 page.on('pageerror',e=>errors.push(e.message));page.on('console',m=>{if(/Content Security Policy|Refused to|[Hh]ydration.*mismatch/.test(m.text()))errors.push(m.text());});
 await page.goto(server.origin+'/login',{waitUntil:'networkidle'});
 const submit=page.locator('.login-submit'),toast=page.locator('#notice');
 await submit.click();await toast.waitFor({state:'visible'});await page.waitForTimeout(220);
 assert.equal(await toast.getAttribute('role'),'alert');
 const style=await toast.evaluate(el=>{const s=getComputedStyle(el),i=getComputedStyle(el.querySelector('.notice-icon')),svg=el.querySelector('svg');return{background:s.backgroundColor,radius:s.borderRadius,blur:s.backdropFilter,maxWidth:s.maxWidth,top:s.top,color:i.color,icon:i.width,svg:svg.getBoundingClientRect().width,text:el.textContent};});
 assert.match(style.background,/rgba\(245, 245, 247, 0\.9[0-9]*\)/);assert.equal(style.radius,'28px');assert.equal(style.blur,'blur(18px)');assert.equal(style.maxWidth,'360px');assert.equal(style.top,'12px');assert.equal(style.color,'rgb(181, 63, 72)');assert.equal(style.icon,'32px');assert.equal(style.svg,20);assert.ok(!style.text.includes('×'));
 await page.screenshot({path:fileURLToPath(new URL('desktop-error.png',output))});
 await page.locator('#notice-close').focus();await page.keyboard.press('Enter');await toast.waitFor({state:'hidden'});
 for(const [width,enlarged]of [[390,false],[320,true]]){
  await page.setViewportSize({width,height:700});await page.evaluate(v=>document.documentElement.style.fontSize=v?'200%':'100%',enlarged);
  await submit.click();await toast.waitFor({state:'visible'});await page.waitForTimeout(220);
  const rect=await toast.boundingBox();assert.ok(rect.x>=23&&rect.x+rect.width<=width-23);assert.equal(await page.evaluate(()=>document.documentElement.scrollWidth<=innerWidth),true);
  await page.screenshot({path:fileURLToPath(new URL('error-'+width+'.png',output)),fullPage:true});
  await page.locator('#notice-close').click();
 }
 await page.emulateMedia({reducedMotion:'reduce'});await page.goto(server.origin+'/login?reason=signed-out',{waitUntil:'networkidle'});await toast.waitFor({state:'visible'});
 assert.equal(await toast.getAttribute('role'),'status');assert.equal(await toast.locator('.notice-icon').evaluate(el=>getComputedStyle(el).color),'rgb(17, 17, 17)');assert.equal(await toast.evaluate(el=>el.getAnimations().length),0);
 await page.screenshot({path:fileURLToPath(new URL('success-reduced-motion.png',output)),fullPage:true});
 await toast.waitFor({state:'hidden',timeout:8000});
 assert.deepEqual(errors,[]);console.log('Toast QA passed: mobile capsule/glass/icon/error/success, tap and keyboard dismiss, expiry, reduced motion, desktop/390/320/text200%, no overflow/CSP/hydration errors.');
}finally{await browser.close();await server.close();}
