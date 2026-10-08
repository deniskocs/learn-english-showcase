import { defineConfig, loadEnv } from 'vite'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '')
  if (!env.VITE_API_BASE_URL) {
    throw new Error(
      `VITE_API_BASE_URL is required (mode=${mode}). Copy .env.example to .env.local or set .env.${mode}.`
    )
  }
  if (!env.VITE_GOOGLE_CLIENT_ID) {
    throw new Error(
      `VITE_GOOGLE_CLIENT_ID is required (mode=${mode}). Copy .env.example to .env.local or set .env.${mode}.`
    )
  }

  return {
    server: {
      host: true,
      port: 5173,
      strictPort: true,
    },
    preview: {
      host: true,
      port: 5173,
      strictPort: true,
    },
  }
})
