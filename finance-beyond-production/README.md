# Finance & Beyond — production starter

A Next.js + Supabase foundation for financeandbeyond.in with public content pages, student registration/login, protected member dashboard, administrator-only publishing, file uploads, and an interactive finance quiz.

## Important status
This is an implementation scaffold, not a deployed/live service. A Supabase project and domain/hosting accounts must be configured by the site owner. No passwords, API secrets, domain purchases, or external deployments have been performed.

## Requirements
- Node.js 20.9+
- Supabase project
- Vercel account (recommended hosting)
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
7. Deploy the repository to Vercel and add the same environment variables. Add `https://financeandbeyond.in` and `https://www.financeandbeyond.in` to Supabase Auth Site URL/redirect allowlist as appropriate.
8. At your domain registrar, set the DNS records Vercel provides. Do not guess DNS values; copy the exact records from your Vercel project.

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
