# Full-Stack School Management System

A **Next.js + Prisma + PostgreSQL** based school management system with Docker support.  
This project implements role-based dashboards for **Admin, Teacher, Student, and Parent**, with complete data management (announcements, assignments, attendance, classes, exams, results, etc.).

---

## 🚀 Features

- **Next.js (App Router)** with TypeScript and TailwindCSS  
- **Prisma ORM** with PostgreSQL  
- **Docker + Docker Compose** support  
- **Role-based dashboards** (Admin, Teacher, Student, Parent)  
- **Reusable UI Components** (Charts, Tables, Forms, etc.)  
- **Authentication ready** (Clerk integration placeholders)  
- **Database Seeding** with Prisma  
- **Test route** (`/test`) for setup verification

---

## 🗂️ Project Structure

```bash
.
├── Dockerfile                # Docker build file for Next.js app
├── docker-compose.yml        # Docker Compose for PostgreSQL + Next.js
├── next.config.mjs           # Next.js configuration
├── package.json              # Project dependencies
├── prisma/                   # Prisma schema, migrations, and seeds
│   ├── schema.prisma         # Prisma schema definition
│   ├── migrations/           # Database migrations
│   ├── seed.ts               # Database seed script (TypeScript)
│   └── build/seed.js         # Compiled seed script for Node.js
├── public/                   # Static assets (icons, images, logos)
├── src/
│   ├── app/                  # App router pages
│   │   ├── (dashboard)/      # Role-based dashboards
│   │   ├── [[...sign-in]]/   # Auth pages (Clerk-ready)
│   │   └── test/             # Test route for validation
│   ├── components/           # Reusable UI components
│   ├── lib/                  # Utility functions, Prisma client, configs
│   └── middleware.ts         # Middleware (auth, logging, etc.)
├── tailwind.config.ts        # TailwindCSS configuration
└── tsconfig.json             # TypeScript configuration
```

---

## ⚙️ Setup Instructions

### 1️⃣ Clone the repository

```bash
git clone <your-repo-url>
cd full-stack-school
```

### 2️⃣ Install dependencies

```bash
npm install
```

### 3️⃣ Configure environment variables

Create a `.env.local` file in the project root with the following example (edit values):

```env
DATABASE_URL="postgresql://myuser:mypassword@localhost:5432/mydb?schema=public"

NEXT_PUBLIC_CLERK_FRONTEND_API=""
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=""
CLERK_SECRET_KEY=""
```

> **Important**: When running the app **inside Docker**, `DATABASE_URL` can point to `postgres:5432` (container hostname). When running Next on your host (`npm run dev`), set `DATABASE_URL` to `localhost:5432` so host processes can reach the DB.

---

### 4️⃣ Run with Docker (recommended)

```bash
# Build and start services (Next.js + PostgreSQL)
docker compose up -d --build

# Show running containers
docker ps
```

---

### 5️⃣ Setup Prisma

```bash
# Generate Prisma client
npx prisma generate

# Apply schema to the database
npx prisma db push
```

---

### 6️⃣ Seed the database

If `prisma/build/seed.js` already exists, run:

```bash
node prisma/build/seed.js
```

If you only have the TypeScript seed (`prisma/seed.ts`), compile and run:

```bash
# compile TS seed to JS
npx tsc prisma/seed.ts --outDir prisma/build --module CommonJS --target ES2020

# run compiled seed
node prisma/build/seed.js
```

If Prisma cannot connect to `postgres:5432` while running on the host, set the env for this terminal to `localhost`:

```powershell
$env:DATABASE_URL="postgresql://myuser:mypassword@localhost:5432/mydb?schema=public"
node prisma/build/seed.js
```

---

### 7️⃣ Run the app

```bash
# Start Next.js in dev mode (host)
npm run dev

# Or if running inside Docker, ensure app service is started by compose:
docker compose up -d --build
```

Open: **http://localhost:3000**

---

## ✅ Clerk configuration (how I fixed it)

