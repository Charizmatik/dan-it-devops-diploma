# Python backend

Простий сервер на стандартній бібліотеці Python 3. Додаткові пакети не потрібні.

## Запуск

У теці `final-submission` виконайте:

```sh
python backend/app.py
```

Сервер слухає `0.0.0.0:8000`. Відкрийте http://localhost:8000/ у браузері.
Для зупинки натисніть `Ctrl+C` у терміналі сервера.

## Відповідь

`GET /` повертає HTTP **200** та JSON. Приклад (IP залежить від середовища):

```json
{"status": "ok", "ip": "192.168.1.10"}
```

Інші шляхи повертають HTTP **404**.

## Налаштування

| Змінна середовища | Типове значення | Призначення |
| --- | --- | --- |
| `PORT` | `8000` | Порт HTTP-сервера |
| `POD_IP` | Визначається за hostname | IP у відповіді; у Kubernetes передамо `status.podIP` через Downward API |

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
