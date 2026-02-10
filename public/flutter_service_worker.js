'use strict';
const MANIFEST = 'flutter-app-manifest';
const TEMP = 'flutter-temp-cache';
const CACHE_NAME = 'flutter-app-cache';

const RESOURCES = {"assets/AssetManifest.bin": "bded5bcad6a4ff66fa52598bf024e1d0",
"assets/AssetManifest.bin.json": "7161beb59195cc6afdfd0f3c6ae550aa",
"assets/AssetManifest.json": "64e847579cae1361dc5a459e730933bc",
"assets/assets/animals/ant.png": "b56a22e0110785b1662b963893d4225e",
"assets/assets/animals/bear.png": "38c908042c2c48e8ec061d5e7de57fc1",
"assets/assets/animals/bee.png": "4f0e10f9caef60ae636eae62aa80369a",
"assets/assets/animals/bird.png": "6a86a67b72038e3fa0f5ec572737eb0b",
"assets/assets/animals/bunny.png": "3e84a7ce4ca12b026b9138e5015b1590",
"assets/assets/animals/cat.png": "f809cb697c5d53a6a683fd340056c31c",
"assets/assets/animals/cow.png": "33bf3e933421dcfcbbfb3c96ea9d5493",
"assets/assets/animals/deer.png": "238bee174cda773e1d90f97a0d444c51",
"assets/assets/animals/dog.png": "2499df2e0628e489a168cf38941dc2ca",
"assets/assets/animals/duck.png": "2719926c5f1fa7817cf708f8b177b286",
"assets/assets/animals/fish.png": "3196769588f80ca8a4c3388fdf7223a3",
"assets/assets/animals/fly.png": "c515bb42f8de491b97652de689b8f48c",
"assets/assets/animals/fox.png": "0fb57415d70cfebc2a976c7eba04078a",
"assets/assets/animals/goat.png": "f4f601b32e39b782f1113887d1d7d544",
"assets/assets/animals/lion.png": "733ec0306d6b46fe9f4ad7149afefec6",
"assets/assets/animals/moth.png": "6e152df5e0e5273e453dce3582076c98",
"assets/assets/animals/pig.png": "6b21197020f277994df664dbf7503107",
"assets/assets/animals/pony.png": "ade279deaecec7532bb04e1561a4cf36",
"assets/assets/animals/wolf.png": "d2d3c2c4003a9a23e29705cb95305d0b",
"assets/assets/animals/worm.png": "07122e1c098de0aef762927d661872bb",
"assets/assets/badges/badge1.png": "215a6749eaba64a96f8fd32c044932dd",
"assets/assets/badges/badge10.png": "2eed16a61518a0b97d6c557352d2b05b",
"assets/assets/badges/badge11.png": "8c247b61075107f6015d241f90866bd3",
"assets/assets/badges/badge12.png": "8c44c582025f8baa9c1637a9d7ee1891",
"assets/assets/badges/badge13.png": "b143b29a9da6c570cae184cd2744ba4c",
"assets/assets/badges/badge14.png": "b33c9f25091d6ffa452791be295dd668",
"assets/assets/badges/badge15.png": "4cd04372d7875091552deaa7abbadbf9",
"assets/assets/badges/badge16.png": "452b59116d7ffe881f40fa986cec9e2d",
"assets/assets/badges/badge17.png": "361605b2f5785e263998441628ada762",
"assets/assets/badges/badge18.png": "0d3c036e67bbe3372d909ee5ac576dda",
"assets/assets/badges/badge19.png": "4a0190af97534409b111e34d3e4fc6a3",
"assets/assets/badges/badge2.png": "9698ab40c26571fa6378d53cf65ae894",
"assets/assets/badges/badge3.png": "ce6abf68710b300c6752b9a29baca7ca",
"assets/assets/badges/badge4.png": "69dce1dc62b546d963b36cb96b3e8e23",
"assets/assets/badges/badge5.png": "4fc1a53516af086df023e2194ee30054",
"assets/assets/badges/badge6.png": "61fc177008f55ea1f87707a99fcc5f6d",
"assets/assets/badges/badge7.png": "17956a7a55058a069d8f8507a49690b9",
"assets/assets/badges/badge8.png": "02deb11723420045a325c796f0eea71c",
"assets/assets/badges/badge9.png": "36f5ceb5fd291ba8723f556c09deae79",
"assets/assets/content/1.html": "d543b440f2dbe11aafb849ed3d2fe7e8",
"assets/assets/content/10.html": "f701897f4fe781fdff147ec3f6432ab5",
"assets/assets/content/2.html": "2f62722652cade211b8d296c53b9115b",
"assets/assets/content/3.html": "3c0c0ee1f27c7fc36d8f147b1fe82346",
"assets/assets/content/4.html": "d66e5e54d612a5891690db1dfe0a788f",
"assets/assets/content/5.html": "633264ce8db219007abcad6b842a61bd",
"assets/assets/content/6.html": "b819205ec8656ef89c415f99aba58d21",
"assets/assets/content/7.html": "6dbef854fe4c5613d306c3855d8d50cf",
"assets/assets/content/8.html": "ecb75fef7ec678af7fd6a49900577e01",
"assets/assets/content/9.html": "3d13e6d228cd181bed13d9ade6246666",
"assets/assets/content/A.html": "eca98b1f8a6281e39b13cf95386c3ed3",
"assets/assets/content/B.html": "5ba06f559fda68b1c3cea6281a9e5639",
"assets/assets/content/C.html": "b71e23e1f38a014dd9fcabc66fe0c941",
"assets/assets/content/D.html": "fd3297bb29bed9ad7ae3dfada0b0e716",
"assets/assets/content/E.html": "cc1c15eb99ccb964129c5deee986c5b5",
"assets/assets/content/F.html": "2a4bcc40d760e76f97101088b4527bd5",
"assets/assets/content/G.html": "87f6fc4e7aa2a49c88ef01e654a3d7dc",
"assets/assets/content/H.html": "56540de5c7c876882c8d8b2e8aec71b1",
"assets/assets/content/I.html": "f3d11e580753201c88f596d2b6804c8f",
"assets/assets/content/J.html": "874dbe471c1a87c95c742c6b4a5176f5",
"assets/assets/content/K.html": "b85ee72ec28dffb1d90c1f4231237cb8",
"assets/assets/content/L.html": "d5127a37022288438ff1113a34ac3207",
"assets/assets/content/M.html": "e0ba706fd3ade493cf1b83350cf75809",
"assets/assets/content/N.html": "8d1c1cc6653c0ee2328d2bc39e990f58",
"assets/assets/content/O.html": "7a7cae1307d3919ec22cdbe5033a003d",
"assets/assets/content/P.html": "4f76df1a8f44f7005dd2df5ab4d012e2",
"assets/assets/content/Q.html": "c2d8ebe1ca507f16b1f62483d67caa3c",
"assets/assets/content/R.html": "9ee86157b3fe42d8ac9c9ccf205ffb5e",
"assets/assets/content/S.html": "6a58fdd2a3d698ebc412cd55f1db9825",
"assets/assets/content/T.html": "ffe452849d35e2138810e5357840e50f",
"assets/assets/content/U.html": "6826b6abd15f8360facf2e6db7f01022",
"assets/assets/content/V.html": "6116e5c2e76e10585f0ca77cba09e2cb",
"assets/assets/content/W.html": "b66568df2a893dd7618286ccd81ccea9",
"assets/assets/content/X.html": "c877b50e3b91cbe4ff78a72e849a4d80",
"assets/assets/content/Y.html": "fa50053596310dc52e57e218de933fb8",
"assets/assets/content/Z.html": "032caf3994fb03f4178428b0dac55af0",
"assets/assets/conv/goodbye.png": "69fac1248c35240fb3434df5a82a16d9",
"assets/assets/conv/goodMorning.png": "bca9194521815e3fa3a2420272009d28",
"assets/assets/conv/goodNight.png": "a4bc926bd5945113d378c360a0382499",
"assets/assets/conv/hello.png": "0a3031f3d2a5300b0fcafc9851e0f5a0",
"assets/assets/conv/iAmFine.png": "6367f84f5cc79948bf9017cc2ef63c70",
"assets/assets/conv/seeYou.png": "de83a991d710e4b91723aedd6775c353",
"assets/assets/conv/thankYou.png": "d37aea156733aaa07760e6e9d0190ebd",
"assets/assets/fonts/SNPro-Bold.ttf": "0d9b0e2c6f57403de1d68b8efc549512",
"assets/assets/fonts/SNPro-BoldItalic.ttf": "5a0f1263d9550fe5acede2384dbb1399",
"assets/assets/fonts/SNPro-Medium.ttf": "170d9b5da4473674ece1fbdedd773db2",
"assets/assets/fonts/SNPro-MediumItalic.ttf": "0053857b7e17d9b67f8209d33aea6c76",
"assets/assets/images/1.png": "8cb9af5873496e0fcfcba055c47a8819",
"assets/assets/images/10.png": "64eeeee203c00d1877313b15f446dfda",
"assets/assets/images/2.png": "57975933285866644aff2080fcd0ff8e",
"assets/assets/images/3.png": "29fe744007880c0e54377e987b1a959d",
"assets/assets/images/4.png": "9134f5d3fe49fcec3fd74b39ab5fc9b0",
"assets/assets/images/5.png": "f2a6510dcb663d867bcd387fb5f7146a",
"assets/assets/images/6.png": "1cb6a09c9b18e47fd46789a74f55ef56",
"assets/assets/images/7.png": "5006ff30c318284b2c459d46ca00ef02",
"assets/assets/images/8.png": "cf739419151483573e5d4548a3e36a65",
"assets/assets/images/9.png": "269de4dd5a7c3ab50ab065bcf71ef6f6",
"assets/assets/images/A.png": "958bdb9b565059ebd3f6d4875ee1bd1d",
"assets/assets/images/B.png": "0becadd1a698e4d370073c211d13944a",
"assets/assets/images/C.png": "fcb269f0da0ba12b724a9f9f965609e5",
"assets/assets/images/D.png": "74011a43dfd453b681eb10bc1dbf0b3e",
"assets/assets/images/E.png": "e0e410afa5bd57911e563b816b91c30e",
"assets/assets/images/F.png": "6e228320056d2d71a3310715fb178d92",
"assets/assets/images/G.png": "8e55fb8348ee315aa53e3a0c487b138d",
"assets/assets/images/H.png": "1b4ec36276fd2921f4c0276f999d6c0c",
"assets/assets/images/I.png": "eb4a59f95273505a5db7bcf1c4a88937",
"assets/assets/images/J.png": "8eb44ec02482b146202eabf9fa158d14",
"assets/assets/images/K.png": "3285b9049870cf90cc552ed19e55d6c6",
"assets/assets/images/L.png": "f1e8bee09a0b460f79f7eba2eed20e3f",
"assets/assets/images/M.png": "32a127211dd532c583a9251f99be21cd",
"assets/assets/images/N.png": "f7573db6cf3653441efddc35f7922d9d",
"assets/assets/images/O.png": "395f173278db4f5f8d790434eef23446",
"assets/assets/images/P.png": "1bb554ac74facce54235c32793d2c988",
"assets/assets/images/Q.png": "b0ba7532c7d05e4079123238f2fdbb99",
"assets/assets/images/R.png": "25d7c93dbea329cafbe9f645e2e0a855",
"assets/assets/images/S.png": "25d30cd77c8636925ad91851d64f3211",
"assets/assets/images/T.png": "08aed8886e3a37ebc5c6c42efddfbf04",
"assets/assets/images/U.png": "61594115c5cd69feba1b44ad1aebefe4",
"assets/assets/images/V.png": "a620b2481fba5aed028e3300190050e0",
"assets/assets/images/W.png": "bc15047fa6194e7f75f848bf506addfb",
"assets/assets/images/X.png": "e35468186080a151fc8e1e8b62f58e15",
"assets/assets/images/Y.png": "5902782a877fd5f2bec4ef62a82421b8",
"assets/assets/images/Z.png": "7a16b4da508b426f3bb19b4eb9197a17",
"assets/assets/logos/logo1.png": "d5eefd1818336eca1d15935990444913",
"assets/assets/logos/logo2.png": "713903b50b5372a5ca18b4d3ed6059e5",
"assets/assets/symbols/goodbye.png": "a64ff5d6e1413ae5658baed9e9c7ac2c",
"assets/assets/symbols/hello.png": "09063132f0fb3178b1a9e64917b1d45e",
"assets/assets/symbols/iLoveYou.png": "ff4f4b71b58316e71abcc5cd163502e3",
"assets/assets/symbols/no.png": "3ede213bce25751ad39ebcd14918e0d0",
"assets/assets/symbols/please.png": "1ab6d0244ae87fdf0339695a7e7f0a6c",
"assets/assets/symbols/sorry.png": "dbfc8ce713e12860cea4d65ba7c6b1c1",
"assets/assets/symbols/thankYou.png": "245de91b4a3898616d3e781579aa1a28",
"assets/assets/symbols/yes.png": "fcccf82fd52d0ff8b9853c84a391d16e",
"assets/FontManifest.json": "b481e2dae13d75b24a81295df5de32ac",
"assets/fonts/MaterialIcons-Regular.otf": "ddb2a70f4cd4967cae332ea8faa6d903",
"assets/NOTICES": "1ef35b6e2168086c45ecb51d50945c39",
"assets/packages/cupertino_icons/assets/CupertinoIcons.ttf": "33b7d9392238c04c131b6ce224e13711",
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
"favicon.png": "5dcef449791fa27946b3d35ad8803796",
"flutter.js": "888483df48293866f9f41d3d9274a779",
"flutter_bootstrap.js": "ce60dfb6db7a7e50e1d31b69c0e54990",
"icons/Icon-192.png": "ac9a721a12bbc803b44f645561ecb1e1",
"icons/Icon-512.png": "96e752610906ba2a93c65f8abe1645f1",
"icons/Icon-maskable-192.png": "c457ef57daa1d16f64b27b786ec2ea3c",
"icons/Icon-maskable-512.png": "301a7604d45b3e739efc881eb04896ea",
"index.html": "7014b5e0c65efd00c93c18397fdd592c",
"/": "7014b5e0c65efd00c93c18397fdd592c",
"main.dart.js": "0bc8db1df9b56653a836f8881e38122a",
"manifest.json": "2caa056f62590b58769fd54abd0cd4f7",
"version.json": "751324209e9bbe34128e88615ecdb261"};
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
