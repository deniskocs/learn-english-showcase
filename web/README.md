# Learn English — web

Статический фронт (Vite → nginx).

## Dev

```bash
cd web
cp .env.example .env.local
npm install
npm run dev
```

Откройте `http://localhost:5173/`.

## Build

```bash
npm run build   # → dist/
npm run preview
```

## Env

| Переменная | Назначение |
|------------|------------|
| `VITE_API_BASE_URL` | Backend API без trailing slash |
| `VITE_GOOGLE_CLIENT_ID` | Google Identity Services client ID |

Обязательны при `dev` / `build` (см. `vite.config.js`).
