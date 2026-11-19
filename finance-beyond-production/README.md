# Finance & Beyond — production starter

A Next.js + Supabase foundation for financeandbeyond.in with public content pages, student registration/login, protected member dashboard, administrator-only publishing, file uploads, and an interactive finance quiz.

## Important status
This is an implementation scaffold, not a deployed/live service. A Supabase project and domain/hosting accounts must be configured by the site owner. No passwords, API secrets, domain purchases, or external deployments have been performed.

## Requirements
- Node.js 20.9+
- Supabase project
- Netlify project connected to this repository
- Domain financeandbeyond.in (purchase/availability not verified)

## Setup
1. Create a Supabase project.
2. In Supabase SQL Editor, run `supabase/schema.sql`.
3. In Supabase Authentication settings, enable email/password and configure the site URL and redirect URLs for localhost and your eventual domain.
4. Copy `.env.example` to `.env.local`; fill in the project URL and anon/public key from Supabase Project Settings → API. Never put a service-role key in browser code or commit secrets.
5. Install and run:
   ```bash
   npm install
   npm run dev
   ```
6. Register your own account at `/register`. Confirm your email. Then sign in and use the SQL statement at the bottom of `supabase/schema.sql` to promote only your own account to `admin` (replace the example email).
7. Deploy through Netlify using the repository-root `netlify.toml` and the existing `NEXT_PUBLIC_SUPABASE_URL` and `NEXT_PUBLIC_SUPABASE_ANON_KEY` variables. Add the deployed URLs to the Supabase Auth redirect allowlist as appropriate.
8. For a custom domain, use the DNS records Netlify provides.

## Netlify deployment verification

The repository-root configuration uses `finance-beyond-production` as the base directory, `npm run build` as the build command, and `.next` as the publish directory relative to that base. It explicitly loads `@netlify/plugin-nextjs`, installed in the application's development dependencies with a compatible version range and recorded in the lockfile. Node.js 22 and the current runtime support this Next.js 15 App Router application, server rendering, and middleware.

The runtime must run during Netlify's build lifecycle to package the server and middleware handlers and generate routing. Uploading the internal `.next` files directly leaves the homepage under `server/app/index.html` and causes `/` to return 404. Keep Next.js's normal server output and let the runtime generate routing; do not add a static SPA fallback.

Before publishing to production:

1. Check the Deploy Preview build log for the Next.js Runtime (`@netlify/plugin-nextjs`) pre-build and build hooks. Confirm that function packaging includes the Next.js server handler (`___netlify-server-handler`) and middleware handler, and that no message says the runtime was skipped.
2. From this application directory, run `npm run verify:deployment -- <preview-origin>` with the preview's HTTP or HTTPS origin. The read-only checks require the homepage, games, login, and server-rendered news page to return their expected HTML; both dashboard routes must redirect anonymous visitors to login; and an unknown route must return the Next.js 404 page.
3. Publish only after the runtime and preview checks pass. Then run `npm run verify:deployment -- https://finance-and-beyond.netlify.app` to verify the same behavior on production.

The verification command uses no login credentials and prints only route paths, HTTP statuses, and validation results.

## Included routes
- `/` public homepage
- `/news`, `/learning`, `/cases`, `/activities`, `/research` public published content
- `/games` interactive sample finance quiz
- `/register`, `/login` Supabase email/password authentication
- `/dashboard` authenticated member area
- `/dashboard/admin` administrator-only content publishing and deletion

## Security model
- Public visitors can read only published content.
- Authenticated students can register and sign in; registration defaults to the `student` role.
- Admin role is assigned manually in Supabase by the project owner.
- RLS policies restrict content publishing, editing, deletion and storage uploads to admins.
- The frontend uses only the Supabase anon/publishable key; do not expose the service-role key.
- Public resource bucket means published uploaded files are publicly readable. Uploads/deletes are restricted to admins. Do not upload confidential student records or copyrighted material without permission.

## Before launch
Configure email templates/SMTP, privacy policy, terms, contact details, analytics/consent as required, backups, and domain DNS. Add CAPTCHA/rate limiting if opening registration publicly. Test RLS using a student account and an admin account. Review all sample text and legal notices.
