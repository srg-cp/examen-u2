// Reunion preserves the original pixels outside the two printed bandana areas.
type Artwork = { src: string; width: number; height: number };
const dog: Artwork = { src: '/images/landing/dog-curious.png', width: 1254, height: 1254 };
const cat: Artwork = { src: '/images/landing/cat.png', width: 1254, height: 1254 };
const wave: Artwork = { src: '/images/landing/dog-wave.png', width: 1254, height: 1254 };
const reunion: Artwork = { src: '/images/landing/reunion.png', width: 1536, height: 1024 };
const report: Artwork = { src: '/images/landing/dog-report.png', width: 1254, height: 1254 };
const home: Artwork = { src: '/images/landing/pets-home.png', width: 1774, height: 887 };
const map: Artwork = { src: '/images/landing/pets-map.png', width: 1774, height: 887 };
const corgi: Artwork = { src: '/images/landing/corgi.png', width: 1254, height: 1254 };
const dalmatian: Artwork = { src: '/images/landing/dalmatian.png', width: 1312, height: 1199 };
const tabby: Artwork = { src: '/images/landing/tabby.png', width: 1254, height: 1254 };

export const landingArtwork = {
  'hero-dog': dog, 'hero-cat': cat,
  search: dog, found: cat, help: wave, return: reunion,
  'search-corgi': corgi, 'found-tabby': tabby, 'help-dalmatian': dalmatian,
  'step-search': report, 'step-found': tabby, 'step-help': wave, 'step-return': reunion,
  home, map, report, share: tabby, collaborate: reunion,
  'footer-dog': dog, 'footer-cat': cat,
} as const;
export type LandingArtworkName = keyof typeof landingArtwork;
