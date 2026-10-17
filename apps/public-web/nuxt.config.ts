export default defineNuxtConfig({
  compatibilityDate: '2026-10-17',
  devtools: { enabled: false },
  buildDir: '.nuxt',
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
      link: [{ rel: 'icon', href: '/brand.png', type: 'image/png' }],
    },
  },
});
