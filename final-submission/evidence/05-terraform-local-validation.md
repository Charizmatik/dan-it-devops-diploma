# Локальна перевірка Terraform для етапу 2

Дата перевірки: 2026-09-03.

## Що перевірено

- `terraform fmt -recursive -check` — успішно;
- `terraform init -backend=false -input=false` — успішно;
- `terraform validate` — `Success! The configuration is valid.`;
- `git diff --check` — помилок пробілів не виявлено.

Під час `init` зафіксовано:

- Terraform CLI 1.16.0;
- `hashicorp/aws` 5.100.0;
- `hashicorp/helm` 2.17.0.

Файл `.terraform.lock.hcl` збережено разом із Terraform-кодом. Каталог
`.terraform/` і локальний інструмент `.tools/` ігноруються Git.

## Межі цієї перевірки

Це перевірка формату, HCL та схем провайдерів, а не доказ створення кластера.
Після налаштування тимчасового AWS login та профілю `danit-terraform` виконано
`terraform plan` з фактичними параметрами тестового акаунта. Результат:
`9 to add, 0 to change, 0 to destroy`. Перший apply створив EKS `trezor`;
фактична версія control plane за AWS API — 1.35. ingress-nginx 4.15.1 офіційно
пройшов E2E-перевірки з Kubernetes 1.35.

Під час створення node group тестовий AWS-акаунт відхилив `t3.medium` як не
дозволений для Free Tier. EC2 instance не було створено. AWS API показав
доступні x86_64 типи; конфігурацію змінено на `t3.small` (2 vCPU, 2 GiB), а
робочу групу названо `trezor-workers`. Порожню невдалу групу
`trezor-node-group` передано на видалення через EKS API.

Скрін активного control plane збережено як `05-eks-control-plane.png`. Фінальні
докази node group, `kubectl` та ingress потрібно додати після завершення apply.
