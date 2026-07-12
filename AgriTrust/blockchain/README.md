# AgriTrust Smart Contracts 📜

The `blockchain` folder is reserved for our Cardano Smart Contracts (written in **Aiken**). 

## How Escrow Works in AgriTrust

1. **Locking Funds:**
   When a buyer accepts a farmer's offer, a transaction is constructed using **MeshJS** on the frontend. The buyer's ADA is sent to the Plutus Script (Escrow Contract) address.
   
2. **Datum & Redeemer:**
   - The **Datum** attached to the UTxO contains the `Farmer's Wallet Address`, the `Buyer's Wallet Address`, and the `Trade ID`.
   - The ADA is securely locked on-chain and cannot be moved by either party.

3. **Releasing Funds:**
   When the physical agricultural goods are delivered, the buyer triggers the "Confirm Delivery" action. A new transaction is constructed. The script validates that the transaction is signed by the buyer's private key (matching the Datum). If valid, the script allows the ADA to be transferred to the Farmer.

## Fallback Simulation (Hackathon Mode)

Writing and deploying Aiken contracts on Testnet can be susceptible to network congestion or API limits. To ensure zero downtime during a live hackathon pitch:

- The AgriTrust frontend wraps the MeshJS wallet calls in a `blockchainService.ts` abstraction layer.
- If a real transaction fails (or if no wallet is connected), the service gracefully falls back to generating simulated cryptographic hashes and records them directly into the **Trust Ledger**.
- This guarantees that the UI flow (Lock Escrow -> Confirm Delivery -> View QR Certificate) will always execute flawlessly on stage.
