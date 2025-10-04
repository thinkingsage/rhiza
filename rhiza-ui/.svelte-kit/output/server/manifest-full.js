export const manifest = (() => {
function __memo(fn) {
	let value;
	return () => value ??= (value = fn());
}

return {
	appDir: "_app",
	appPath: "_app",
	assets: new Set(["favicon.svg"]),
	mimeTypes: {".svg":"image/svg+xml"},
	_: {
		client: {start:"_app/immutable/entry/start.DLkbNxWW.js",app:"_app/immutable/entry/app.Cfu_ZXXw.js",imports:["_app/immutable/entry/start.DLkbNxWW.js","_app/immutable/chunks/BUyEvlbE.js","_app/immutable/chunks/Dx7XVoHi.js","_app/immutable/chunks/D_-CZwhG.js","_app/immutable/entry/app.Cfu_ZXXw.js","_app/immutable/chunks/D_-CZwhG.js","_app/immutable/chunks/Dx7XVoHi.js","_app/immutable/chunks/CWj6FrbW.js","_app/immutable/chunks/CgBnU58_.js"],stylesheets:[],fonts:[],uses_env_dynamic_public:false},
		nodes: [
			__memo(() => import('./nodes/0.js')),
			__memo(() => import('./nodes/1.js')),
			__memo(() => import('./nodes/2.js'))
		],
		remotes: {
			
		},
		routes: [
			{
				id: "/",
				pattern: /^\/$/,
				params: [],
				page: { layouts: [0,], errors: [1,], leaf: 2 },
				endpoint: null
			}
		],
		prerendered_routes: new Set([]),
		matchers: async () => {
			
			return {  };
		},
		server_assets: {}
	}
}
})();
