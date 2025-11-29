'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "79817898125bbf45ac5f557aa30a8180",
"assets/AssetManifest.bin.json": "e6780102bbab148203f6cb38447d3895",
"assets/AssetManifest.json": "80421b834ad281dbff73ec2acdfe6352",
"assets/assets/expense_manger.html": "16884cda801663b9371c947765036ebb",
"assets/assets/icon.png": "27b151eaf3d9a14d345b64ac9ba3b678",
"assets/assets/images/auto_run_instruction.png": "157e98af2acc6a4e016d56e628112c82",
"assets/assets/images/avoid_bugs_instruction.png": "f0448c04f9ef5e56de6ca3674342d6f6",
"assets/assets/images/collect_eggs_acorns_instruction.png": "956d095654805ae2d41ae60be6b56413",
"assets/assets/images/dash_wins.png": "ffafdcb95f0a7128fbd777cdddbb5c34",
"assets/assets/images/game_background.png": "5d526f90eb95b7b7f6501db3b0984d06",
"assets/assets/images/game_logo.png": "aecf4ea9c06d5205af7b7d4d21b756c2",
"assets/assets/images/game_over_bg.png": "17b71b6212da21a5f2ebde3cf7b0f5b4",
"assets/assets/images/gate.png": "cca0e66f4bb7be18f78517b90cc74043",
"assets/assets/images/instructions_background.png": "78550f5737685df238f56eac487284ab",
"assets/assets/images/intro_background_desktop.png": "b3202cfef9a5e1e613d47562548298cb",
"assets/assets/images/intro_background_mobile.png": "50d142ad847a3c965d8a6ca94843493f",
"assets/assets/images/leaderboard_bg.png": "a99577e2caf54fa93c40ec0a549c03d3",
"assets/assets/images/portalInstruction.png": "6f9fdd76caafce41085cfc2f1e6a738b",
"assets/assets/images/powerful_wings_instruction.png": "f4d825dd7401992cd617c9d1ba522e12",
"assets/assets/images/tap_to_jump_instruction.png": "71cce59dd14a67ad4e1fc7bd611db362",
"assets/assets/images/tap_to_jump_spacebar.png": "6c109b28f920b5e49ee5f40d50c59f6e",
"assets/assets/images/trophy.png": "2ecf6a6c938d57eee0215be92cd06d62",
"assets/assets/jsonCorelatorAnalyzer.html": "885af227e319e2bd60407764565aadb1",
"assets/assets/json_multi_corelator.html": "ad741c308be1eed912fa51a84076d0d3",
"assets/assets/map/anim/spritesheet_dash_deathDrown.png": "5c22059a6f6c7255a10893426d836621",
"assets/assets/map/anim/spritesheet_dash_deathDrown.tsx": "d9740badc5006c3bfbc13c689ca2134f",
"assets/assets/map/anim/spritesheet_dash_deathFaint.png": "3989c2ee9ae8a8c892e18ab680f6cc3b",
"assets/assets/map/anim/spritesheet_dash_deathFaint.tsx": "9333035a6ef560095d18401d2cebc41c",
"assets/assets/map/anim/spritesheet_dash_deathPit.png": "a1d94d5863ddc8014a69bc21029dd9f5",
"assets/assets/map/anim/spritesheet_dash_deathPit.tsx": "3cbf386b590ab89c7fc06d6dd837b97b",
"assets/assets/map/anim/spritesheet_dash_edgeGrab.png": "a0cfcbd71ab5bc4514792939fba579ba",
"assets/assets/map/anim/spritesheet_dash_edgeGrab.tsx": "4fd46d50c801a931017290b72ce7d648",
"assets/assets/map/anim/spritesheet_dash_flap.png": "edf38acfdfbbe05de428ffd07c79eacf",
"assets/assets/map/anim/spritesheet_dash_flap.tsx": "8b55ce8a1e41d00baaeedc47e4a7bc76",
"assets/assets/map/anim/spritesheet_dash_idle.png": "a8dd365ed3f4d51072d8c35e1c9538f2",
"assets/assets/map/anim/spritesheet_dash_idle.tsx": "444a425770ecb604a677c2a38fd7e47e",
"assets/assets/map/anim/spritesheet_dash_jump.png": "01acd54753271f34e6d373a73c99b2d9",
"assets/assets/map/anim/spritesheet_dash_jump.tsx": "b2a332d024bbbc52c884aa91715d6c45",
"assets/assets/map/anim/spritesheet_dash_run.png": "c4471c3cc171d1fb49dc74af030606f9",
"assets/assets/map/anim/spritesheet_dash_run.tsx": "daa87e0414f7644a144b4d679753803d",
"assets/assets/map/anim/spritesheet_dash_slide.png": "7de0239821d02b61ab7bd82e8ed0717b",
"assets/assets/map/anim/spritesheet_dash_slide.tsx": "c6470840e0449d72ad9135ce808a1876",
"assets/assets/map/anim/spritesheet_enemy_ant.png": "44531f1de744678d847be99c1e3ce930",
"assets/assets/map/anim/spritesheet_enemy_ant.tsx": "c78b9c287c2b48b236364fd0a7c5f04a",
"assets/assets/map/anim/spritesheet_enemy_bee.png": "d4602d09ea1430450cd0cbfac5a043b3",
"assets/assets/map/anim/spritesheet_enemy_bee.tsx": "d3db917d6d0173c97a9ad335ba0b433b",
"assets/assets/map/anim/spritesheet_enemy_beetle.png": "064da20cd845cb40a0835693bb7849cf",
"assets/assets/map/anim/spritesheet_enemy_beetle.tsx": "a43efc734dc39280d513266c25feb585",
"assets/assets/map/anim/spritesheet_enemy_butterfly.png": "59613a53bbb084a55dc40bbfb2347189",
"assets/assets/map/anim/spritesheet_enemy_butterfly.tsx": "a994eb6956f9b16981d89b0de54d70a7",
"assets/assets/map/anim/spritesheet_enemy_dragonfly.png": "93f645a2d0641fd01976ce0a63051dbe",
"assets/assets/map/anim/spritesheet_enemy_grasshopper.png": "0829da93d86b30c3984992c32ef8848e",
"assets/assets/map/anim/spritesheet_enemy_grasshopper.tsx": "2776e2c1e7170ad6bab02523e557ee35",
"assets/assets/map/anim/spritesheet_fx_large.png": "e460f7d486285200acd464a80ff4d6ee",
"assets/assets/map/anim/spritesheet_fx_large.tsx": "1c769f1431cb2b48c5e6b926d82e793b",
"assets/assets/map/anim/spritesheet_fx_small.png": "9a1e37f977faccb33d2741e709a6d886",
"assets/assets/map/anim/spritesheet_fx_small.tsx": "391ee5542510e60b4fed0d43a34707a4",
"assets/assets/map/anim/spritesheet_item_egg.png": "1acde5c0639b80c4d40b7a1c9a572e61",
"assets/assets/map/anim/spritesheet_item_egg.tsx": "0a006e32aa40018db0061c1a0df30ad6",
"assets/assets/map/anim/spritesheet_item_feather.png": "ab7dd37d11a754761d2ba196ae873585",
"assets/assets/map/anim/spritesheet_item_feather.tsx": "4ed60125d809dd17aa597b859f4539fb",
"assets/assets/map/anim/spritesheet_phoenixDash_doublejump.png": "15c5b8693cff5d4861de16f2bdb648ca",
"assets/assets/map/anim/spritesheet_phoenixDash_doublejump.tsx": "4fe0a7aee204ecfaee123a24caa2e775",
"assets/assets/map/anim/spritesheet_phoenixDash_idle.png": "6fbe4354912e796a1d8f4544902c7967",
"assets/assets/map/anim/spritesheet_phoenixDash_idle.tsx": "61666bdc08a9d7d7d397525b73902641",
"assets/assets/map/anim/spritesheet_phoenixDash_jump.png": "f40bc3adf586bf16c3d462a2fd564bc1",
"assets/assets/map/anim/spritesheet_phoenixDash_jump.tsx": "c11615086459f8b0ab8b3ce76a1c5808",
"assets/assets/map/anim/spritesheet_phoenixDash_run.png": "4801237af827ab57aedb0b8538304b11",
"assets/assets/map/anim/spritesheet_phoenixDash_run.tsx": "702d65b533ab2bc1638aa9ed6796b86d",
"assets/assets/map/anim/spritesheet_poof.png": "dcb190f7daec1fbb04d449e4d0e0077f",
"assets/assets/map/anim/spritesheet_poof.tsx": "7ed0ec9a1b5c7451b78e84726b9eee31",
"assets/assets/map/anim/spritesheet_poof_orange.png": "eb28872e8400b0d0e287a5fecd3b33dd",
"assets/assets/map/anim/spritesheet_poof_orange.tsx": "1879ac64b0ca11d4da6648232b750385",
"assets/assets/map/flutter_runnergame_map_A.tmx": "18c52b3ced31308eeda28ea49ac78c3d",
"assets/assets/map/flutter_runnergame_map_B.tmx": "58c5085c5671d255084c1e10a954f11f",
"assets/assets/map/flutter_runnergame_map_C.tmx": "0ec9a32c7b89c4a2d1e99ef8070ff4b6",
"assets/assets/map/objects/tile_enemies_v2.png": "75e2822e2a545e4b3e6d7c43279d501b",
"assets/assets/map/objects/tile_enemies_v2.tsx": "d7a3d1be631b7825272435164a818de3",
"assets/assets/map/objects/tile_forest_trees_back_v02.png": "91822cac7cb310b783a1b42f5374de28",
"assets/assets/map/objects/tile_forest_trees_back_v02.tsx": "e341ad0625dcd0e25feda263d375dead",
"assets/assets/map/objects/tile_forest_trees_front_v02.png": "945a620500d2652ea52914b3f67dd2e1",
"assets/assets/map/objects/tile_forest_trees_front_v02.tsx": "5d31c02eb4fcacf5fed92d262df4f302",
"assets/assets/map/objects/tile_gate_lvl5.png": "9d1e58f5ea5b79b443288d4424320005",
"assets/assets/map/objects/tile_gate_lvl5.tsx": "bf6bb8372f1005bbef25f2ecded1e341",
"assets/assets/map/objects/tile_gate_lvl7.png": "2f1c9968745fa30f803c76a4422bd7ad",
"assets/assets/map/objects/tile_gate_lvl7.tsx": "ba4ba845f38f03fdc781ceec3646c668",
"assets/assets/map/objects/tile_items_v2.png": "75b6bff9bdb72457a6cd8f288b21b62b",
"assets/assets/map/objects/tile_items_v2.tsx": "6336fbd68d7a195f71a7af5d4e734d2e",
"assets/assets/map/objects/tile_mountain_tree_v01.png": "3ad29b8386f9b09ba3da0410b6ca0e81",
"assets/assets/map/objects/tile_mountain_tree_v01.tsx": "75e47d9dbf5689df7bfd2ec9adebfb66",
"assets/assets/map/objects/tile_plains_mountains_B.png": "29c70bdf615f949610bc99e5271e31c2",
"assets/assets/map/objects/tile_plains_mountains_B.tsx": "da8437a541d7889fbf968bbaa748d567",
"assets/assets/map/objects/tile_plains_mountains_v01.png": "a243526e736411008b5cf520ec7d91c1",
"assets/assets/map/objects/tile_plains_mountains_v01.tsx": "ad656995b2edc082fd3aa43587de3e18",
"assets/assets/map/tiles/tile_atmos_forest_1.png": "05a2d79c99814ecec87ce0af7732f837",
"assets/assets/map/tiles/tile_atmos_forest_1.tsx": "f757d4a26cd8274c3c37bad30e930449",
"assets/assets/map/tiles/tile_atmos_forest_2.png": "e7383fe8edb7b6762c2de8690e2c4b58",
"assets/assets/map/tiles/tile_atmos_forest_2.tsx": "331819d5782be12bc514805b0cc74ef1",
"assets/assets/map/tiles/tile_atmos_forest_3.png": "b045d7207ab1064411d1664b998a7bf4",
"assets/assets/map/tiles/tile_atmos_forest_3.tsx": "eb51174df7dd1b27b2d4f5b7dbeca6cf",
"assets/assets/map/tiles/tile_clouds_BG.png": "5f19cd356a27a857929dfeedff06b1ab",
"assets/assets/map/tiles/tile_clouds_BG.tsx": "c417f47c7fe0e1cedbe127362bc8cdf9",
"assets/assets/map/tiles/tile_clouds_v02.png": "4ac3f75685d918b6e6107d7496a46e62",
"assets/assets/map/tiles/tile_clouds_v02.tsx": "a8477fa2c0c59a0c1c2649626eb46fa9",
"assets/assets/map/tiles/tile_decorations_v01.png": "499e74dd838d78fa4fd5a8c49fc5e938",
"assets/assets/map/tiles/tile_decorations_v01.tsx": "747d6fe1b147194ae4936735f8a9553f",
"assets/assets/map/tiles/tile_forest_bushes_v02.png": "f5449c16bb75f38004a0bfef82f33367",
"assets/assets/map/tiles/tile_forest_bushes_v02.tsx": "b457d0183e392f947dd4f894b7dd50c7",
"assets/assets/map/tiles/tile_forest_bushes_v03.png": "d00687aae1e9c0b1d22aa9824673c1c4",
"assets/assets/map/tiles/tile_forest_bushes_v03.tsx": "5b119112e14709f3dc3b3b698b97e9e9",
"assets/assets/map/tiles/tile_forest_ground_v02.png": "67d5f731a4b11680dd36c4473a5a9619",
"assets/assets/map/tiles/tile_forest_ground_v02.tsx": "ac45a6a4a54a6a262f35ec5a045fdf6a",
"assets/assets/map/tiles/tile_forest_ground_v03.png": "f5aee5f5ba8dc0f051be273e9f4bfe01",
"assets/assets/map/tiles/tile_forest_ground_v03.tsx": "f5f63b637f0bea57000a6042104a248b",
"assets/assets/map/tiles/tile_forest_ground_v04.png": "e92030c946949e438241a3ebc8d8127b",
"assets/assets/map/tiles/tile_forest_ground_v04.tsx": "b4a5810cfce99f6dd1cbd890d88df7e8",
"assets/assets/map/tiles/tile_gate_v2.png": "6b3dbdb7276fd973f527b63ec32a0e19",
"assets/assets/map/tiles/tile_gate_v2.tsx": "c1569a12ff833efbefe9413228309f5a",
"assets/assets/map/tiles/tile_ground_transition_v02.png": "86b2c9c7d084fcb24260c363417af29a",
"assets/assets/map/tiles/tile_ground_transition_v02.tsx": "67169fe937416f6f47e2f697a35835c6",
"assets/assets/map/tiles/tile_mountain_ground_v02.png": "a053486a51959c2ad72ea5feb11aaf43",
"assets/assets/map/tiles/tile_mountain_ground_v02.tsx": "eee03901c76b33f9fc850cfdd72d0571",
"assets/assets/map/tiles/tile_mountain_ground_v03.png": "868ea392d678beb101474a0c1d0fd0db",
"assets/assets/map/tiles/tile_mountain_ground_v03.tsx": "3292f58d27df6be13918fdee76832411",
"assets/assets/map/tiles/tile_mountain_mountains_v01.png": "c2df1566b33a214a7a0d7636d1b2f235",
"assets/assets/map/tiles/tile_mountain_mountains_v01.tsx": "cdb9455ed758d7cd9eac0425c612e6f1",
"assets/assets/map/tiles/tile_mountain_stars_v01.png": "96fa3c91e1226d8de86dbe8fabed0910",
"assets/assets/map/tiles/tile_mountain_stars_v01.tsx": "507782f366a295928cc63ce1c803497e",
"assets/assets/map/tiles/tile_plains_ground_v02.png": "64f09ac825436b61d46706568064fa22",
"assets/assets/map/tiles/tile_plains_ground_v02.tsx": "a8daa0e15fdd1959fdf4a6f188854656",
"assets/assets/map/tiles/tile_plains_ground_v03.png": "d0d291c07c9909e3c46d24aa45141376",
"assets/assets/map/tiles/tile_plains_ground_v03.tsx": "e4708e2ac42651f5cc34caa527a33433",
"assets/assets/map/tiles/tile_plains_hills_v01.png": "f738df9b25981dd7d4fb15353ec4a7c4",
"assets/assets/map/tiles/tile_plains_hills_v01.tsx": "81eec53fa7820df1798d93e268ead36e",
"assets/assets/map/tiles/tile_plains_hills_v02.png": "1cd488c837fb4726191b02bb55e6a782",
"assets/assets/map/tiles/tile_plains_hills_v02.tsx": "b522e00833d301019230dc36ba690043",
"assets/assets/map/tiles/tile_sky_v02.png": "9030a06a7ce03162e6f078ba66e1bcf9",
"assets/assets/map/tiles/tile_sky_v02.tsx": "25d82a9a13e0fcf967f90b537d61cbe1",
"assets/assets/map/tiles/tile_treehouse.png": "4929d7af1f12d7e53b7e9b72b7856901",
"assets/assets/map/tiles/tile_treehouse.tsx": "2481217a070db89f6d76f146478d3f2e",
"assets/assets/music/FlutterGame_SunshineAndDewdrops_1_1.mp3": "6c8257c4dcf1e7888eea003218991bc9",
"assets/assets/sfx/Dash_AcornPickup.mp3": "ed5364255793385c6365b08662021901",
"assets/assets/sfx/Dash_EggPickup.mp3": "f96b423f1cb5445ed1783e12fde2949f",
"assets/assets/sfx/Dash_FeatherPowerup.mp3": "7cc26e281b475a11ebfbe10621e09b2e",
"assets/assets/sfx/Dash_Footstep_Run.mp3": "144b07cbd9a8d47342756869998621ac",
"assets/assets/sfx/Dash_Jump.mp3": "fd6eebb05e4046e76130c35218c70ad1",
"assets/assets/sfx/Phoenix_DOUBLEJump.wav": "9540f28092f7806c6bd04992d9f51c5b",
"assets/assets/sfx/Phoenix_Jump.wav": "0b658a1cc9c8cae5e1aac430a0919de6",
"assets/assets/smartJsonFormatterAnalyzer.html": "58407bee616474b63dadac5bb1ef29a1",
"assets/assets/sounds/capture.mp3": "a2b149c4f98d37bd7863462fdc4539b0",
"assets/assets/sounds/move-self.mp3": "d9502a4de53f50cbb0147e25d2c172b2",
"assets/assets/sounds/notify.mp3": "1ca271535cc745b6facaff0c844c44de",
"assets/FontManifest.json": "16cdd9f3112218e5c2037c55e4901277",
"assets/fonts/MaterialIcons-Regular.otf": "cda2028f330ec2e6a73be53154bd33b8",
"assets/NOTICES": "7d0b28391312e30deffe59eb590546e3",
"assets/packages/app_ui/assets/fonts/GoogleSansText-Bold.ttf": "a6f5ad76d0ff8168fd7046354d62fc68",
"assets/packages/app_ui/assets/fonts/GoogleSansText-Regular.ttf": "3077fc2d656cc45868d673507772f8d4",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.css": "5a8d0222407e388155d7d1395a75d5b9",
"assets/packages/flutter_inappwebview/assets/t_rex_runner/t-rex.html": "16911fcc170c8af1c5457940bd0bf055",
"assets/packages/flutter_inappwebview_web/assets/web/web_support.js": "509ae636cfdd93e49b5a6eaf0f06d79f",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Brands-Regular-400.otf": "d75ea17885ff2a0c03f33e5bd204c108",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Regular-400.otf": "b2703f18eee8303425a5342dba6958db",
"assets/packages/font_awesome_flutter/lib/fonts/Font-Awesome-7-Free-Solid-900.otf": "f9a03a9ac20e81b5394a59c1597ccbe3",
"assets/shaders/ink_sparkle.frag": "ecc85a2e95f5e9f53123dcaf8cb9b6ce",
"canvaskit/canvaskit.js": "140ccb7d34d0a55065fbd422b843add6",
"canvaskit/canvaskit.js.symbols": "58832fbed59e00d2190aa295c4d70360",
"canvaskit/canvaskit.wasm": "07b9f5853202304d3b0749d9306573cc",
"canvaskit/chromium/canvaskit.js": "5e27aae346eee469027c80af0751d53d",
"canvaskit/chromium/canvaskit.js.symbols": "193deaca1a1424049326d4a91ad1d88d",
"canvaskit/chromium/canvaskit.wasm": "24c77e750a7fa6d474198905249ff506",
"canvaskit/skwasm.js": "1ef3ea3a0fec4569e5d531da25f34095",
"canvaskit/skwasm.js.symbols": "0088242d10d7e7d6d2649d1fe1bda7c1",
"canvaskit/skwasm.wasm": "264db41426307cfc7fa44b95a7772109",
"canvaskit/skwasm_heavy.js": "413f5b2b2d9345f37de148e2544f584f",
"canvaskit/skwasm_heavy.js.symbols": "3c01ec03b5de6d62c34e17014d1decd3",
"canvaskit/skwasm_heavy.wasm": "8034ad26ba2485dab2fd49bdd786837b",
"favicon.png": "e1b99dfa1b9ca7b8babe7e4758383a75",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "4c6883251ade49230ec7e88f426b54a4",
"icons/Icon-192.png": "394b038c2fae6cfe28ec0dd5c587a26c",
"icons/Icon-512.png": "e4e157fdc9c77f14a766e3ef09054547",
"icons/Icon-maskable-192.png": "394b038c2fae6cfe28ec0dd5c587a26c",
"icons/Icon-maskable-512.png": "e4e157fdc9c77f14a766e3ef09054547",
"index.html": "ed229e582b7f8b46fbc35769177ea47e",
"/": "ed229e582b7f8b46fbc35769177ea47e",
"main.dart.js": "34b526f37dc342dddfe5f39e8888292e",
"manifest.json": "f0d889848ddb0e9aa93eeb6309219d81",
"version.json": "df1de803233b7dddc490c17dd0edb96e"};
// The application shell files that are downloaded before a service worker can
// start.
const CORE = ["main.dart.js",
"index.html",
"flutter_bootstrap.js",
"assets/AssetManifest.bin.json",
"assets/FontManifest.json"];

