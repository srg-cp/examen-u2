import { assertRegisteredRoutes } from './shared/routing/route_policy';

export default defineNuxtConfig({
  hooks: {
    'pages:extend'(pages) {
      const visit = (items: typeof pages, parent = '') => {
        for (const page of items) {
          const path = page.path.startsWith('/') ? page.path : parent + '/' + page.path;
          assertRegisteredRoutes([path]);
          if (page.alias) assertRegisteredRoutes(Array.isArray(page.alias) ? page.alias : [page.alias]);
          if (page.children) visit(page.children, path);
        }
      };
      visit(pages);
    },
  },
  compatibilityDate: '2026-10-17',
  devtools: { enabled: false },
  buildDir: process.env.NUXT_BUILD_DIR || '.nuxt',
  ssr: true,
  css: ['~/assets/main.css'],
  typescript: { strict: true },
  sourcemap: { server: false, client: false },
  nitro: { preset: 'node-server', compressPublicAssets: true },
  app: {
    head: {
      htmlAttrs: { lang: 'es' },
      title: 'Entre Huellas',
      meta: [{ name: 'referrer', content: 'no-referrer' }],
      link: [{ rel: 'icon', href: '/brand-icon.png', type: 'image/png' }],
    },
  },
});
