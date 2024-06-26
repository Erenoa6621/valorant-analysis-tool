#!/bin/bash

# プロジェクトのルートディレクトリを設定
PROJECT_ROOT="$HOME/projects/valorant-analysis-tool"

# ディレクトリ構造の作成
mkdir -p $PROJECT_ROOT/{backend/app,frontend/{pages,components}}

# バックエンドのファイル作成
cat << EOF > $PROJECT_ROOT/backend/app/main.py
from fastapi import FastAPI

app = FastAPI()

@app.get("/")
def read_root():
    return {"Hello": "World"}

@app.get("/items/{item_id}")
def read_item(item_id: int, q: str = None):
    return {"item_id": item_id, "q": q}
EOF

cat << EOF > $PROJECT_ROOT/backend/requirements.txt
fastapi==0.68.0
uvicorn==0.15.0
sqlalchemy==1.4.23
psycopg2-binary==2.9.1
redis==3.5.3
scikit-learn==0.24.2
tensorflow==2.6.0
EOF

cat << EOF > $PROJECT_ROOT/backend/Dockerfile
FROM python:3.9

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY ./app /app

CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
EOF

# フロントエンドのファイル作成
cat << EOF > $PROJECT_ROOT/frontend/pages/index.js
import React from 'react'

const Home = () => {
  return (
    <div>
      <h1>Welcome to VALORANT Analysis Tool</h1>
      <p>This is the home page of our application.</p>
    </div>
  )
}

export default Home
EOF

cat << EOF > $PROJECT_ROOT/frontend/components/Layout.js
import React from 'react'

const Layout = ({ children }) => {
  return (
    <div>
      <header>
        <nav>
          <ul>
            <li><a href="/">Home</a></li>
            <li><a href="/analysis">Analysis</a></li>
          </ul>
        </nav>
      </header>
      <main>{children}</main>
      <footer>© 2024 VALORANT Analysis Tool</footer>
    </div>
  )
}

export default Layout
EOF

cat << EOF > $PROJECT_ROOT/frontend/package.json
{
  "name": "valorant-analysis-frontend",
  "version": "1.0.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start"
  },
  "dependencies": {
    "next": "12.0.0",
    "react": "17.0.2",
    "react-dom": "17.0.2",
    "@chakra-ui/react": "1.6.0",
    "d3": "7.0.0"
  }
}
EOF

cat << EOF > $PROJECT_ROOT/frontend/Dockerfile
FROM node:14

WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

CMD ["npm", "run", "dev"]
EOF

# docker-compose.ymlの作成
cat << EOF > $PROJECT_ROOT/docker-compose.yml
version: '3.8'

services:
  backend:
    build: ./backend
    volumes:
      - ./backend:/app
    ports:
      - "8000:8000"
    environment:
      - DATABASE_URL=postgresql://user:password@db/valorant_analysis
    depends_on:
      - db
      - redis

  frontend:
    build: ./frontend
    volumes:
      - ./frontend:/app
      - /app/node_modules
    ports:
      - "3000:3000"
    environment:
      - NEXT_PUBLIC_API_URL=http://backend:8000

  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=valorant_analysis
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:6

volumes:
  postgres_data:
EOF

# .envファイルの作成
cat << EOF > $PROJECT_ROOT/.env
DATABASE_URL=postgresql://user:password@db/valorant_analysis
POSTGRES_DB=valorant_analysis
POSTGRES_USER=user
POSTGRES_PASSWORD=password
EOF

echo "Project structure has been created successfully at $PROJECT_ROOT"