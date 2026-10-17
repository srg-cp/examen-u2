import { mkdir, copyFile, writeFile } from 'node:fs/promises';
const root = new URL('../', import.meta.url);
const copies = new Map([
  ['index.html', 'public/index.html'], ['app.css', 'public/app.css'], ['app.mjs', 'public/app.mjs'], ['brand.png', 'public/brand.png'],
  ['client/domain/case.mjs', 'src/features/case_reader/domain/case.mjs'],
  ['client/domain/read_case.mjs', 'src/features/case_reader/domain/read_case.mjs'],
  ['client/data/http_case_repository.mjs', 'src/features/case_reader/data/http_case_repository.mjs'],
  ['client/presentation/reader_view_model.mjs', 'src/features/case_reader/presentation/reader_view_model.mjs'],
  ['client/presentation/reader_view.mjs', 'src/features/case_reader/presentation/reader_view.mjs'],
]);
for (const [target, source] of copies) {
  const destination = new URL(`dist/${target}`, root); await mkdir(new URL('./', destination), { recursive: true });
  await copyFile(new URL(source, root), destination);
}
await writeFile(new URL('dist/manifest.json', root), JSON.stringify([...copies.keys()], null, 2));
console.log('Build público preparado; adaptadores de servidor y credenciales excluidos.');
