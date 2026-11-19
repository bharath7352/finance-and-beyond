import assert from 'node:assert/strict';

let origin;
try {
  const target = new URL(process.argv[2]);
  assert.ok(['http:', 'https:'].includes(target.protocol));
  assert.equal(target.username, '');
  assert.equal(target.password, '');
  assert.equal(target.pathname, '/');
  assert.equal(target.search, '');
  assert.equal(target.hash, '');
  origin = target.origin;
} catch {
  console.error('Usage: npm run verify:deployment -- <deployment-origin>');
  process.exit(1);
}

const checks = [
  { path: '/', heading: /Finance knowledge\.[\s\S]*?Beyond the classroom\./ },
  { path: '/games', heading: /Finance Games & Quizzes/ },
  { path: '/login', heading: /Welcome back/ },
  { path: '/news', heading: /Finance News & Updates/ },
  { path: '/dashboard', redirect: '/login' },
  { path: '/dashboard/admin', redirect: '/login' },
  { path: '/deployment-routing-check-not-found', status: 404 },
];

let failures = 0;
for (const check of checks) {
  try {
    // Keep redirects visible so missing pages and auth middleware are checked directly.
    const response = await fetch(new URL(check.path, origin), {
      redirect: 'manual',
      signal: AbortSignal.timeout(15_000),
    });

    try {
      if (check.redirect) {
        assert.ok([307, 308].includes(response.status), `expected auth redirect; received HTTP ${response.status}`);
        const location = response.headers.get('location');
        assert.ok(location, 'auth redirect is missing its destination');
        const destination = new URL(location, origin);
        assert.equal(destination.origin, origin, 'auth redirect must stay on this deployment');
        assert.equal(destination.pathname, check.redirect, 'auth redirect must lead to login');
      } else {
        assert.equal(response.status, check.status ?? 200, `unexpected HTTP status ${response.status}`);
        assert.ok(response.headers.get('content-type')?.includes('text/html'), 'expected an HTML page');
        const html = (await response.text()).replaceAll('&amp;', '&');
        if (check.heading) {
          const heading = html.match(/<h1\b[^>]*>([\s\S]*?)<\/h1>/i)?.[1] ?? '';
          assert.ok(check.heading.test(heading), 'expected page heading is missing');
        } else {
          assert.ok(html.includes('This page could not be found'), 'expected the Next.js not-found page');
        }
      }
    } finally {
      if (!response.bodyUsed) await response.body?.cancel();
    }

    console.log(`PASS ${check.path} (HTTP ${response.status})`);
  } catch (error) {
    failures++;
    // Response bodies, cookies, and redirect URLs can contain account data.
    const reason = error instanceof assert.AssertionError ? error.message.split('\n')[0] : 'request failed or timed out';
    console.error(`FAIL ${check.path}: ${reason}`);
  }
}

if (failures) {
  console.error(`${failures} deployment check(s) failed.`);
  process.exitCode = 1;
} else {
  console.log('All deployment checks passed.');
}
