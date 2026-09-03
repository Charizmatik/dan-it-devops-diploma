# Готовність матеріалів

Позначка виконання означає наявність відповідного результату, а не лише плану.

## Підпункти етапу 1

- [x] Підготовлено Python backend: `GET /` повертає HTTP 200 та IP адресу.
- [x] Локально перевірено HTTP 200 для `/` і HTTP 404 для невідомого шляху на Python 3.12.13. [Протокол](evidence/01-backend-local.md).
- [x] Підготовлено й перевірено Dockerfile: образ зібрано, контейнер повертає HTTP 200 та власну IP адресу, процес працює з UID 10001. [Протокол](evidence/02-docker-local.md).
- [x] Підготовлено й перевірено GitHub Actions та публікацію образу в Docker Hub. [Успішний запуск](https://github.com/Charizmatik/dan-it-devops-diploma/actions/runs/33680105744).
- [x] Образ із Docker Hub завантажено та запущено локально; підтверджено HTTP 200, IP контейнера та UID 10001.
- [x] Збережено скріни GitHub Actions і тегів Docker Hub та протоколи перевірок. [Матеріали етапу 1](evidence/03-ci-publication.md).

## Етапи завдання

| Етап | Код підготовлено | Перевірено в цільовому середовищі | Докази збережено |
| --- | --- | --- | --- |
| 1. Python backend, Docker, GitHub Actions, Docker Hub | [x] | [x] | [x] |
| 2. EKS, одна node group з одним node, nginx ingress | [x] | [x] | [x] |
| 3. ArgoCD через Terraform і DNS | [ ] | [ ] | [ ] |
| 4. Deployment, Service, Ingress і DNS застосунку | [ ] | [ ] | [ ] |
| 5. ArgoCD Application та автоматичне оновлення | [ ] | [ ] | [ ] |

- [ ] Додано інструкції відтворення в окремому середовищі.
- [ ] Описано параметри та необхідні Secrets без їхніх значень.
- [ ] Зібрано скріни за пунктами завдання для захисту.
- [ ] Підготовлено інструкції видалення створених хмарних ресурсів.
- [ ] Перевірено склад теки для перенесення й відсутність секретів.

## Підпункти етапу 2

- [x] Підготовлено Terraform для EKS у наявній VPC.
- [x] Одна managed node group має `min_size = desired_size = max_size = 1`.
- [x] Node group використовує EKS-оптимізований Amazon Linux 2023 AMI.
- [x] ingress-nginx описано як Helm release з одним controller replica та AWS NLB.
- [x] Чужі VPC/subnet IDs, домен, backend state та інші значення шаблону вилучено.
- [x] Додано безпечний приклад параметрів та інструкції створення, перевірки й видалення.
- [x] Локально виконано `terraform init`, `terraform fmt -check` і `terraform validate`.
- [x] Перевірено `terraform plan` з фактичними AWS-параметрами: 9 add, 0 change, 0 destroy.
- [x] Ресурси реально створено в AWS.
- [x] Підтверджено один `Ready` node та працездатний ingress-nginx.
- [x] Збережено фактичні скріни AWS і kubectl для захисту.
- [x] Збережено окремий скрін активних namespace, включно з `ingress-nginx`.
