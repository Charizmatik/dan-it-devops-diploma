# Матеріали дипломної роботи DevOps

Ця тека призначена для накопичення матеріалів фінальної здачі.
Користувач виконає фінальну збірку в окремому середовищі та оформить результат окремою текою в [репозиторії курсу](https://github.com/Charizmatik/dan-it-devops-13-practice).

## Поточний стан

Підготовлено [Python backend](backend/README.md): `GET /` повертає HTTP 200 і JSON з IP адресою.
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
Стан робіт і доказів: [CHECKLIST.md](CHECKLIST.md).

## Запланований склад

- Python backend: відповідь HTTP 200 на `/`, бажано з IP адресою пода.
- Dockerfile та інструкції локального запуску.
- GitHub Actions workflow для збірки й публікації образу в Docker Hub.
- Terraform для EKS з однією node group та одним node, nginx ingress controller і ArgoCD.
- Kubernetes manifests: Deployment, Service, Ingress.
- ArgoCD Application з автоматичною синхронізацією.
- Інструкції розгортання, перевірки, демонстрації оновлення й видалення створених ресурсів.
- Скріни та підтвердження виконання в `evidence/`.

## Визначені параметри

- Робочий репозиторій для CI/GitOps: https://github.com/Charizmatik/dan-it-devops-diploma.
- Основна гілка: `main`.
- Docker Hub namespace: `mikoladolia`.
- Образ Docker Hub: `mikoladolia/dan-it-backend`.
- EKS Kubernetes version: `1.35`.
- ingress-nginx Helm chart: `4.15.1`.

## Параметри, які потрібно визначити

- Назва теки для здачі.
- Номер групи, назва кластера, AWS region та спосіб доступу до AWS.
- Домен групи, DNS-імена застосунку та ArgoCD, спосіб створення DNS-записів.

Конкретні значення та команди відтворення додаватимуться після узгодження й перевірки.
Секрети не входять до матеріалів здачі.

## Особливості перенесення

GitHub Actions запускає workflow з `.github/workflows/` у корені репозиторію.
Якщо матеріали здаються вкладеною текою, workflow потрібно розмістити в кореневій `.github/workflows/` робочого репозиторію та налаштувати шляхи до коду.
Шляхи ArgoCD до маніфестів також мають відповідати фактичному розташуванню матеріалів.

## Докази виконання

Додавати лише фактичні результати запусків. Для скрінів зазначати, який пункт завдання вони підтверджують; приховувати секрети перед збереженням.
