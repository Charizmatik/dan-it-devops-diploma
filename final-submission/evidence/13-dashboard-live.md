# Live DevOps dashboard

Дата перевірки: 5 вересня 2026 року.

Dashboard містить адаптивний інтерфейс, JSON API та окремий Kubernetes health
endpoint. Security-реліз `359aa5ae88ed778544c152b34f4a85a2827b1292`
мінімізував публічні runtime-дані.

[Security release run 33974912832](https://github.com/Charizmatik/dan-it-devops-diploma/actions/runs/33974912832)
завершився зі статусом `success`. Усі кроки, включно зі збіркою тестового
образу, smoke test, входом у Docker Hub і публікацією, завершилися успішно.

Опублікований і розгорнутий immutable образ:

```text
mikoladolia/dan-it-backend:sha-359aa5ae88ed778544c152b34f4a85a2827b1292
```

Rolling update в EKS завершився успішно:

```text
Deployment dan-it-backend   1/1 available   pod restarts: 0
```

Фактична зовнішня перевірка `http://app.mikoladolia.pp.ua`:

```text
Dashboard /        HTTP 200   text/html; charset=utf-8
CSS asset          HTTP 200
JavaScript asset   HTTP 200
/healthz           HTTP 200   status=ok
/api/status        HTTP 200   status=ok
```

API повернув:

```json
{
  "status": "ok",
  "ip": "172.31.12.11",
  "environment": "AWS EKS",
  "release": "359aa5ae",
  "runtime": "Python 3.12"
}
```

API додатково повертає uptime та серверний час. Назва pod, namespace, hostname
node, повний SHA, patch-версія Python і лічильник запитів відсутні. Dashboard
автоматично оновлює телеметрію кожні 5 секунд і не завантажує зовнішні
JavaScript/CSS залежності.

## Скріншот

Скріншот зроблено безпосередньо з живого URL у Chrome після завершення rollout:

![Live DevOps dashboard](14-dashboard-live.png)
