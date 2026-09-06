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
| 3. ArgoCD через Terraform і DNS | [x] | [x] | [x] |
| 4. Deployment, Service, Ingress і DNS застосунку | [x] | [x] | [x] |
| 5. ArgoCD Application та auto-sync маніфестів | [x] | [x] | [x] текстовий протокол |
| 5а. Backend → CI → SHA у Git → автоматичний rollout | [x] | [x] | [x] |

- [x] Додано інструкції відтворення в окремому середовищі.
- [x] Описано параметри та необхідні Secrets без їхніх значень.
- [x] Доповнено докази фінальними скрінами Application, sync history і всіх namespace.
- [x] Підготовлено інструкції видалення створених хмарних ресурсів.
- [x] Перевірено склад теки для перенесення й відсутність секретів.

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

## Підпункти етапу 3

- [x] ArgoCD описано як Terraform `helm_release` з зафіксованою версією chart.
- [x] Додано namespace `argocd` та Ingress через наявний ingress-nginx.
- [x] Host налаштовано у власному домені: `argocd.mikoladolia.pp.ua`.
- [x] Додано опційний Route53 CNAME та output цілі для зовнішнього DNS.
- [x] Конфігурацію оптимізовано для єдиного `t3.small` node.
- [x] Локально виконано `terraform fmt`, `init` і `validate`.
- [x] Підтверджено власний домен `mikoladolia.pp.ua`; DNS керується через NIC.UA.
- [x] Виконано `terraform plan`: 1 add, 0 change, 0 destroy.
- [x] ArgoCD реально встановлено в EKS; основні pods мають стан `Running`.
- [x] У NIC.UA створено CNAME `argocd` на ingress-nginx NLB з TTL 3600.
- [x] Публічний Google DNS резолвить ім'я на ingress-nginx NLB.
- [x] HTTP-маршрут за host ArgoCD повертає `200 OK` і HTML із title `Argo CD`.
- [x] Збережено фактичний скрін UI ArgoCD за DNS-іменем без пароля адміністратора.
- [x] Задокументовано реєстратора, реєстрову активацію PP.UA, NS, DNS-записи,
  строки дії та порядок відновлення у [DOMAIN.md](DOMAIN.md).

## Підпункти етапу 4

- [x] Підготовлено namespace, Deployment, Service, Ingress і Kustomization.
- [x] Deployment використовує перевірений immutable SHA-тег образу з Docker Hub.
- [x] `POD_IP` передається через Downward API; додано readiness і liveness probes.
- [x] Контейнер працює без root із базовими обмеженнями security context.
- [x] Ingress налаштовано для `app.mikoladolia.pp.ua` через IngressClass `nginx`.
- [x] Додано інструкції застосування, перевірки, DNS і видалення ресурсів.
- [x] Маніфести застосовано в EKS; Deployment успішно завершив rollout.
- [x] Підтверджено pod `Running`, Service endpoints та адресу Ingress.
- [x] У NIC.UA створено CNAME `app` на поточний ingress-nginx NLB.
- [x] Публічний DNS резолвить `app.mikoladolia.pp.ua`.
- [x] HTTP-запит за DNS-іменем повертає 200 і фактичний IP pod.
- [x] Збережено фактичний текстовий протокол четвертого етапу.
- [x] Збережено повнорозмірний скрін live dashboard після розгортання.
- [x] Додано live DevOps dashboard, JSON API та окремий health endpoint.
- [x] Новий образ зібрано й опубліковано успішним GitHub Actions run.
- [x] EKS Deployment оновлено на immutable dashboard-тег; rollout успішний.

## Підпункти етапу 5

- [x] Підготовлено декларативний ArgoCD Application у `argocd/application.yaml`.
- [x] Source вказує на публічний GitHub-репозиторій, гілку `main` і шлях
  `final-submission/k8s`.
- [x] Увімкнено автоматичну синхронізацію, `prune` і `selfHeal`.
- [x] Application застосовано в namespace `argocd` і отримано стан
  `Synced / Healthy`.
- [x] Після окремого Git-коміту ArgoCD автоматично перейшов на ревізію
  `c8e8e54fe796c43a573a8185707c71151eac2c32`.
- [x] Автоматичний rollout завершився успішно; новий pod працює, публічний API
  повертає HTTP 200.
- [x] Фактичний результат зафіксовано у
  [протоколі GitOps auto-sync](evidence/15-argocd-gitops-live.md).

## Автоматична доставка backend

- [x] Підготовлено job запису нового SHA-тега та APP_VERSION у Git після публікації.
- [x] Новий workflow опубліковано й успішно виконано у GitHub Actions.
- [x] Зміна лише backend спричинила публікацію, коміт бота та rollout без ручної зміни маніфесту.
- [x] Збережено відповідність source SHA → image → GitOps SHA → ArgoCD revision → pod imageID.
- [x] Збережено скрін Application `Synced / Healthy` із деревом ресурсів.
- [x] Збережено скріни source/destination, automated/prune/selfHeal та історії sync.
- [x] Збережено актуальний скрін namespaces з `argocd`, `dan-it-backend`, `ingress-nginx`.

Попередній rollout через зміну annotation підтверджує auto-sync маніфестів,
але не наскрізне оновлення backend. [Порядок перевірки](GITOPS-VERIFICATION.md).

Наскрізний цикл підтверджено 07.09.2026: [протокол і докази](evidence/29-gitops-end-to-end.md).
Скрин namespaces відображає збережений фактичний вивід kubectl у браузері.
