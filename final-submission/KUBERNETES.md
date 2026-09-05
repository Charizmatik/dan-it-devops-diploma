# Розгортання застосунку в Kubernetes

> Фактичний стан: ресурси застосовано до EKS-кластера `trezor` 5 вересня 2026
> року. Rollout завершився успішно, DNS створено, публічний HTTP-запит повернув
> `200 OK`. [Протокол перевірки](evidence/12-kubernetes-app-live.md).
> З 5 вересня 2026 року ці ресурси керуються ArgoCD з автоматичною
> синхронізацією. [Протокол GitOps](evidence/15-argocd-gitops-live.md).

Маніфести в теці `k8s/` реалізують четвертий етап завдання:

- namespace `dan-it-backend`;
- `Deployment` з одним pod і образом із Docker Hub;
- внутрішній `ClusterIP` Service на порту 80;
- Ingress через наявний ingress-nginx для host `app.mikoladolia.pp.ua`.

Deployment використовує перевірений незмінний тег
`sha-359aa5ae88ed778544c152b34f4a85a2827b1292`. IP pod береться з Kubernetes
Downward API й відображається на dashboard через `GET /api/status`. Назва pod,
namespace та hostname node навмисно не передаються у контейнер і не
публікуються. Readiness і liveness probes звертаються до `/healthz` на порту
8000. Контейнер працює без root, без Linux capabilities та з read-only root
filesystem.

## Передумови

- `kubectl` налаштований на потрібний EKS-кластер;
- ingress-nginx працює та має IngressClass `nginx`;
- публічний образ доступний у Docker Hub;
- DNS-запис `app.mikoladolia.pp.ua` вказує CNAME на hostname Network Load
  Balancer сервісу ingress-nginx.

## Застосування

Рекомендований спосіб після встановлення ArgoCD:

```powershell
kubectl apply -f argocd/application.yaml
```

Після bootstrap зміни в `k8s/` доставляються з гілки `main` автоматично.
Команда нижче залишається для первинної ручної перевірки до створення
Application або для аварійної діагностики:

З кореня `final-submission/`:

```powershell
kubectl apply -k k8s
kubectl rollout status deployment/dan-it-backend -n dan-it-backend
kubectl get pods,service,ingress -n dan-it-backend -o wide
```

Тека містить `kustomization.yaml`, тому той самий шлях можна буде використати
як source path для ArgoCD Application на п'ятому етапі.

## DNS

Отримати поточну ціль CNAME можна однією з команд:

```powershell
kubectl get service ingress-nginx-controller -n ingress-nginx `
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
terraform -chdir=terraform/eks output -raw argocd_dns_target
```

У NIC.UA потрібно створити запис:

```text
Ім'я:  app
TTL:   3600
Тип:   CNAME
Дані:  <поточний hostname ingress-nginx NLB>.
```

Оскільки ArgoCD і застосунок використовують той самий ingress-nginx, ціль
запису `app` має збігатися з ціллю наявного запису `argocd`. Якщо Service або
NLB буде створено заново, обидва CNAME потрібно оновити.

## Перевірка

Спочатку можна перевірити маршрутизацію без очікування DNS, передавши host
безпосередньо на NLB:

```powershell
$nlb = kubectl get service ingress-nginx-controller -n ingress-nginx `
  -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'
Invoke-WebRequest -Uri "http://$nlb/" -Headers @{ Host = 'app.mikoladolia.pp.ua' }
```

Після створення DNS-запису:

```powershell
Resolve-DnsName app.mikoladolia.pp.ua -Type CNAME
Invoke-RestMethod http://app.mikoladolia.pp.ua/
```

Очікується HTTP 200 та JSON на зразок:

```json
{"status":"ok","ip":"10.0.1.23"}
```

IP у відповіді має збігатися зі значенням `IP` у виводі:

```powershell
kubectl get pods -n dan-it-backend -o wide
```

## Видалення ресурсів застосунку

```powershell
kubectl delete -f argocd/application.yaml
```

Через finalizer ArgoCD каскадно видалить керовані ресурси. Якщо Application
вже не існує, резервна команда — `kubectl delete -k k8s`. DNS-запис `app`
видаляється окремо в NIC.UA. Ці команди не видаляють EKS, ingress-nginx,
ArgoCD або спільний Network Load Balancer.
