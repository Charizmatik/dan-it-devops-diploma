# Перевірка виправлення автоматичної доставки

Статус 07.09.2026: workflow виправлено локально. Цей документ — сценарій
майбутньої перевірки, а не доказ виконання в AWS.

## Передумови

Активні EKS `trezor` у `eu-central-1`, ArgoCD Application `dan-it-backend`,
доступ kubectl до правильного контексту, чинні Docker Hub Secrets і дозвіл
workflow на запис у `main`. Саме відкриття AWS Console не надає CLI-доступу.

## Наскрізний сценарій

1. Опублікувати виправлений workflow та дочекатися успішних `build` і `update-gitops`.
2. Зафіксувати поточні pod UID, image та revision Application командами нижче.
3. Окремим комітом змінити видимий текст dashboard у `backend/app.py`, не
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

## Докази, які потрібно зберегти

У `evidence/` додати фактичний протокол із датою, посиланнями на source-коміт,
CI run, GitOps-коміт, Docker digest та результати команд до/після.
Якщо використовувався multi-platform image index, відрізняти його digest
від digest платформи в pod imageID; перевірити зв'язок через registry manifest.

Потрібні справжні скріншоти:

- Application: `Synced / Healthy`, revision та дерево ресурсів.
- Application details: repo, `main`, шлях, destination namespace та auto-sync policy.
- Sync history: час і revision автоматичної операції після коміту бота.
- Namespaces: `argocd`, `dan-it-backend`, `ingress-nginx`.
- GitHub Actions: обидва успішні jobs, summary з тегом і GitOps-комітом.
- Dashboard після оновлення з видимою зміною та DNS-адресою.

Підтвердження дозволу на власний домен додати окремо з наданого куратором
повідомлення, прибравши сторонні персональні дані. Наявний опис у DOMAIN.md
не замінює незалежного підтвердження. Не позначати відсутні докази виконаними.
