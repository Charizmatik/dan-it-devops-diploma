# Запуск backend у Docker

Потрібен запущений Docker Engine для Linux-контейнерів (на Windows — Docker Desktop).
Локально встановлювати Python не потрібно.
Усі команди нижче виконуються з теки `final-submission`.

## Збірка образу

```sh
docker build -t dan-it-backend:local .
```

Використовується [офіційний образ Python](https://hub.docker.com/_/python) `3.12-slim-bookworm`.
Тег отримує оновлення Python 3.12 і базової ОС; digest фактично використаного образу видно в журналі збірки.
У контейнер копіюється лише `backend/app.py`; сторонні Python-пакети не потрібні.
Процес працює з UID/GID `10001:10001`, без root. Логи надходять у stdout/stderr.

## Запуск контейнера

```sh
docker run --detach --rm --name dan-it-backend -p 127.0.0.1:8000:8000 dan-it-backend:local
```

Відкрийте http://localhost:8000/ у браузері. Очікується HTTP 200 та DevOps
dashboard. Машинний JSON зі статусом і IP контейнера доступний на
http://localhost:8000/api/status, healthcheck — на http://localhost:8000/healthz.
Порт опублікований лише на локальному комп'ютері. `EXPOSE 8000` у Dockerfile описує порт; публікує його параметр `-p`.

Перевірка в PowerShell:

```powershell
Invoke-WebRequest -Uri http://localhost:8000/ -UseBasicParsing | Select-Object StatusCode, Content
```

Якщо локальний порт 8000 зайнятий, використайте `-p 127.0.0.1:8080:8000` та відкрийте http://localhost:8080/.
За потреби внутрішній порт можна змінити через `-e PORT=8080`, узгодивши його з правою частиною `-p`.

## Логи

```sh
docker logs dan-it-backend
```

## Зупинка

```sh
docker stop dan-it-backend
```

Завдяки `--rm` контейнер видалиться після зупинки. Зібраний образ залишиться для наступних запусків.

## Матеріали для захисту

Збережіть скрін успішної збірки та скрін відповіді застосунку разом із запущеним контейнером.
Образ `dan-it-backend:local` успішно зібрано й запущено локально. Перевірено HTTP 200, збіг IP у відповіді з IP контейнера та UID процесу 10001.
Для перевірки використано тимчасовий вільний порт хоста; після перевірки контейнер зупинено й видалено, образ залишено локально.
[Протокол перевірки](evidence/02-docker-local.md) містить журнал збірки та фактичні результати.
