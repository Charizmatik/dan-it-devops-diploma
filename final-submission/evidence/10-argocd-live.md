# Фактичне розгортання ArgoCD і DNS

Перевірено 2026-09-04 у кластері EKS `trezor`, регіон `eu-central-1`.

## Terraform

Актуальний план після зміни host на `argocd.mikoladolia.pp.ua`:

```text
Plan: 1 to add, 0 to change, 0 to destroy.
```

Результат застосування:

```text
helm_release.argocd: Creation complete after 52s [id=argocd]
Apply complete! Resources: 1 added, 0 changed, 0 destroyed.
argocd_dns_managed_by_terraform = false
argocd_url = "http://argocd.mikoladolia.pp.ua"
```

DNS керується через NIC.UA, тому Route53 record навмисно не входить до state.
Terraform повернув NLB ingress-nginx як `argocd_dns_target`.

## Kubernetes

Команда `kubectl get pods,service,ingress -n argocd -o wide` підтвердила:

- `argocd-application-controller-0` — `1/1 Running`;
- `argocd-redis` — `1/1 Running`;
- `argocd-repo-server` — `1/1 Running`;
- `argocd-server` — `1/1 Running`;
- init job Redis — `Completed`;
- Ingress class — `nginx`;
- host — `argocd.mikoladolia.pp.ua`;
- address — наявний AWS NLB ingress-nginx;
- порт — `80`.

## DNS

Домен `mikoladolia.pp.ua` активовано до 4 вересня 2027 року. У NIC.UA домен
переведено з паркових NS на `ns10.uadns.com`, `ns11.uadns.com` і
`ns12.uadns.com`. Створено запис:

```text
argocd  3600  CNAME  <ingress-nginx NLB hostname>.
```

Публічний Google DNS-over-HTTPS повернув status `0` та підтвердив:

- NS: `ns10.uadns.com`, `ns11.uadns.com`, `ns12.uadns.com`;
- CNAME `argocd.mikoladolia.pp.ua` на потрібний NLB;
- TTL CNAME — `3600`.

Одразу після делегації локальний resolver ще тримав негативний DNS-кеш.
Після поширення DNS прямий HTTP-запит за звичайним URL
`http://argocd.mikoladolia.pp.ua` повернув:

```text
StatusCode        : 200
StatusDescription : OK
ContentType       : text/html; charset=utf-8
Title             : Argo CD
```

Таким чином підтверджено повний шлях: DNS → ingress-nginx NLB → ArgoCD UI.
Сторінка входу також відкрилася у Chrome та у вбудованому браузері.

Helm release має status `deployed`, revision `1`. Rollout controller,
repo-server і server завершився успішно. Фактично запущена версія ArgoCD —
`v3.5.1`; Terraform використовує chart `argo-cd` версії `10.4.0`.

Початковий пароль адміністратора не виводився у чат і не зберігався у доказах.

Фактичний вигляд сторінки входу через домен збережено у
[`11-argocd-login-page.png`](11-argocd-login-page.png). На скріні немає пароля
чи інших секретів.
