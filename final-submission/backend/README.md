# Python backend

Вебзастосунок на стандартній бібліотеці Python 3 із live DevOps dashboard.
Додаткові Python-пакети та зовнішні frontend-залежності не потрібні.

## Запуск

У теці `final-submission` виконайте:

```sh
python backend/app.py
```

Сервер слухає `0.0.0.0:8000`. Відкрийте http://localhost:8000/ у браузері.
Для зупинки натисніть `Ctrl+C` у терміналі сервера.

## Сторінки та API

- `GET /` — адаптивний dashboard із live-даними Kubernetes;
- `GET /api/status` — JSON із даними runtime;
- `GET /healthz` — мінімальний healthcheck для probes;
- інші шляхи — HTTP 404.

Приклад відповіді `GET /api/status`:

```json
{
  "status": "ok",
  "service": "dan-it-backend",
  "ip": "172.31.12.11",
  "environment": "AWS EKS",
  "release": "359aa5ae",
  "uptime_seconds": 16,
  "runtime": "Python 3.12"
}
```

## Налаштування

| Змінна середовища | Типове значення | Призначення |
| --- | --- | --- |
| `PORT` | `8000` | Порт HTTP-сервера |
| `POD_IP` | Визначається за hostname | IP у відповіді; у Kubernetes передамо `status.podIP` через Downward API |
| `APP_VERSION` | `development` | Версія розгорнутого образу |

Публічний API навмисно не повертає назву pod, namespace, hostname node,
повний SHA образу, точну patch-версію Python або лічильник запитів. Це зменшує
обсяг службової інформації, доступної без автентифікації.

Локально поле `ip` містить адресу, отриману через hostname комп'ютера. Якщо адресу не вдалося визначити, повертається `unknown`.

Щоб змінити порт у PowerShell перед запуском:

```powershell
$env:PORT = '8080'
python backend/app.py
```

Перевірка в іншому терміналі PowerShell:

```powershell
Invoke-WebRequest -Uri http://localhost:8000/ -UseBasicParsing | Select-Object StatusCode, Content
```

Якщо змінили порт, замініть `8000` у запиті на обране значення.

## Перевірка в поточному середовищі

Сервер перевірено на Python 3.12.13: [протокол HTTP-запитів](../evidence/01-backend-local.md).
На цьому комп'ютері команда `python` посилається на непрацююче віртуальне середовище, тому для перевірки використано вбудований у Codex інтерпретатор.
Для повторного запуску з теки `final-submission` у PowerShell:

```powershell
& 'C:\Users\Trezor\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' backend/app.py
```

В іншому середовищі використовуйте його встановлений Python 3; цей локальний шлях переносити не потрібно.
