# Перевірка автоматичного оновлення

Нижче наведено порядок перевірки доставки нової версії backend у EKS.
Результати запуску від 07.09.2026 наведено у
[протоколі наскрізної доставки](evidence/29-gitops-end-to-end.md).

## Передумови

Активні EKS `trezor` у `eu-central-1`, ArgoCD Application `dan-it-backend`,
доступ kubectl до правильного контексту, чинні Docker Hub Secrets і дозвіл
workflow на запис у `main`.

## Наскрізний сценарій

1. Опублікувати workflow та дочекатися успішних `build` і `update-gitops`.
2. Зафіксувати поточні pod UID, image та revision Application командами нижче.
3. Окремим комітом змінити API у `backend/app.py` та видимий текст у `backend/static/`, не
   редагуючи `k8s/`. Записати повний SHA цього source-коміту.
4. Дочекатися CI: образ `sha-<source SHA>` опубліковано, job `update-gitops`
   створив окремий GitOps-коміт з новими `image` і `APP_VERSION`.
5. Дочекатися автоматичної синхронізації ArgoCD без натискання Sync і без
   `kubectl apply`, `set image` чи `rollout restart`. Перевірити, що
   `.status.sync.revision` відповідає GitOps-коміту (або пізнішому коміту з тим
   самим маніфестом), а не лише старий стан `Synced / Healthy`.
6. Перевірити новий pod UID, його image та imageID, успішний rollout,
   HTTP 200 і змінений текст dashboard. IP API має відповідати поточному pod.

```powershell
kubectl config current-context
kubectl get namespaces
kubectl get application dan-it-backend -n argocd -o jsonpath='{.status.sync.status}|{.status.health.status}|{.status.sync.revision}|{.status.operationState.phase}'
kubectl get deployment dan-it-backend -n dan-it-backend -o jsonpath='{.spec.template.spec.containers[0].image}'
kubectl get pods -n dan-it-backend -o custom-columns='NAME:.metadata.name,UID:.metadata.uid,IP:.status.podIP,IMAGE:.spec.containers[0].image,IMAGE_ID:.status.containerStatuses[0].imageID'
kubectl rollout status deployment/dan-it-backend -n dan-it-backend --timeout=180s
Invoke-RestMethod http://app.mikoladolia.pp.ua/api/status
```

## Результати перевірки

У [звіті про оновлення](evidence/29-gitops-end-to-end.md) наведено коміт backend,
запуск CI, коміт маніфесту, digest образу та стан pod до і після розгортання.
До звіту додано скриншоти:

- Application: `Synced / Healthy`, revision та дерево ресурсів.
- Application details: repo, `main`, шлях, destination namespace та auto-sync policy.
- Sync history: час і revision автоматичної операції після коміту pipeline.
- Namespaces: `argocd`, `dan-it-backend`, `ingress-nginx`.
- GitHub Actions: обидва успішні jobs, summary з тегом і GitOps-комітом.
- Dashboard після оновлення з видимою зміною та DNS-адресою.
