# Збірка та публікація через GitHub Actions

Робочий репозиторій: [Charizmatik/dan-it-devops-diploma](https://github.com/Charizmatik/dan-it-devops-diploma).
Образ: [mikoladolia/dan-it-backend](https://hub.docker.com/r/mikoladolia/dan-it-backend).

## Підтверджений результат

[Запуск №2](https://github.com/Charizmatik/dan-it-devops-diploma/actions/runs/33680105744) від 02.09.2026 завершився успішно за 47 секунд.
Опубліковано `latest` і `sha-a3d755c05d915d6a3b24948512b28a3a6db47a80`.
Образ завантажено з Docker Hub і перевірено локально. [Скріни та протоколи](evidence/03-ci-publication.md).

## Як працює workflow

1. Після push у `main`, що змінює backend, Dockerfile, `.dockerignore` чи активний workflow, GitHub запускає збірку.
2. Збирається Linux/amd64 образ із контекстом `final-submission/`.
3. Тимчасовий контейнер перевіряється: HTTP 200 на `/`, правильна IP адреса, HTTP 404 на невідомому шляху, UID 10001.
4. Після успішної перевірки виконується вхід у Docker Hub через GitHub Secrets.
5. Образ публікується з тегами `latest` і `sha-<повний SHA коміту>`. Digest виводиться в підсумку запуску.

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
Токен має строк дії 30 днів за обраним користувачем налаштуванням; після завершення строку потрібно створити новий і оновити GitHub Secret.

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
- Якщо змінюється Docker Hub namespace або репозиторій образів, змініть `IMAGE_NAME` і налаштуйте Secrets відповідного акаунта.
- Перевірте назву основної гілки у тригерах та умовах публікації.

Публікація образу сама по собі не оновлює Kubernetes Deployment. Зв'язок із маніфестами та ArgoCD буде реалізований на наступних етапах.
