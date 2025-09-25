FROM node:18

# Create app directory
WORKDIR /app

# Install deps first (cache friendly)
COPY package*.json ./
RUN npm install --legacy-peer-deps

# Copy rest of app
COPY . .

# Generate Prisma client (safe at build time)
RUN npx prisma generate

# Build Next for production (optional for dev; remove if you want dev image)
# If you prefer to run dev in container, change this to `CMD ["npm","run","dev"]`
RUN npm run build

# Expose dev port (app should bind to 0.0.0.0)
EXPOSE 3000

# Default command — run Next in dev mode so hot reload works in your volume mount.
# If you instead want production serve, change to `npm start`.
CMD ["npm", "run", "dev", "--", "-H", "0.0.0.0"]