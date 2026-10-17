export default defineEventHandler(event => {
  setHeader(event, 'Content-Type', 'application/xml; charset=utf-8');
  return '<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"><url><loc>https://entrehuellas.kormind.com/</loc></url></urlset>';
});
