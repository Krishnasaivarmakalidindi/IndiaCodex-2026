# AgriTrust Backend 🗄️

The backend of AgriTrust is completely serverless and runs on **Supabase**. We leverage Supabase's managed PostgreSQL database, Realtime subscriptions, and built-in Authentication to provide a lightning-fast, highly scalable architecture.

## 🏗️ Architecture

Instead of writing a traditional Node.js/Express API that acts as a middleman, AgriTrust connects directly to the database via PostgREST.

- **PostgreSQL:** The core database containing 10 relational tables.
- **Supabase Auth:** Handles JWT-based authentication for Farmers and Buyers.
- **Supabase Realtime:** Broadcasts database row changes via WebSockets instantly to connected clients (used for the live order book and negotiations).

## 🛠️ Database Schema

The database consists of the following core tables:

1. **`profiles`**: User information, trust scores, and roles.
2. **`products`**: Agricultural listings posted by farmers.
3. **`offers`**: Bids made by buyers on products.
4. **`orders`**: Executed trades that have moved to the contract phase.
5. **`contracts`**: Smart contract metadata linking the PostgreSQL row to the Cardano Blockchain transaction hash.
6. **`blockchain_logs`**: The core of the **Trust Ledger**. Every major state change is cryptographically hashed and chained to the previous block here.
7. **`wallets`** and **`wallet_transactions`**: Simulate and track ADA escrow balances.
8. **`reviews`**: Post-trade feedback driving the Trust Score algorithm.
9. **`notifications`**: Real-time alerts for users.

## 🚀 Deployment Instructions

If you wish to host your own instance of the AgriTrust backend:

1. Create a free account at [Supabase.com](https://supabase.com/).
2. Create a new Project.
3. Open the **SQL Editor** in the Supabase Dashboard.
4. Copy the entire contents of `schema.sql` (found in this folder) and run it. This will instantly build the 10 tables and insert mock seed data.
5. Go to **Authentication -> Providers** and disable "Confirm email" for smoother hackathon testing.
6. Go to **Database -> Replication** and enable Realtime for the `products`, `offers`, `orders`, and `blockchain_logs` tables.
7. Copy your `Project URL` and `anon key` into the frontend's `.env` file!

That's it! Your backend is live and highly scalable.
