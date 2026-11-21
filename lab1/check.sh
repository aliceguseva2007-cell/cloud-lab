#!/bin/bash
echo "=== 1. HTTP редирект на HTTPS ==="
curl -sI http://myapp.local | head -1

echo -e "\n=== 2. Балансировка /api (чередование инстансов в заголовке) ==="
for i in {1..6}; do
  curl -sk -D - -o /dev/null https://myapp.local/api/notes | grep -i "X-Backend-Instance"
done

echo -e "\n=== 3. /admin без пароля (ожидаем 401) ==="
curl -sk -o /dev/null -w "%{http_code}\n" https://myapp.local/admin/

echo -e "\n=== 4. Флуд запросами (ожидаем 429) ==="
for i in {1..30}; do
  curl -sk -o /dev/null -w "%{http_code} " https://myapp.local/api/notes &
done
wait

echo -e "\n\n=== 5. Чужой Host (other.local) ==="
curl -s -H "Host: other.local" http://127.0.0.1/

echo -e "\n=== 6. Кастомная 404 ==="
curl -sk https://myapp.local/this-page-does-not-exist

echo -e "\n=== 7. alias /docs ==="
curl -sk https://myapp.local/docs/help.html