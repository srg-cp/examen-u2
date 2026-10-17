import { configuration } from './config.mjs';
import { createPublicServer } from './server.mjs';
import { SupabaseCaseDataSource } from '../features/case_reader/data/supabase_case_data_source.mjs';
import { SupabaseCaseRepository } from '../features/case_reader/data/supabase_case_repository.mjs';
import { ReadCase, ReadCasePhoto } from '../features/case_reader/domain/read_case.mjs';

try {
  const config = configuration(process.env);
  const repository = new SupabaseCaseRepository(new SupabaseCaseDataSource(config));
  const server = await createPublicServer({ readCase: new ReadCase(repository), readPhoto: new ReadCasePhoto(repository),
    dist: new URL('../../dist/', import.meta.url), trustedProxies: config.trustedProxies });
  server.listen(config.port, config.host, () => console.log(`Entre Huellas: http://${config.host}:${config.port}`));
  server.on('error', () => { console.error('No se pudo iniciar la ficha pública.'); process.exitCode = 1; });
  for (const event of ['SIGTERM', 'SIGINT']) process.on(event, () => server.close());
} catch {
  console.error('Configuración de servidor incompleta o build pendiente. Revisa README.md.'); process.exitCode = 1;
}
