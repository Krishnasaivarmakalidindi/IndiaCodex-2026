import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
// @ts-ignore
import wasm from 'vite-plugin-wasm'
import { nodePolyfills } from 'vite-plugin-node-polyfills'

// https://vite.dev/config/
export default defineConfig({
  base: '/IndiaCodex-2026/',
  plugins: [
    react(),
    wasm(),
    nodePolyfills()
  ],
  define: {
    global: 'globalThis',
  },
  build: {
    target: 'esnext'
  }
})
