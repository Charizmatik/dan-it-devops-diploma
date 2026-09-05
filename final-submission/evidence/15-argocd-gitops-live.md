# Фактична перевірка ArgoCD Application і auto-sync

Дата перевірки: 5 вересня 2026 року. Кластер: `trezor`, регіон:
`eu-central-1`.

## Що було налаштовано

До namespace `argocd` застосовано декларативний ресурс
[`Application`](../argocd/application.yaml) з такими параметрами:

- публічний репозиторій:
  `https://github.com/Charizmatik/dan-it-devops-diploma.git`;
- гілка: `main`;
- шлях маніфестів: `final-submission/k8s`;
- destination: поточний EKS-кластер, namespace `dan-it-backend`;
- автоматична синхронізація: `enabled: true`;
- автоматичне видалення вилучених із Git ресурсів: `prune: true`;
- виправлення ручного drift: `selfHeal: true`.

Після створення Application ArgoCD синхронізував уже наявні Deployment,
Service, Ingress і Namespace з ревізією
`05e2a938e76bbc8ee511ce34a8d0eea28bf1d3fb`. Початковий стан:

```text
Synced
Healthy
05e2a938e76bbc8ee511ce34a8d0eea28bf1d3fb
{"enabled":true,"prune":true,"selfHeal":true}
```

## Доказ автоматичного оновлення з Git

Для перевірки в pod template додано безпечну annotation
`gitops.dan-it.dev/deployed-by: argocd`. Маніфест і Application опубліковано
в `main` одним комітом:

```text
c8e8e54fe796c43a573a8185707c71151eac2c32
feat: enable ArgoCD automated delivery
```

[Коміт у GitHub](https://github.com/Charizmatik/dan-it-devops-diploma/commit/c8e8e54fe796c43a573a8185707c71151eac2c32)

Після `git push` не виконувалась команда `kubectl apply` для Kubernetes
маніфестів застосунку. ArgoCD сам виявив нову ревізію, створив новий
ReplicaSet, виконав rollout і завершив операцію о `2026-09-05T16:35:25Z`:

```text
Synced|Healthy|c8e8e54fe796c43a573a8185707c71151eac2c32|Succeeded|2026-09-05T16:35:25Z
argocd|1/1
```

Новий pod після автоматичного rollout:

```text
NAME                              READY   STATUS    RESTARTS   IP
dan-it-backend-68b56bdcbd-ktjmd   1/1     Running   0          172.31.0.19
```

Публічна перевірка `http://app.mikoladolia.pp.ua/api/status` після sync:

```json
{"status":"ok","service":"dan-it-backend","ip":"172.31.0.19","environment":"AWS EKS","release":"359aa5ae","uptime_seconds":20,"server_time":"2026-09-05T19:35:47+03:00","runtime":"Python 3.12"}
```

Результат: ArgoCD доставляє Kubernetes-маніфести з Git, автоматично реагує
на новий commit у `main`, виконує rollout і повертається до стану
`Synced / Healthy`.

## Команди повторної перевірки

```powershell
kubectl get application dan-it-backend -n argocd -o wide
kubectl get application dan-it-backend -n argocd `
  -o jsonpath='{.status.sync.status}{"|"}{.status.health.status}{"|"}{.status.sync.revision}{"`n"}'
kubectl rollout status deployment/dan-it-backend -n dan-it-backend
kubectl get pods -n dan-it-backend -o wide
Invoke-RestMethod http://app.mikoladolia.pp.ua/api/status
```
