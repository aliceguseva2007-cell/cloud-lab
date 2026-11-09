## Часть со звёздочкой

Мы переписываем docker-compose добавляем состояние здоровья ,автоматический перезапуск и порядок запуска

```yaml
services:
  db:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./db/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U $${POSTGRES_USER} -d $${POSTGRES_DB}"]
      interval: 5s
      timeout: 3s
      retries: 10
      start_period: 10s
    networks:
      - backend_net
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.good
    restart: unless-stopped
    environment:
      DB_HOST: db
      DB_PORT: 5432
      DB_NAME: ${DB_NAME}
      DB_USER: ${DB_USER}
      DB_PASSWORD: ${DB_PASSWORD}
    depends_on:
      db:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "python", "-c", "import urllib.request; urllib.request.urlopen('http://localhost:5000/api/health')"]
      interval: 5s
      timeout: 3s
      retries: 5
      start_period: 10s
    networks:
      - frontend_net
      - backend_net
  frontend:
    build: ./frontend
    restart: unless-stopped
    ports:
      - "8080:80"
    depends_on:
      backend:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "wget", "-q", "-O", "/dev/null", "http://127.0.0.1/"]
      interval: 5s
      timeout: 3s
      retries: 5
    networks:
      - frontend_net
volumes:
  pgdata:
networks:
  frontend_net:
  backend_net:
```

заново пере собираем

![image21](lab2/screenshots/image21.png)

Теперь все по очереди запускается

![image22](lab2/screenshots/image22.png)

Уронили сервис

![image23](lab2/screenshots/image23.png)

Так как сервис моментально перезагрузился этого даже не видно было

![image24](lab2/screenshots/image24.png)

Но вот здесь видно что все таки все работает))

![image25](lab2/screenshots/image25.png)

Перезапуск все таки произошел)

![image26](lab2/screenshots/image26.png)

Решила сделать промежутки измерения меньше вот теперь видно один раз 500 а дальше 200 снова

![image27](lab2/screenshots/image27.png)

Запускаем программу ab чтобы максимально нагрузить сайт нагружаем на 3000 пользователей одновременно 30

![image28](lab2/screenshots/image28.png)

![image29](lab2/screenshots/image29.png)

![image30](lab2/screenshots/image30.png)

![image31](lab2/screenshots/image31.png)

Docker stat

![image32](lab2/screenshots/image32.png)

Воть в целом это все ,спасибо что все прочли , писала своими словами не судите строго

![image33](lab2/screenshots/image33.jpeg)
