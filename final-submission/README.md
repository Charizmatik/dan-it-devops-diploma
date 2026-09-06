# Дипломна робота DevOps

Python-застосунок працює в AWS EKS. GitHub Actions збирає Docker-образ,
публікує його в Docker Hub і оновлює тег у Kubernetes-маніфесті. ArgoCD
відстежує зміни в репозиторії та розгортає нову версію застосунку.

Основний звіт із кодом і скриншотами: [diploma.md](diploma.md).

## Застосунок та інфраструктура

- [Застосунок](http://app.mikoladolia.pp.ua): dashboard зі статусом сервісу, IP pod і версією образу.
- [ArgoCD](http://argocd.mikoladolia.pp.ua): керування розгортанням застосунку.
- [GitHub](https://github.com/Charizmatik/dan-it-devops-diploma): код, маніфести й workflow.
- [Docker Hub](https://hub.docker.com/r/mikoladolia/dan-it-backend/tags): опубліковані образи.

Кластер `trezor` розміщений у `eu-central-1`. Він має одну node group
`trezor-workers` з одним `t3.small` node. Вхідний трафік проходить через
AWS Network Load Balancer та ingress-nginx. Terraform створює кластер
і встановлює ingress-nginx та ArgoCD через Helm.

## Автоматичне оновлення

1. Зміна backend у гілці `main` запускає GitHub Actions.
2. Workflow збирає образ, перевіряє HTTP-відповіді та запуск без root.
3. Після перевірки образ публікується з тегами `latest` і `sha-<commit>`.
4. Job `update-gitops` оновлює `image` та `APP_VERSION` у Deployment і створює коміт.
5. ArgoCD синхронізує маніфест і запускає нову версію застосунку.

Цей цикл перевірено 07.09.2026: зміна backend `4a9d766` запустила
[CI](https://github.com/Charizmatik/dan-it-devops-diploma/actions/runs/34062070590),
pipeline оновив маніфест у коміті `0321103`, після чого ArgoCD завершив
розгортання зі станом `Synced / Healthy`.

## Документація

| Файл | Зміст |
| --- | --- |
| [backend/README.md](backend/README.md) | Backend та локальний запуск |
| [DOCKER.md](DOCKER.md) | Збірка і запуск контейнера |
| [CI.md](CI.md) | Workflow, теги образів і GitHub Secrets |
| [EKS.md](EKS.md) | Створення та видалення інфраструктури |
| [ARGOCD.md](ARGOCD.md) | Встановлення ArgoCD і налаштування Application |
| [KUBERNETES.md](KUBERNETES.md) | Deployment, Service та Ingress |
| [DOMAIN.md](DOMAIN.md) | Домен, DNS-записи та їх обслуговування |
| [GITOPS-VERIFICATION.md](GITOPS-VERIFICATION.md) | Як перевірити оновлення застосунку |
| [CHECKLIST.md](CHECKLIST.md) | Виконані пункти завдання |

## Параметри середовища

| Параметр | Значення |
| --- | --- |
| Група | DevOps 13 |
| AWS region | `eu-central-1` |
| EKS cluster | `trezor` |
| Kubernetes | `1.35` |
| Node | `t3.small`, кількість — 1 |
| ingress-nginx Helm chart | `4.15.1` |
| ArgoCD Helm chart | `10.4.0` |
| Основна гілка | `main` |
| Docker image | `mikoladolia/dan-it-backend` |
| DNS-провайдер | NIC.UA |
| Terraform state | локальний; для S3 є `backend.tf.example` |

Для розгортання потрібні Terraform, AWS CLI, kubectl, доступ до AWS,
наявна VPC та subnets у різних Availability Zones. Параметри задаються
в локальному `terraform.tfvars` за прикладом `terraform.tfvars.example`.
Для CI потрібні GitHub Secrets `DOCKERHUB_USERNAME` і `DOCKERHUB_TOKEN`.

## Перенесення в інший репозиторій

Workflow потрібно розмістити в `.github/workflows/` кореня репозиторію.
Якщо тека проєкту зміниться, слід оновити шляхи збірки та маніфесту
у workflow, а також `repoURL` і `path` у ArgoCD Application.

## Результати перевірки

У [evidence/](evidence/) зібрано скриншоти GitHub Actions, Docker Hub,
AWS, ArgoCD і застосунку, а також результати команд перевірки.
[Перевірка автоматичного оновлення](evidence/29-gitops-end-to-end.md)
містить коміти, версію образу та стан pod до і після розгортання.
