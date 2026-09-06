# Збірка та публікація через GitHub Actions

Робочий репозиторій: [Charizmatik/dan-it-devops-diploma](https://github.com/Charizmatik/dan-it-devops-diploma).
Образ: [mikoladolia/dan-it-backend](https://hub.docker.com/r/mikoladolia/dan-it-backend).

## Підтверджений результат

07.09.2026 повний цикл перевірено на зміні лише backend:
[CI run 34062070590](https://github.com/Charizmatik/dan-it-devops-diploma/actions/runs/34062070590)
успішно виконав `build` і `update-gitops`; бот створив коміт `0321103`,
ArgoCD автоматично розгорнув образ `sha-4a9d7664d5f4a94e027ad2165764e2ceb991389f`.
[Наскрізний протокол і скріни](evidence/29-gitops-end-to-end.md).

Попередній результат від 05.09.2026:

[Запуск dashboard](https://github.com/Charizmatik/dan-it-devops-diploma/actions/runs/33973964536)
від 05.09.2026 завершився успішно. Опубліковано `latest` і
`sha-37bae4d0ff8a1f9c0fbab11ecb5f481eb8e3626e`; цей immutable тег розгорнуто
в EKS. Початкова публікація та її скріни збережені в
[протоколі етапу 1](evidence/03-ci-publication.md).

## Як працює workflow

1. Після push у `main`, що змінює backend, Dockerfile, `.dockerignore` чи активний workflow, GitHub запускає збірку.
2. Збирається Linux/amd64 образ із контекстом `final-submission/`.
3. Тимчасовий контейнер перевіряється: dashboard на `/`, `/healthz`, JSON API,
   правильна IP адреса, HTTP 404 на невідомому шляху та UID 10001.
4. Після успішної перевірки виконується вхід у Docker Hub через GitHub Secrets.
5. Образ публікується з тегами `latest` і `sha-<повний SHA коміту>`. Digest виводиться в підсумку запуску.
6. Окремий job `update-gitops` після успішного build оновлює `image` та
   `APP_VERSION` у `final-submission/k8s/deployment.yaml` і комітить у `main`
   через `GITHUB_TOKEN` з job-level дозволом `contents: write`.
7. ArgoCD виявляє коміт маніфесту та автоматично запускає rollout нового образу.
   Успіх CI означає запис у Git; успіх доставки перевіряється окремо в ArgoCD/EKS.

Pull request до `main` запускає збірку та перевірку без публікації й без доступу до Docker Hub Secrets.
Workflow також можна запустити вручну через Actions → Build and publish backend → Run workflow для гілки `main`.
Зміни лише документації чи доказів не запускають нову публікацію.

Використано [офіційні Docker Actions](https://docs.docker.com/build/ci/github-actions/), зафіксовані на конкретних SHA комітів.

## Налаштування репозиторію

У Settings → Secrets and variables → Actions потрібні Repository secrets:

| Назва | Значення |
| --- | --- |
| `DOCKERHUB_USERNAME` | `mikoladolia` |
| `DOCKERHUB_TOKEN` | Personal access token Docker Hub із правами Read & Write |

Обидва секрети налаштовано. Значення токена не входить до матеріалів здачі.
Токен має строк дії 30 днів за поточним налаштуванням; після завершення строку потрібно створити новий і оновити GitHub Secret.

## Перевірка опублікованого образу

```sh
docker pull mikoladolia/dan-it-backend:latest
docker run --detach --rm --name dan-it-backend -p 127.0.0.1:8000:8000 mikoladolia/dan-it-backend:latest
```

Відкрийте http://localhost:8000/. Для зупинки:

```sh
docker stop dan-it-backend
```

Для відтворення конкретного запуску використовуйте тег `sha-<коміт>` або digest із протоколу, оскільки `latest` змінюється з наступними публікаціями.

## Перенесення в інший репозиторій

Активний workflow розміщено в `.github/workflows/docker-publish.yml` у корені робочого репозиторію.
Його копія для здачі міститься в `final-submission/.github/workflows/docker-publish.yml`.
GitHub не запускає workflow із вкладеної теки автоматично.

Після перенесення матеріалів:

- Скопіюйте workflow в кореневу `.github/workflows/` робочого репозиторію.
- Узгодьте `context`, `file` та фільтри `paths` із новим шляхом до коду.
- Оновіть також шляхи у `update-gitops`: перевірку build inputs, Python-редактор і `git add`.
- Якщо змінюється Docker Hub namespace або репозиторій образів, змініть `IMAGE_NAME` і налаштуйте Secrets відповідного акаунта.
- Перевірте назву основної гілки у тригерах та умовах публікації.

## Автоматичне оновлення GitOps

Виправлення від 07.09.2026 опубліковано та перевірено у GitHub і EKS.
Попередні публікації вимагали ручного оновлення Deployment; тепер це робить
job `update-gitops`. Додатково виправлено `.dockerignore`, щоб Docker build
отримував статичні файли dashboard, які копіює Dockerfile.

Для запису потрібна можливість push у `main` від `github-actions[bot]`.
`contents: write` не обходить branch protection чи організаційні обмеження.
Якщо правила вимагають PR, job завершиться помилкою; для такого репозиторію
потрібно окремо узгодити доставку через PR та його злиття.

Коміт бота змінює лише Deployment. Push через `GITHUB_TOKEN` не запускає
повторний workflow; додатково `k8s/` не входить у фільтр збірки.
ArgoCD сам читає Git і не потребує нового запуску Actions.
[Документація GitHub](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow).

Перед записом job перевіряє, що коміт збірки є предком поточного `main` і
build inputs відтоді не змінилися. Застаріла збірка пропускається з поясненням
у summary. Повторний запуск із тим самим тегом не створює зайвого коміту.
Якщо `main` зміниться між checkout і push, звичайний push відхилиться:
force-push не використовується. Повторно запустіть workflow на актуальному `main`.

Сценарій перевірки й перелік відсутніх доказів: [GITOPS-VERIFICATION.md](GITOPS-VERIFICATION.md).
