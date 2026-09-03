# EKS, одна node group та ingress-nginx

Terraform-код розташовано в [`terraform/eks/`](terraform/eks/). Він створює:

- EKS-кластер Kubernetes 1.35 у наявній VPC;
- одну managed node group рівно з одним EC2 node (`min = desired = max = 1`);
- ingress-nginx 4.15.1 через Helm у namespace `ingress-nginx`;
- публічний AWS Network Load Balancer для ingress controller.

Код адаптовано з наданого навчального прикладу. Чужі VPC/subnet IDs, домен
`devops8.test-danit.com`, спільний S3 backend, ACM, ExternalDNS та EBS CSI не
перенесено. ACM, DNS та ArgoCD належать наступним етапам. Terraform state,
кеш провайдерів та локальний `terraform.tfvars` не можна додавати до Git.

Навчальне завдання прямо вимагає nginx ingress controller, тому використано
[ingress-nginx](https://github.com/kubernetes/ingress-nginx). Проєкт
заархівований 24 березня 2026 року; chart 4.15.1 є його останнім релізом і
пройшов E2E-перевірки з Kubernetes 1.35. Для нового production-проєкту потрібна
окрема оцінка підтримуваної альтернативи, але для цього дипломного стенда
версії зафіксовано сумісною парою.

## Передумови

- Terraform `>= 1.7`;
- AWS CLI з профілем або іншим безпечним способом автентифікації;
- `kubectl`;
- наявна VPC і щонайменше дві subnet у різних Availability Zones;
- для node у вибраних subnet має бути вихід до інтернету через Internet Gateway
  або NAT Gateway, щоб завантажити системні та ingress-nginx образи;
- права AWS на EKS, EC2, IAM та Elastic Load Balancing.

Terraform і AWS Load Balancer створюють платні ресурси. Після демонстрації їх
потрібно видалити командою `terraform destroy`.

Для поточного тестового акаунта використано `t3.small`: AWS позначає його як
Free Tier eligible, а 2 GiB пам'яті придатніші для EKS add-ons, ingress-nginx і
подальшого ArgoCD, ніж 1 GiB у `t3.micro`.

## Параметри

1. Скопіювати `terraform.tfvars.example` у локальний `terraform.tfvars`.
2. Заповнити AWS region, профіль, назву кластера, VPC, subnet IDs та власну
   публічну IPv4 адресу у форматі `/32`.
3. Не комітити `terraform.tfvars`.

У PowerShell власну публічну адресу можна переглянути так:

```powershell
(Invoke-RestMethod https://checkip.amazonaws.com).Trim() + "/32"
```

Terraform перевіряє, що всі subnet належать указаній `vpc_id` та охоплюють
щонайменше дві Availability Zones.

## Створення

У каталозі `final-submission/terraform/eks` виконати:

```powershell
terraform fmt -check
terraform init
terraform validate
terraform plan -out=eks.tfplan
terraform apply eks.tfplan
```

Локальний state підходить для навчального запуску в одному середовищі. Для
віддаленого state спочатку окремо створити унікальний S3 bucket і, за потреби,
DynamoDB lock table, потім скопіювати `backend.tf.example` у `backend.tf` та
заповнити значення до `terraform init`.

Після успішного apply Terraform виведе команду `configure_kubectl_command`.
Виконати її, а потім перевірити кластер:

```powershell
kubectl get nodes -o wide
kubectl get namespaces
kubectl get pods -n ingress-nginx -o wide
kubectl get service -n ingress-nginx ingress-nginx-controller
```

Очікуваний результат: один node у стані `Ready`, pod ingress controller у стані
`Running`, а Service має тип `LoadBalancer` і заповнений `EXTERNAL-IP`/hostname.
Створення hostname NLB після `terraform apply` іноді займає кілька хвилин.

## Докази для захисту

Зберегти до `evidence/` скріни без секретів:

- AWS Console: кластер у стані `Active`;
- вкладка Compute: одна node group з desired/min/max = 1;
- `kubectl get nodes -o wide`: рівно один `Ready` node;
- `kubectl get pods -n ingress-nginx -o wide`;
- `kubectl get service -n ingress-nginx ingress-nginx-controller` з hostname NLB.

## Видалення

З того самого каталогу й з тим самим state виконати:

```powershell
terraform plan -destroy
terraform destroy
```

Після завершення перевірити в AWS, що EKS cluster і створений ingress NLB
видалені. Не видаляти спільну VPC або subnet: цей Terraform-код їх не створює.
