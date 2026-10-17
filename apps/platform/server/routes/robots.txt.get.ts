export default defineEventHandler(event => {
  setHeader(event, 'Content-Type', 'text/plain; charset=utf-8');
  return 'User-agent: *\nAllow: /$\nDisallow: /c/\nDisallow: /api/\nDisallow: /app/\nDisallow: /admin/\nSitemap: https://entrehuellas.kormind.com/sitemap.xml\n';
});