// During install, the TEMP cache is populated with the application shell files.
self.addEventListener("install", (event) => {
  self.skipWaiting();
  return event.waitUntil(
    caches.open(TEMP).then((cache) => {
      return cache.addAll(
        CORE.map((value) => new Request(value, {'cache': 'reload'})));
    })
  );
});
// During activate, the cache is populated with the temp files downloaded in
// install. If this service worker is upgrading from one with a saved
// MANIFEST, then use this to retain unchanged resource files.
self.addEventListener("activate", function(event) {
  return event.waitUntil(async function() {
    try {
      var contentCache = await caches.open(CACHE_NAME);
      var tempCache = await caches.open(TEMP);
      var manifestCache = await caches.open(MANIFEST);
      var manifest = await manifestCache.match('manifest');
      // When there is no prior manifest, clear the entire cache.
      if (!manifest) {
        await caches.delete(CACHE_NAME);
        contentCache = await caches.open(CACHE_NAME);
        for (var request of await tempCache.keys()) {
          var response = await tempCache.match(request);
          await contentCache.put(request, response);
        }
        await caches.delete(TEMP);
        // Save the manifest to make future upgrades efficient.
        await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
        // Claim client to enable caching on first launch
        self.clients.claim();
        return;
      }
      var oldManifest = await manifest.json();
      var origin = self.location.origin;
      for (var request of await contentCache.keys()) {
        var key = request.url.substring(origin.length + 1);
        if (key == "") {
          key = "/";
        }
        // If a resource from the old manifest is not in the new cache, or if
        // the MD5 sum has changed, delete it. Otherwise the resource is left
        // in the cache and can be reused by the new service worker.
        if (!RESOURCES[key] || RESOURCES[key] != oldManifest[key]) {
          await contentCache.delete(request);
        }
      }
      // Populate the cache with the app shell TEMP files, potentially overwriting
      // cache files preserved above.
      for (var request of await tempCache.keys()) {
        var response = await tempCache.match(request);
        await contentCache.put(request, response);
      }
      await caches.delete(TEMP);
      // Save the manifest to make future upgrades efficient.
      await manifestCache.put('manifest', new Response(JSON.stringify(RESOURCES)));
      // Claim client to enable caching on first launch
      self.clients.claim();
      return;
    } catch (err) {
      // On an unhandled exception the state of the cache cannot be guaranteed.
      console.error('Failed to upgrade service worker: ' + err);
      await caches.delete(CACHE_NAME);
      await caches.delete(TEMP);
      await caches.delete(MANIFEST);
    }
  }());
});
// The fetch handler redirects requests for RESOURCE files to the service
// worker cache.
self.addEventListener("fetch", (event) => {
  if (event.request.method !== 'GET') {
    return;
  }
  var origin = self.location.origin;
  var key = event.request.url.substring(origin.length + 1);
  // Redirect URLs to the index.html
  if (key.indexOf('?v=') != -1) {
    key = key.split('?v=')[0];
  }
  if (event.request.url == origin || event.request.url.startsWith(origin + '/#') || key == '') {
    key = '/';
  }
  // If the URL is not the RESOURCE list then return to signal that the
  // browser should take over.
  if (!RESOURCES[key]) {
    return;
  }
  // If the URL is the index.html, perform an online-first request.
  if (key == '/') {
    return onlineFirst(event);
  }
  event.respondWith(caches.open(CACHE_NAME)
    .then((cache) =>  {
      return cache.match(event.request).then((response) => {
        // Either respond with the cached resource, or perform a fetch and
        // lazily populate the cache only if the resource was successfully fetched.
        return response || fetch(event.request).then((response) => {
          if (response && Boolean(response.ok)) {
            cache.put(event.request, response.clone());
          }
          return response;
        });
      })
    })
  );
});
self.addEventListener('message', (event) => {
  // SkipWaiting can be used to immediately activate a waiting service worker.
  // This will also require a page refresh triggered by the main worker.
  if (event.data === 'skipWaiting') {
    self.skipWaiting();
    return;
  }
  if (event.data === 'downloadOffline') {
    downloadOffline();
    return;
  }
});
// Download offline will check the RESOURCES for all files not in the cache
// and populate them.
async function downloadOffline() {
  var resources = [];
  var contentCache = await caches.open(CACHE_NAME);
  var currentContent = {};
  for (var request of await contentCache.keys()) {
    var key = request.url.substring(origin.length + 1);
    if (key == "") {
      key = "/";
    }
    currentContent[key] = true;
  }
  for (var resourceKey of Object.keys(RESOURCES)) {
    if (!currentContent[resourceKey]) {
      resources.push(resourceKey);
    }
  }
  return contentCache.addAll(resources);
}
// Attempt to download the resource online before falling back to
// the offline cache.
function onlineFirst(event) {
  return event.respondWith(
    fetch(event.request).then((response) => {
      return caches.open(CACHE_NAME).then((cache) => {
        cache.put(event.request, response.clone());
        return response;
      });
    }).catch((error) => {
      return caches.open(CACHE_NAME).then((cache) => {
        return cache.match(event.request).then((response) => {
          if (response != null) {
            return response;
          }
          throw error;
        });
      });
    })
  );
}
