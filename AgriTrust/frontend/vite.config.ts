import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import wasm from 'vite-plugin-wasm'
import topLevelAwait from 'vite-plugin-top-level-await'

// https://vite.dev/config/
export default defineConfig({
  base: '/IndiaCodex-2026/',
  plugins: [
    react(),
    wasm(),
    topLevelAwait()
  ],
  define: {
    global: 'globalThis',
  },
})