If you use Clerk for authentication, after creating an app and a user in the Clerk dashboard, perform these steps to attach role metadata and enable session metadata for role checks:

1. In Clerk dashboard → **Users** → click your created user → scroll to **User metadata** → edit the **Public** metadata and add:

```json
{
  "role": "admin"
}
```

2. In Clerk dashboard → **Configure** → **Session** → click **Edit** and add the following JSON so sessions include user public metadata:

```json
{ "metadata": "{{user.public_metadata}}" }
```

This allows the app's middleware and auth checks to read `role` from the session.

---

## ✅ Testing & Verification (preflight checks used during development)

Run these checks to ensure DB and app connectivity before declaring the setup healthy.

### A. Containers & ports

```bash
docker ps --format "table {{.Names}}	{{.Status}}	{{.Ports}}"
```

Expect:
- `postgres` container with `0.0.0.0:5432->5432/tcp`
- `app` container (if exposed) with `0.0.0.0:3000->3000/tcp`

### B. Postgres readiness

```bash
docker logs <postgres_container_name> --tail 50
```

Look for:
```
database system is ready to accept connections
```

### C. Host network reachability (when running Next on host)

PowerShell:
```powershell
Test-NetConnection -ComputerName localhost -Port 5432
# Expect: TcpTestSucceeded : True
```

macOS/Linux:
```bash
nc -zv localhost 5432
# expect "succeeded"
```

### D. Prisma connectivity

Ensure terminal uses correct `DATABASE_URL` (host or container) before running:

```powershell
$env:DATABASE_URL="postgresql://myuser:mypassword@localhost:5432/mydb?schema=public"
npx prisma generate
npx prisma db push
```

### E. Seed verification

```bash
node prisma/build/seed.js

# quick check for inserted admins
$env:DATABASE_URL="postgresql://myuser:mypassword@localhost:5432/mydb?schema=public"; node -e "const {PrismaClient}=require('@prisma/client');(async()=>{const p=new PrismaClient();console.log('admins:', await p.admin.count());await p.$disconnect();})()"
```

Expect numeric output like `admins: 1`.

### F. Browser checks

- Open devtools (F12) → Console: watch for errors.
- Network tab: reload `http://localhost:3000` and check for failing requests (4xx/5xx).
- If the page is blank, check server terminal for stack traces.

---

## 🛠️ Common Issues & Fixes (just in case or if)

- **Prisma: Environment variable not found: DATABASE_URL**  
  - Don't run `npx prisma` during Docker build. Run migrations/seeds at runtime inside container or set env for host.

- **Can't reach database server at `postgres:5432`**  
  - Host process connecting to `postgres` hostname fails. Either run Next inside Docker (so `postgres` resolves), or set `DATABASE_URL` to `localhost` when running Next on host.

- **TypeScript seed execution errors**  
  - Install `ts-node` or compile seed to JS using `tsc`.

- **Dockerfile running Prisma at build fails**  
  - Remove migration step from Dockerfile; run migrations in container at runtime.

---

## 🧾 Dev Preflight Checklist (copy-paste)

```bash
# 1. Build and start containers
docker compose up -d --build

# 2. Wait for Postgres
docker logs $(docker ps --filter "name=postgres" -q) --tail 50

# 3. If running Next on host, set DB URL for this terminal:
# PowerShell:
$env:DATABASE_URL="postgresql://myuser:mypassword@localhost:5432/mydb?schema=public"

# 4. Prisma + seed
npx prisma generate
npx prisma db push
node prisma/build/seed.js

# 5. Start Next (host)
npm run dev
```

---


<!-- 

## 📹 Demo Video

Full walkthrough: [YouTube Video](https://youtu.be/6sfiAyKy8Jo?si=7fMZFfT9I1bSyZ_a)

---

## 📝 Git Commit Example

```bash
git add .
git commit -m "fix: resolve docker-compose and dependency issues, add middleware and test setup"
git push origin main
```

---

## 👨‍💻 Author

- **Paras Saxena** — Full-Stack Developer | DevOps Enthusiast

--- 

-->
