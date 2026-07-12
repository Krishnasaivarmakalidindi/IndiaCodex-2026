-- ============================================================
-- AgriTrust – Phase 5 Complete Schema
-- Run this in Supabase SQL Editor: Dashboard → SQL Editor → New Query
-- ============================================================

-- ── 1. PROFILES ──────────────────────────────────────────────
create table if not exists public.profiles (
  id          uuid primary key references auth.users on delete cascade,
  role        text not null default 'buyer' check (role in ('farmer','buyer','admin')),
  full_name   text not null default '',
  avatar_url  text,
  trust_score integer not null default 100,
  trades_completed integer not null default 0,
  is_verified boolean not null default false,
  created_at  timestamptz not null default now()
);
alter table public.profiles enable row level security;

drop policy if exists "profiles_select" on public.profiles;
drop policy if exists "profiles_insert" on public.profiles;
drop policy if exists "profiles_update" on public.profiles;

create policy "profiles_select" on public.profiles for select using (true);
create policy "profiles_insert" on public.profiles for insert with check (true);
create policy "profiles_update" on public.profiles for update using (auth.uid() = id);


-- ── 2. WALLETS ───────────────────────────────────────────────
create table if not exists public.wallets (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null unique references public.profiles on delete cascade,
  address        text not null,
  balance        numeric not null default 10000,
  locked_balance numeric not null default 0,
  network        text not null default 'preview_testnet',
  created_at     timestamptz not null default now()
);
alter table public.wallets enable row level security;

drop policy if exists "wallets_all" on public.wallets;
create policy "wallets_all" on public.wallets for all using (true) with check (true);


-- ── 3. PRODUCTS ──────────────────────────────────────────────
create table if not exists public.products (
  id                 uuid primary key default gen_random_uuid(),
  farmer_id          uuid not null references public.profiles on delete cascade,
  title              text not null,
  description        text not null default '',
  category           text not null,
  grade              text not null,
  price_per_unit     numeric not null,
  unit_type          text not null,
  quantity_available integer not null,
  image_url          text,
  created_at         timestamptz not null default now()
);
alter table public.products enable row level security;

drop policy if exists "products_select" on public.products;
drop policy if exists "products_insert" on public.products;
drop policy if exists "products_update" on public.products;
drop policy if exists "products_delete" on public.products;

create policy "products_select" on public.products for select using (true);
create policy "products_insert" on public.products for insert with check (auth.uid() = farmer_id);
create policy "products_update" on public.products for update using (auth.uid() = farmer_id);
create policy "products_delete" on public.products for delete using (auth.uid() = farmer_id);


-- ── 4. OFFERS ────────────────────────────────────────────────
create table if not exists public.offers (
  id           uuid primary key default gen_random_uuid(),
  product_id   uuid not null references public.products on delete cascade,
  buyer_id     uuid not null references public.profiles on delete cascade,
  offer_price  numeric not null,
  quantity     integer not null,
  status       text not null default 'pending' check (status in ('pending','accepted','declined','countered')),
  counter_price numeric,
  created_at   timestamptz not null default now()
);
alter table public.offers enable row level security;

drop policy if exists "offers_all" on public.offers;
create policy "offers_all" on public.offers for all using (true) with check (true);


-- ── 5. ORDERS ────────────────────────────────────────────────
create table if not exists public.orders (
  id           uuid primary key default gen_random_uuid(),
  offer_id     uuid references public.offers,
  buyer_id     uuid not null references public.profiles,
  farmer_id    uuid not null references public.profiles,
  product_id   uuid not null references public.products,
  total_amount numeric not null,
  status       text not null default 'negotiated' check (status in (
    'negotiated','contract_generated','buyer_signed','funds_locked',
    'farmer_signed','shipment_started','buyer_confirmed','funds_released','contract_closed'
  )),
  created_at   timestamptz not null default now()
);
alter table public.orders enable row level security;

drop policy if exists "orders_all" on public.orders;
create policy "orders_all" on public.orders for all using (true) with check (true);


-- ── 6. CONTRACTS ─────────────────────────────────────────────
create table if not exists public.contracts (
  id               uuid primary key default gen_random_uuid(),
  order_id         uuid not null references public.orders on delete cascade,
  contract_address text not null,
  status           text not null default 'active' check (status in ('active','funded','released','refunded','closed')),
  tx_hash          text,
  created_at       timestamptz not null default now()
);
alter table public.contracts enable row level security;

