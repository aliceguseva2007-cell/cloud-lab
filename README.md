# Lab 0 — Notes Service

Приложение: фронт (HTML/JS) → бэкенд (Flask) → база (PostgreSQL).

## Стек
- Python 3.13, Flask
- PostgreSQL 17
- HTML/JS

## Требования
- Python 3.10+
- PostgreSQL
- Git

## Подготовка БД
```sql
CREATE DATABASE lab0db;
\c lab0db
CREATE TABLE notes (
  id SERIAL PRIMARY KEY,
  text TEXT NOT NULL,
  created_at TIMESTAMP DEFAULT NOW()
);
```

## Установка зависимостей
```bash
cd backend
pip install -r requirements.txt
```

## Настройка окружения
Создать `backend/.env` по образцу `backend/.env.example` и указать свой пароль Postgres.

## Запуск бэкенда
Из PyCharm: открыть `backend/app.py` → Run.
Или из терминала:
```bash
cd backend
python app.py
```
Бэкенд на http://localhost:5000 (проверка: `/api/health`).

## Запуск фронтенда
```bash
cd frontend
python -m http.server 8000
```
Открой http://localhost:8000

## Проверка
1. Ввести текст в форму → «Добавить».
2. Обновить страницу (F5) — запись сохраняется (значит, она в Postgres).

<img width="847" height="407" alt="Снимок экрана 2026-09-22 210854" src="https://github.com/user-attachments/assets/0d33b947-5481-426f-940d-bfc004a0d45e" />

## API
- `GET  /api/notes` — список
- `POST /api/notes` — создать `{ "text": "..." }`
- `GET  /api/health` — проверка живости
