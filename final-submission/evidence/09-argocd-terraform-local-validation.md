# Локальна перевірка Terraform для етапу 3

Перевірено 2026-09-04 у `final-submission/terraform/eks`.

Виконано:

```powershell
terraform fmt -recursive
terraform init -backend=false
terraform validate
```

Результат:

- Terraform CLI `1.16.0`;
- встановлено й зафіксовано у `.terraform.lock.hcl` provider
  `hashicorp/kubernetes 2.38.0`;
- повторно використано `hashicorp/aws 5.100.0` і `hashicorp/helm 2.17.0`;
- `terraform validate`: `Success! The configuration is valid.`

Це підтверджує синтаксис і узгодженість конфігурації. Після повторного входу в
AWS фактичні `plan`, `apply` та перевірку кластера виконано; результати наведено
в [10-argocd-live.md](10-argocd-live.md).