drop policy if exists "contracts_all" on public.contracts;
create policy "contracts_all" on public.contracts for all using (true) with check (true);


-- ── 7. WALLET TRANSACTIONS ───────────────────────────────────
create table if not exists public.wallet_transactions (
  id         uuid primary key default gen_random_uuid(),
  wallet_id  uuid not null references public.wallets on delete cascade,
  amount     numeric not null,
  type       text not null check (type in ('deposit','withdrawal','escrow_lock','escrow_release','fee')),
  status     text not null default 'confirmed' check (status in ('pending','confirmed')),
  tx_hash    text,
  created_at timestamptz not null default now()
);
alter table public.wallet_transactions enable row level security;

drop policy if exists "wallet_txns_all" on public.wallet_transactions;
create policy "wallet_txns_all" on public.wallet_transactions for all using (true) with check (true);


-- ── 8. REVIEWS ───────────────────────────────────────────────
create table if not exists public.reviews (
  id         uuid primary key default gen_random_uuid(),
  farmer_id  uuid not null references public.profiles,
  buyer_id   uuid not null references public.profiles,
  rating     integer not null check (rating between 1 and 5),
  review     text,
  order_id   uuid not null references public.orders,
  created_at timestamptz not null default now()
);
alter table public.reviews enable row level security;

drop policy if exists "reviews_all" on public.reviews;
create policy "reviews_all" on public.reviews for all using (true) with check (true);


-- ── 9. BLOCKCHAIN LOGS ───────────────────────────────────────
create table if not exists public.blockchain_logs (
  id           uuid primary key default gen_random_uuid(),
  block_number integer not null,
  tx_hash      text not null,
  action       text not null,
  data         jsonb,
  prev_hash    text,
  created_at   timestamptz not null default now()
);
alter table public.blockchain_logs enable row level security;

drop policy if exists "blockchain_all" on public.blockchain_logs;
create policy "blockchain_all" on public.blockchain_logs for all using (true) with check (true);


-- ── 10. NOTIFICATIONS ────────────────────────────────────────
create table if not exists public.notifications (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.profiles on delete cascade,
  message    text not null,
  type       text not null,
  read       boolean not null default false,
  created_at timestamptz not null default now()
);
alter table public.notifications enable row level security;

drop policy if exists "notifications_select" on public.notifications;
drop policy if exists "notifications_insert" on public.notifications;
drop policy if exists "notifications_update" on public.notifications;

create policy "notifications_select" on public.notifications for select using (user_id = auth.uid());
create policy "notifications_insert" on public.notifications for insert with check (true);
create policy "notifications_update" on public.notifications for update using (user_id = auth.uid());


-- ── 11. AUTO-PROFILE + WALLET TRIGGER ───────────────────────
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
declare
  v_role      text;
  v_name      text;
  v_address   text;
begin
  v_role    := coalesce(new.raw_user_meta_data->>'role', 'buyer');
  v_name    := coalesce(new.raw_user_meta_data->>'full_name', split_part(new.email, '@', 1));
  v_address := 'addr_test1v' || substring(replace(new.id::text, '-', ''), 1, 38);

  insert into public.profiles (id, role, full_name, trust_score, trades_completed, is_verified)
  values (new.id, v_role, v_name, 100, 0, false)
  on conflict (id) do nothing;

  insert into public.wallets (user_id, address, balance, locked_balance, network)
  values (new.id, v_address, 10000.0, 0.0, 'preview_testnet')
  on conflict (user_id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();


-- ── 12. GENESIS BLOCK ────────────────────────────────────────
insert into public.blockchain_logs (block_number, tx_hash, action, data, prev_hash)
values (
  100,
  '0x3a4b6c7d8e9f0a1b2c3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b0c1d2e3f4a5b',
  'GENESIS_BLOCK',
  '{"message": "AgriTrust Trust Ledger Initialized on Cardano Preview Testnet"}'::jsonb,
  '0x0000000000000000000000000000000000000000000000000000000000000000'
)
on conflict do nothing;
