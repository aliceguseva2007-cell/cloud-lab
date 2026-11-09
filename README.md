# Отчёт. Лабораторная работа 2 (Docker)

Создаем плохой образ так его и называем ( он плох тем что нет ни версий ни ignor , все сохраняется все пароли и тд , пересборка долгая , работаем в root )

## Плохой образ

Плохой докер:

![image1](lab2/screenshots/image1.png)

Сначала мы запускает контейнер (это уже рабочий вариан) и спрашивает, под каким пользователем работает процесс

![image2](lab2/screenshots/image2.png)

пересобирает образ с секундомером

![image3](lab2/screenshots/image3.png)

Размер:

![image4](lab2/screenshots/image4.png)

## Хороший образ

Создаем хороший докер

![image5](lab2/screenshots/image5.png)

Сравнение

![image6](lab2/screenshots/image6.png)

![image7](lab2/screenshots/image7.png)

## Фронтенд и nginx

Создаем фронтенд докер

![image8](lab2/screenshots/image8.png)

Создаем frontend/nginx.conf

nginx –это веб-сервер: программа, которая отдаёт браузеру страницу сайта и пересылает запросы /api/... бэкенду. В вашей лабе он работает в отдельном контейнере для фронтенда на порту 80.

Поменяли это

![image9](lab2/screenshots/image9.png)

На это

![image10](lab2/screenshots/image10.png)

Чтобы он работал через nginx а не просто в порт стучался)

## База данных и compose

Создаем init.sql

![image11](lab2/screenshots/image11.png)

Чтобы когда проект загружали на другой комп у них и sql работал , ну это еще нужно для compose docker , ну как раз чтобы все собрать

Создаем файл docker-compose

```yaml
services:
  db:
    image: postgres:16-alpine
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - pgdata:/var/lib/postgresql/data
      - ./db/init.sql:/docker-entrypoint-initdb.d/init.sql:ro
    networks:
      - backend_net
  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile.good
    environment:
      DB_HOST: db
      DB_PORT: 5432
      DB_NAME: ${DB_NAME}
      DB_USER: ${DB_USER}
      DB_PASSWORD: ${DB_PASSWORD}
    depends_on:
      - db
    networks:
      - frontend_net
      - backend_net
  frontend:
    build: ./frontend
    ports:
      - "8080:80"
    depends_on:
      - backend
    networks:
      - frontend_net
volumes:
  pgdata:
networks:
  frontend_net:
  backend_net:
```

создаем и запускаем контейнер:

![image12](lab2/screenshots/image12.png)

и выводим его данные:

![image13](lab2/screenshots/image13.png)

## Проверки

1) Заходим не под root

![image14](lab2/screenshots/image14.png)

2) Переходим по ссылке http://localhost:8080/

![image15](lab2/screenshots/image15.png)

3) Данные переживут если мы закроем сессию

![image16](lab2/screenshots/image16.png)

![image17](lab2/screenshots/image17.png)

![image18](lab2/screenshots/image18.png)

Заметки остались)

4) Фронтенд изолировал

![image19](lab2/screenshots/image19.png)

5) Проверка подключен ли backend к db

![image20](lab2/screenshots/image20.png)

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

Решили сделать промежутки измерения меньше вот теперь видно один раз 500 а дальше 200 снова

![image27](lab2/screenshots/image27.png)

Запускаем программу ab чтобы максимально нагрузить сайт нагружаем на 3000 пользователей одновременно 30

![image28](lab2/screenshots/image28.png)

![image29](lab2/screenshots/image29.png)

![image30](lab2/screenshots/image30.png)

![image31](lab2/screenshots/image31.png)

Docker stat

![image32](lab2/screenshots/image32.png)

Воть в целом это все ,спасибо что все прочли , писали своими словами не судите строго

![image33](lab2/screenshots/image33.jpeg)
