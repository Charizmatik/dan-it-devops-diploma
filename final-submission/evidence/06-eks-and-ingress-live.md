# Фактичне розгортання EKS та ingress-nginx

Дата перевірки: 2026-09-03. Регіон: `eu-central-1`.

## Terraform

Підсумковий apply успішний. Після додавання зрозумілих `Name` tags повторний
`terraform plan -detailed-exitcode` завершився з кодом `0` і повідомленням:

```text
No changes. Your infrastructure matches the configuration.
```

Локальний `terraform.tfvars`, state, plans і `.terraform/` ігноруються Git.

## EKS і node group

AWS API підтвердив:

```text
cluster: trezor
Kubernetes: 1.35
node group: trezor-workers
status: ACTIVE
instance type: t3.small
min / desired / max: 1 / 1 / 1
health issues: []
```

`kubectl get nodes -o wide` повернув рівно один node:

```text
NAME                                           STATUS   AGE   VERSION
ip-172-31-0-47.eu-central-1.compute.internal   Ready    98s   v1.35.7-eks-cb19647
```

EC2 instance працює на Amazon Linux 2023, має Terraform-керований тег
`Name = trezor-worker`. Його root EBS volume `gp3`, 20 GiB, має тег
`Name = trezor-worker-root`. Auto Scaling Group поширює ім'я на майбутній
replacement node.

Скрін активного control plane: [05-eks-control-plane.png](05-eks-control-plane.png).
Скрін активної node group з `t3.small` і scaling `1/1/1`:
[06-eks-node-group-active.png](06-eks-node-group-active.png).

## ingress-nginx

Helm release `ingress-nginx` 4.15.1 встановлено у namespace `ingress-nginx`.

```text
NAME                                        READY   STATUS    RESTARTS
ingress-nginx-controller-6c7cd85885-px5mp   1/1     Running   0
```

Service `ingress-nginx-controller` має тип `LoadBalancer`. AWS створив
internet-facing Network Load Balancer; після переходу в `active` його DNS
успішно резолвився. HTTP-запит без налаштованого Ingress повернув `404`, що є
очікуваною відповіддю default backend ingress-nginx і підтверджує доступність
controller через NLB.

Скрін `kubectl` з одним `Ready` node, controller `1/1 Running` і Service
`LoadBalancer`: [07-kubectl-node-and-ingress.png](07-kubectl-node-and-ingress.png).

Скрін списку namespace підтверджує, що `ingress-nginx` має статус `Active`:
[08-kubectl-namespaces.png](08-kubectl-namespaces.png).

## Виправлена проблема Free Tier

Початковий `t3.medium` із навчального прикладу тестовий акаунт відхилив як
непридатний для Free Tier. EC2 instance не було створено. Порожню невдалу node
group видалено; AWS API після cleanup повертає лише `trezor-workers`. Серед
дозволених x86_64 типів обрано `t3.small` (2 vCPU, 2 GiB), після чого node group
та ingress-nginx створилися успішно.

## Стан доказів

Для етапу 2 збережено скріни control plane, параметрів єдиної node group,
активних namespace та результатів `kubectl` з ingress-nginx і hostname Network
Load Balancer.
