-- Finance & Beyond: run this in Supabase SQL Editor.
create extension if not exists pgcrypto;
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text,
  role text not null default 'student' check (role in ('student','admin')),
  created_at timestamptz not null default now()
);
create table if not exists public.content (
  id uuid primary key default gen_random_uuid(),
  kind text not null check (kind in ('news','learning','case_study','activity','research')),
  title text not null,
  summary text,
  category text,
  external_url text,
  file_url text,
  published boolean not null default false,
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);
create or replace function public.handle_new_user() returns trigger language plpgsql security definer set search_path = '' as $$
begin insert into public.profiles(id,full_name) values(new.id,new.raw_user_meta_data->>'full_name'); return new; end; $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute procedure public.handle_new_user();
create or replace function public.is_admin() returns boolean language sql stable security definer set search_path = public as $$ select exists(select 1 from public.profiles where id = auth.uid() and role = 'admin'); $$;
alter table public.profiles enable row level security;
alter table public.content enable row level security;
drop policy if exists "Users can view own profile" on public.profiles;
create policy "Users can view own profile" on public.profiles for select using (auth.uid() = id or public.is_admin());
drop policy if exists "Admins can update profiles" on public.profiles;
create policy "Admins can update profiles" on public.profiles for update using (public.is_admin()) with check (public.is_admin());
drop policy if exists "Public can read published content" on public.content;
create policy "Public can read published content" on public.content for select using (published = true or public.is_admin());
drop policy if exists "Admins can insert content" on public.content;
create policy "Admins can insert content" on public.content for insert with check (public.is_admin() and created_by = auth.uid());
drop policy if exists "Admins can update content" on public.content;
create policy "Admins can update content" on public.content for update using (public.is_admin()) with check (public.is_admin());
drop policy if exists "Admins can delete content" on public.content;
create policy "Admins can delete content" on public.content for delete using (public.is_admin());
insert into storage.buckets (id,name,public,file_size_limit,allowed_mime_types) values ('resources','resources',true,20971520,array['application/pdf','application/vnd.ms-powerpoint','application/vnd.openxmlformats-officedocument.presentationml.presentation','application/msword','application/vnd.openxmlformats-officedocument.wordprocessingml.document','application/vnd.ms-excel','application/vnd.openxmlformats-officedocument.spreadsheetml.sheet']) on conflict (id) do nothing;
drop policy if exists "Public can read resources" on storage.objects;
create policy "Public can read resources" on storage.objects for select using (bucket_id='resources');
drop policy if exists "Admins can upload resources" on storage.objects;
create policy "Admins can upload resources" on storage.objects for insert with check (bucket_id='resources' and public.is_admin());
drop policy if exists "Admins can delete resources" on storage.objects;
create policy "Admins can delete resources" on storage.objects for delete using (bucket_id='resources' and public.is_admin());
-- After registering your own account, run this once with your actual login email:
-- update public.profiles set role='admin' where id=(select id from auth.users where email='YOUR-EMAIL@example.com');
