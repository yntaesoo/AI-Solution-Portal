import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    port: 5173,
    strictPort: true,
    host: '127.0.0.1',
    allowedHosts: ['arfab.kr', 'www.arfab.kr'],
    hmr: {
      clientPort: 80
    },
    watch: {
      ignored: ['**/Data/**', '**/*.mp4', '**/*.pdf', '**/*.png', '**/*.jpg', '**/*.jpeg', '**/*.tmp', '**/~$*', '**/*.hwpx', '**/*.xlsx', '**/*.docx', '**/*.doc']
    }
  }
})
