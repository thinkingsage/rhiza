import * as universal from '../entries/pages/_layout.js';

export const index = 0;
let component_cache;
export const component = async () => component_cache ??= (await import('../entries/pages/_layout.svelte.js')).default;
export { universal };
export const universal_id = "src/routes/+layout.js";
export const imports = ["_app/immutable/nodes/0.CpKPlu3F.js","_app/immutable/chunks/CWj6FrbW.js","_app/immutable/chunks/atU1ri--.js","_app/immutable/chunks/D_-CZwhG.js"];
export const stylesheets = ["_app/immutable/assets/0.QNBvI-D2.css"];
export const fonts = [];
