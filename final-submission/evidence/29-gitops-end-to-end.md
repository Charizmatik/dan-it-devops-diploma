# Повний цикл backend → CI → Git → ArgoCD → EKS

Перевірено 07.09.2026, близько 00:40–00:52 за Києвом (UTC+03:00).
У JSON час Kubernetes/GitHub подано як 06.09.2026 21:xx UTC — це той самий момент.

## Виправлення

У workflow додано окремий job `update-gitops` з `contents: write`, залежний
від успішного `build`. Після публікації він змінює лише image та APP_VERSION
у Deployment і записує коміт через GITHUB_TOKEN. Є перевірка застарілих build
inputs, ідемпотентність та звичайний push без force. PR не публікують образи
та не запускають цей job. Також `.dockerignore` тепер включає dashboard assets.

Початкове виправлення:
[`20daf2c`](https://github.com/Charizmatik/dan-it-devops-diploma/commit/20daf2cf9fe45f593285c7c7a5060aa65b8880f4),
[успішний run](https://github.com/Charizmatik/dan-it-devops-diploma/actions/runs/34061846356),
коміт бота `b3f932424ab284b98c3e40188c13da43eca133b7`.
Його ArgoCD також автоматично розгорнув.

## Окрема демонстрація зміни лише backend

| Ланка | Фактичний результат |
| --- | --- |
| Source-коміт | [`4a9d7664d5f4a94e027ad2165764e2ceb991389f`](https://github.com/Charizmatik/dan-it-devops-diploma/commit/4a9d7664d5f4a94e027ad2165764e2ceb991389f) |
| Зміни source | Лише `backend/app.py`, `backend/static/app.js`, `backend/static/index.html`; додано delivery в API і UI |
| GitHub Actions | [34062070590](https://github.com/Charizmatik/dan-it-devops-diploma/actions/runs/34062070590): build — success, update-gitops — success |
| Образ | `mikoladolia/dan-it-backend:sha-4a9d7664d5f4a94e027ad2165764e2ceb991389f` |
| GitOps-коміт бота | [`032110361c104a3c4391c87c2c3c2690d78e0fac`](https://github.com/Charizmatik/dan-it-devops-diploma/commit/032110361c104a3c4391c87c2c3c2690d78e0fac) |
| ArgoCD sync revision | `032110361c104a3c4391c87c2c3c2690d78e0fac` |
| Ініціатор sync | `operation.initiatedBy.automated = true` |
| Завершення sync | `2026-09-06T21:49:03Z`, phase `Succeeded` |
| Стан Application після rollout | `Synced / Healthy` |
| Pod до зміни | `dan-it-backend-7487f795bd-s6lcj`, UID `e88fa3e6-8b71-491e-9d84-91ea434e0999` |
| Pod після зміни | `dan-it-backend-86d74f84fb-95dk9`, UID `a3a9c4b3-7f21-4aba-99bf-bffce09aaadf` |
| API | HTTP 200, IP `172.31.0.19`, release `4a9d7664`, delivery `GitHub Actions → Git → ArgoCD` |

`kubectl rollout status` завершився повідомленням
`deployment "dan-it-backend" successfully rolled out`.
Під час досліду не виконували ручні Sync, `kubectl apply`, `set image` чи
`rollout restart`. Відкриття Details і History у UI було лише читанням.

Docker Hub digest тегу та фактичний pod imageID збігаються:

```text
sha256:3bf49024948c03bb01f3d882f74fce1b6eea7d36fb23c59fda42e3a9ee9968df
```

Окремий linux/amd64 manifest у відповіді Docker Hub має digest
`sha256:2b203a7e7ebbb995e167178646421d115e4643f7ce8bcb6555c2101793400e66`.
Pod imageID у цьому середовищі посилається на digest індексу тегу.

## Фактичні файли доказів

- [Application до виправлення](17-gitops-before-application.json), [pods](17-gitops-before-pods.json).
- [Application перед окремою зміною backend](18-gitops-baseline-application.json), [pods](18-gitops-baseline-pods.json).
- [Фінальний Application](23-gitops-final-application.json), [Deployment](23-gitops-final-deployment.json), [pods](23-gitops-final-pods.json).
- [CI jobs та їхні steps](23-gitops-ci-jobs.json), [Docker Hub tag](23-gitops-dockerhub-tag.json), [відповідь API](23-gitops-api-status.json).
- [Destination Application](20-argocd-application-destination.png), [source та automated/prune/selfHeal](21-argocd-source-autosync-policy.png).
- [Успішні jobs CI](24-github-actions-end-to-end.png), [фінальний Synced / Healthy](25-argocd-final-synced-healthy-tree.png), [історія автоматичних sync](26-argocd-automated-sync-history.png).
- [Змінений текст dashboard](27-dashboard-updated-copy.png), [новий release та delivery](28-dashboard-final-release.png).
- [Актуальні namespaces і Ready node — текст](22-namespaces-and-node-live.txt), [скрин](22-namespaces-and-node-live.png).

Скрин namespaces — знімок браузера, що відображає збережений фактичний вивід
kubectl; це не знімок вікна термінала. [HTML](22-namespaces-and-node-live.html)
містить той самий вивід для читання. Скріни ArgoCD, GitHub і dashboard знято
безпосередньо з відповідних живих сторінок.

## Мережа та Terraform state

AWS API додатково підтвердив IsDefault=true для VPC vpc-09037eb9ea04df9f8
та DefaultForAz=true для всіх трьох subnet у eu-central-1a/b/c.

Terraform state зберігається локально. Для S3 backend підготовлено опційний
шаблон `terraform/eks/backend.tf.example`.
