// Commande de build Vercel. Il n'y a pas de Postgres hébergé : le site est
// généré en local (npm run generate) puis `dist/` est commité. Vercel ne fait
// que servir ces fichiers. Ce script fait échouer le build si dist/ est
// absent ou visiblement incomplet, plutôt que de publier une page vide.
import { readFileSync, existsSync } from 'node:fs';

const file = 'dist/index.html';
if (!existsSync(file)) {
  console.error(`ERREUR : ${file} absent. Lancer \`npm run generate\` en local et committer dist/.`);
  process.exit(1);
}
const html = readFileSync(file, 'utf8');
const ok = html.length > 20000 && html.trimEnd().endsWith('</html>') && html.includes('<svg');
if (!ok) {
  console.error(`ERREUR : ${file} semble tronqué ou invalide (${html.length} caractères).`);
  process.exit(1);
}
const asOf = (html.match(/(\d{1,2} \w+ 20\d\d)/) || [])[1] ?? '?';
console.log(`OK : ${file} (${html.length} caractères), première date trouvée : ${asOf}`);
