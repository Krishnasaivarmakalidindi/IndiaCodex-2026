import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
// @ts-ignore
import wasm from 'vite-plugin-wasm'

// https://vite.dev/config/
export default defineConfig({
  base: '/IndiaCodex-2026/',
  plugins: [
    react(),
    wasm()
  ],
  define: {
    global: 'globalThis',
  },
  build: {
    target: 'esnext'
  }
})
