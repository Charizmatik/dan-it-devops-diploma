# ArgoCD через Terraform і DNS

Terraform-код етапу 3 розташовано у
[`terraform/eks/argocd.tf`](terraform/eks/argocd.tf). Він:

- встановлює non-HA ArgoCD офіційним Helm chart `argo-cd` версії `10.4.0`;
- створює namespace `argocd`;
- публікує UI через наявний ingress-nginx і спільний AWS NLB;
- використовує DNS-ім'я `argocd.mikoladolia.pp.ua` у власному домені студента;
- за наявності Route53 hosted zone створює CNAME автоматично;
- інакше виводить `argocd_dns_target` для створення запису власником DNS-зони.

Для єдиного `t3.small` node вимкнено необов'язкові Dex, notifications controller
та ApplicationSet controller. Для основних компонентів встановлено помірні
requests і limits. Це навчальна non-HA конфігурація, а не production-схема.

## DNS

Номер групи — 13. Для студентів із власним AWS-акаунтом куратор дозволив
використовувати власний домен. Зареєстровано безкоштовний домен:

```text
argocd.mikoladolia.pp.ua
```

DNS-запис створюється в панелі NIC.UA, оскільки в AWS-акаунті немає Route53
hosted zone. Тип запису — CNAME, ім'я — `argocd`, ціль — значення Terraform
output `argocd_dns_target` (NLB ingress-nginx), TTL — 3600 секунд (мінімальне
значення в DNS-сервісі NIC.UA).

Terraform також підтримує два способи керування DNS:

1. Якщо public hosted zone доступна у поточному AWS-акаунті, записати її ID у
   `argocd_route53_zone_id`. Terraform створить CNAME на NLB ingress-nginx.
2. Якщо зоною керує куратор або інший DNS-провайдер, залишити значення `null`.
   Після apply передати власнику DNS hostname зі значення `argocd_url` і ціль
   із `argocd_dns_target` або створити такий CNAME у власній зоні.

У поточній конфігурації `argocd_route53_zone_id = null`, тому Terraform не
створює Route53 record, а лише повертає точну DNS-ціль. Домен
`mikoladolia.pp.ua` підтверджено через офіційний реєстр PP.UA 2026-09-04.

## Перевірка і застосування

У каталозі `final-submission/terraform/eks`:

```powershell
terraform fmt -check -recursive
terraform init
terraform validate
terraform plan -out=argocd.tfplan
terraform apply argocd.tfplan
```

Після apply:

```powershell
kubectl get pods,service,ingress -n argocd
kubectl get ingress -n argocd -o wide
terraform output argocd_url
terraform output argocd_dns_target
Resolve-DnsName argocd.mikoladolia.pp.ua
Invoke-WebRequest http://argocd.mikoladolia.pp.ua
```

Очікується, що основні pods ArgoCD мають стан `Running`, Ingress містить
потрібний host, DNS повертає CNAME/адреси NLB, а HTTP-запит відкриває UI ArgoCD.
Перший DNS lookup може запрацювати не одразу через TTL і поширення запису.

## ArgoCD Application і автоматична доставка

Декларативний ресурс п'ятого етапу розташовано у
[`argocd/application.yaml`](argocd/application.yaml). Application стежить за
гілкою `main` публічного репозиторію та збирає Kustomize-маніфести з
`final-submission/k8s`.

Політика `automated` увімкнена разом із `prune` та `selfHeal`: нові коміти
синхронізуються автоматично, видалені з Git ресурси прибираються з кластера, а
ручний drift виправляється відповідно до Git. Namespace також може бути
створено через sync option `CreateNamespace=true`.

Застосувати bootstrap-ресурс один раз:

```powershell
kubectl apply -f argocd/application.yaml
kubectl wait --for=jsonpath='{.status.sync.status}'=Synced `
  application/dan-it-backend -n argocd --timeout=180s
kubectl wait --for=jsonpath='{.status.health.status}'=Healthy `
  application/dan-it-backend -n argocd --timeout=180s
```

Після bootstrap усі зміни Deployment, Service та Ingress потрібно робити в
Git, а не застосовувати вручну. Фактичну автоматичну доставку окремого коміту
перевірено в EKS: [протокол GitOps auto-sync](evidence/15-argocd-gitops-live.md).

07.09.2026 додатково перевірено повний цикл зміни backend: CI публікує образ,
комітить SHA-тег, ArgoCD автоматично виконує rollout.
[Новий протокол зі скрінами Application, policy та sync history](evidence/29-gitops-end-to-end.md).

Початковий пароль адміністратора отримати локально, не додавати до Git і не
залишати на скрінах:

```powershell
$encoded = kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath='{.data.password}'
[Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($encoded))
```

Логін: `admin`. Після першого входу пароль потрібно змінити.

## Докази для захисту

Зберегти до `evidence/` скріни без паролів і токенів:

- `terraform apply` із доданим Helm release і, за можливості, DNS record;
- `kubectl get pods,service,ingress -n argocd`;
- browser з UI ArgoCD за DNS-іменем;
- Route53 record або панель іншого DNS-провайдера;
- сторінка ArgoCD з версією, але без секретних даних.

## Видалення

Перед видаленням ArgoCD видалити Application каскадно, щоб його finalizer
прибрав керовані ресурси застосунку:

```powershell
kubectl delete -f argocd/application.yaml
```

Після цього ArgoCD і його DNS record, якщо ним керує Route53, входять до того
самого Terraform state та видаляються загальною командою `terraform destroy`.
Через `crds.keep = false` Helm не залишає CRD ArgoCD після видалення release.
Записи власного DNS-провайдера NIC.UA потрібно видалити окремо.
