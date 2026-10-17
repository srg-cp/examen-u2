// Independent generated illustrations. No mockup atlas or UI baked into images.
const dog = { src: '/images/landing/dog-curious.png', width: 1254, height: 1254 };
const cat = { src: '/images/landing/cat.png', width: 1254, height: 1254 };
const wave = { src: '/images/landing/dog-wave.png', width: 1254, height: 1254 };
const reunion = { src: '/images/landing/reunion.png', width: 1254, height: 1254 };
const report = { src: '/images/landing/dog-report.png', width: 1254, height: 1254 };
const home = { src: '/images/landing/pets-home.png', width: 1774, height: 887 };
const map = { src: '/images/landing/pets-map.png', width: 1774, height: 887 };

export const landingArtwork = {
  'hero-dog': dog, 'hero-cat': cat,
  search: dog, found: cat, help: wave, return: reunion,
  'step-search': report, 'step-found': cat, 'step-help': wave, 'step-return': reunion,
  home, map, report, share: cat, collaborate: reunion,
  'footer-dog': dog, 'footer-cat': cat,
} as const;
export type LandingArtworkName = keyof typeof landingArtwork;

