import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vitejs.dev/config/
export default defineConfig({
  plugins: [react()],
  base: './', // CRITICAL FOR FIVEM: ensures asset paths are relative
  build: {
    outDir: 'dist',
    emptyOutDir: true,
  }
})
