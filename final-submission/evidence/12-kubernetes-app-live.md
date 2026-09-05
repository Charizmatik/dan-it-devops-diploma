# Фактична перевірка Kubernetes-застосунку

Дата перевірки: 5 вересня 2026 року.

## Розгортання

Маніфести з `final-submission/k8s/` застосовано до EKS-кластера `trezor`:

```text
namespace/dan-it-backend created
service/dan-it-backend created
deployment.apps/dan-it-backend created
ingress.networking.k8s.io/dan-it-backend created
deployment "dan-it-backend" successfully rolled out
```

Фактичний стан після rollout:

```text
deployment.apps/dan-it-backend   1/1   1   1
pod/dan-it-backend-7dd7777b9b-n5pms   1/1   Running   0
service/dan-it-backend   ClusterIP   10.100.197.243   80/TCP
ingress.networking.k8s.io/dan-it-backend   nginx   app.mikoladolia.pp.ua
```

Deployment використовує образ:

```text
mikoladolia/dan-it-backend:sha-a3d755c05d915d6a3b24948512b28a3a6db47a80
```

Service має EndpointSlice на фактичний pod:

```text
NAME                   ADDRESSTYPE   PORTS   ENDPOINTS
dan-it-backend-f74cg   IPv4          8000    172.31.12.11
```

## Перевірка Ingress до створення DNS

Запит на Network Load Balancer із Host-заголовком застосунку перевірив повний
маршрут `NLB → ingress-nginx → Service → pod`:

```text
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8

{"status": "ok", "ip": "172.31.12.11"}
```

IP у відповіді збігся з `status.podIP`: `172.31.12.11`.

## DNS

У NIC.UA створено та повторно прочитано з таблиці DNS запис:

```text
app   3600   CNAME   a1c1c754f56d9462b8b7de20717f5220-fbf34f3104150947.elb.eu-central-1.amazonaws.com.
```

Авторитетний сервер `ns10.uadns.com` і публічний Google DNS `8.8.8.8`
повернули однаковий CNAME. Kubernetes Ingress також отримав цю адресу NLB.

## Публічна HTTP-перевірка

Запит за фінальним DNS-іменем успішний:

```text
GET http://app.mikoladolia.pp.ua/
HTTP/1.1 200 OK
Content-Type: application/json; charset=utf-8

{"status": "ok", "ip": "172.31.12.11"}
```

На момент фінальної перевірки pod мав стан `1/1 Running`, `0` рестартів, а IP
у публічній відповіді збігався з IP pod.

## Обмеження доказів

Вбудований браузер Codex заблокував відкриття plain HTTP URL на рівні клієнта.
HTTP-доступ спочатку перевірено фактичним мережевим запитом, а згодом окремо
збережено повнорозмірний скрін live dashboard:
[`14-dashboard-live.png`](14-dashboard-live.png). Це обмеження браузера не було
помилкою Kubernetes, Ingress або DNS.
