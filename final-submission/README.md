# Матеріали дипломної роботи DevOps

Короткий звіт у форматі здачі: [`diploma.md`](diploma.md).

Ця тека призначена для накопичення матеріалів фінальної здачі.
Користувач виконає фінальну збірку в окремому середовищі та оформить результат окремою текою в [репозиторії курсу](https://github.com/Charizmatik/dan-it-devops-13-practice).

## Поточний стан

Підготовлено [Python backend](backend/README.md): `GET /` повертає live DevOps
dashboard, а `/api/status` — JSON з IP та Kubernetes runtime-даними.
Локальну перевірку пройдено на Python 3.12.13: [протокол](evidence/01-backend-local.md).
Підготовлено [Dockerfile та інструкцію Docker](DOCKER.md).
Образ `dan-it-backend:local` зібрано та перевірено локально: HTTP 200, IP контейнера й запуск без root. [Протокол](evidence/02-docker-local.md).
Перший розділ виконано: [GitHub Actions](https://github.com/Charizmatik/dan-it-devops-diploma/actions/runs/33680105744) успішно збирає, перевіряє та публікує образ у [Docker Hub](https://hub.docker.com/r/mikoladolia/dan-it-backend/tags).
[Інструкція CI](CI.md) · [Підсумок перевірки та скріни](evidence/03-ci-publication.md).
Другий етап розгорнуто в тестовому AWS-акаунті: [Terraform-код EKS](EKS.md)
створив кластер `trezor`, одну managed node group `trezor-workers` з одним
`t3.small` node та ingress-nginx через Helm. Підтверджено `Ready` node,
controller `1/1 Running`, активний Network Load Balancer і нульовий Terraform
drift. [Фактичний протокол](evidence/06-eks-and-ingress-live.md).
Для третього етапу підготовлено [Terraform-код ArgoCD і DNS](ARGOCD.md):
офіційний Helm chart `argo-cd` 10.4.0, Ingress через наявний ingress-nginx,
опційний Route53 CNAME і конфігурація для одного `t3.small` node. Для власного
домену зареєстровано `mikoladolia.pp.ua`; host ArgoCD —
`argocd.mikoladolia.pp.ua`. Terraform встановив ArgoCD у EKS; усі основні pods
мають стан `Running`, а Ingress містить потрібний host і адресу спільного NLB.
У NIC.UA створено відповідний CNAME; публічний Google DNS уже повертає запис,
а HTTP-перевірка маршруту через NLB повернула `200 OK` і сторінку `Argo CD`.
[Фактичний протокол](evidence/10-argocd-live.md).
[Повна документація домену, реєстратора, NS і DNS](DOMAIN.md).
Четвертий етап розгорнуто й перевірено: [Kubernetes manifests](KUBERNETES.md)
створили окремий namespace, Deployment із перевіреним SHA-тегом образу,
Service та Ingress для `app.mikoladolia.pp.ua`. У NIC.UA створено CNAME `app`
на спільний ingress-nginx NLB. Публічний DNS резолвить ім'я, HTTP повертає
`200 OK`, а IP у JSON збігається з IP pod.
[Фактичний протокол](evidence/12-kubernetes-app-live.md).
Dashboard з live-даними зібрано в
[GitHub Actions](https://github.com/Charizmatik/dan-it-devops-diploma/actions/runs/33973964536)
Після hardening dashboard розгорнуто в EKS як образ
`sha-359aa5ae88ed778544c152b34f4a85a2827b1292`. Публічний API не розкриває
назву pod, namespace, hostname node, повний SHA або точну patch-версію runtime.
[Перевірка dashboard](evidence/13-dashboard-live.md).
П'ятий етап виконано: [ArgoCD Application](argocd/application.yaml) стежить за
гілкою `main` і шляхом `final-submission/k8s`, автоматично синхронізує зміни,
видаляє вилучені з Git ресурси та виправляє drift. Фактичний коміт
`c8e8e54fe796c43a573a8185707c71151eac2c32` автоматично спричинив новий
rollout; Application повернувся до стану `Synced / Healthy`.
[Протокол GitOps auto-sync](evidence/15-argocd-gitops-live.md).
Стан робіт і доказів: [CHECKLIST.md](CHECKLIST.md).

## Запланований склад

- Python backend: відповідь HTTP 200 на `/`, бажано з IP адресою пода.
- Dockerfile та інструкції локального запуску.
- GitHub Actions workflow для збірки й публікації образу в Docker Hub.
- Terraform для EKS з однією node group та одним node, nginx ingress controller і ArgoCD.
- Kubernetes manifests: Deployment, Service, Ingress.
- ArgoCD Application з автоматичною синхронізацією — підготовлено й перевірено.
- Інструкції розгортання, перевірки, демонстрації оновлення й видалення створених ресурсів.
- Скріни та підтвердження виконання в `evidence/`.

## Визначені параметри

- Робочий репозиторій для CI/GitOps: https://github.com/Charizmatik/dan-it-devops-diploma.
- Основна гілка: `main`.
- Docker Hub namespace: `mikoladolia`.
- Образ Docker Hub: `mikoladolia/dan-it-backend`.
- EKS Kubernetes version: `1.35`.
- ingress-nginx Helm chart: `4.15.1`.
- ArgoCD Helm chart: `10.4.0`.
- Номер групи: `13`.
- Назва тестового EKS-кластера: `trezor`.
- Host ArgoCD у власному домені: `argocd.mikoladolia.pp.ua`.
- Host backend-застосунку: `app.mikoladolia.pp.ua`.
- Реєстратор і DNS-провайдер: NIC.UA; NS — `ns10/ns11/ns12.uadns.com`.
- Домен дійсний до 4 вересня 2027 року; NS-сервіс NIC.UA потрібно продовжити до
  4 грудня 2026 року.

## Параметри, які потрібно визначити

- Назва теки для здачі.
- DNS-записи власного домену керуються через NIC.UA; Route53 для них не
  використовується.

Конкретні значення й команди відтворення наведено у тематичних документах
`DOCKER.md`, `CI.md`, `EKS.md`, `ARGOCD.md`, `KUBERNETES.md` і `DOMAIN.md`.
Секрети не входять до матеріалів здачі; для CI потрібні лише GitHub Secrets
`DOCKERHUB_USERNAME` і `DOCKERHUB_TOKEN` без збереження їхніх значень у Git.

## Особливості перенесення

GitHub Actions запускає workflow з `.github/workflows/` у корені репозиторію.
Якщо матеріали здаються вкладеною текою, workflow потрібно розмістити в кореневій `.github/workflows/` робочого репозиторію та налаштувати шляхи до коду.
Шляхи ArgoCD до маніфестів також мають відповідати фактичному розташуванню матеріалів.

## Докази виконання

Додавати лише фактичні результати запусків. Для скрінів зазначати, який пункт завдання вони підтверджують; приховувати секрети перед збереженням.
