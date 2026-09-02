# Підтвердження виконання розділу 1

Дата перевірки: 02.09.2026. Час у машинних протоколах — UTC.

## GitHub Actions

- Репозиторій: [Charizmatik/dan-it-devops-diploma](https://github.com/Charizmatik/dan-it-devops-diploma).
- Workflow: `Build and publish backend`.
- [Успішний запуск №2](https://github.com/Charizmatik/dan-it-devops-diploma/actions/runs/33680105744).
- Коміт: `a3d755c05d915d6a3b24948512b28a3a6db47a80`.
- Результат: `success`; тривалість — 47 секунд.
- Пройдено збірку, перевірку HTTP 200, IP контейнера, HTTP 404, UID 10001, вхід у Docker Hub та публікацію.
- [Машинний протокол GitHub API](03-github-actions.json).

Перший запуск виявив скидання з'єднання під час старту сервера. У workflow додано повторні спроби для тимчасових помилок з'єднання; другий запуск пройшов усі перевірки.

![Успішний запуск GitHub Actions](03-github-actions-success.png)

## Docker Hub

[Репозиторій образів і теги](https://hub.docker.com/r/mikoladolia/dan-it-backend/tags).

Опубліковано:

- `mikoladolia/dan-it-backend:latest`.
- `mikoladolia/dan-it-backend:sha-a3d755c05d915d6a3b24948512b28a3a6db47a80`.

Digest, отриманий під час `docker pull`:

```text
sha256:d6179b396e5dc5849527fb556606f53651e31222a50d541862141baeda32aa2f
```

Це digest індексу образу; у таблиці Docker Hub наведено digest окремого Linux/amd64 образу.

![Опубліковані теги Docker Hub](04-docker-hub-tags.png)

## Перевірка образу після публікації

Образ із тегом коміту завантажено з Docker Hub і запущено локально у тимчасовому контейнері.
Перевірено відповідність OCI-мітки ревізії коміту, Linux/amd64, UID 10001 та відповідь HTTP 200:

```json
{"status": "ok", "ip": "172.17.0.2"}
```

IP у відповіді збігся з адресою контейнера за `docker inspect`.
[Машинний протокол перевірки опублікованого образу](04-published-image.json).
Після перевірки тимчасовий контейнер зупинено й видалено; образ залишено локально.

Ці матеріали підтверджують розділ 1. EKS, DNS та ArgoCD ще не розгорнуто.
