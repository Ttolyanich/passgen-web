# PassGen Web — Автономный генератор паролей

[![Build and Publish Docker Image](https://github.com/Ttolyanich/passgen-web/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/Ttolyanich/passgen-web/actions/workflows/docker-publish.yml)
[![Docker Image](https://img.shields.io/badge/docker-ghcr.io-blue?logo=docker)](https://github.com/Ttolyanich/passgen-web/pkgs/container/passgen-web)
[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Полная автономная реплика современного генератора паролей (на базе движка passgen.co).  
Приложение работает **на 100% на клиенте** (в браузере пользователя с использованием стандартного криптографического API `crypto.getRandomValues`). Никакие пароли или введённые данные никуда не передаются.

---

## ✨ Возможности

- 🔑 **Генератор паролей (Password)**:
  - Настройка длины ползунком, кнопками `+`/`-` или прямым вводом.
  - Наборы символов: `a-z`, `A-Z`, `0-9`, специальные знаки (`!@#$%^&*` и др.).
  - Исключение визуально похожих символов (`1`, `l`, `I`, `0`, `O`).
  - Мгновенный расчёт энтропии (в битах) и визуальный индикатор надёжности.
  - Быстрое копирование в буфер и генерация QR-кода для мобильных устройств.
- 📝 **Парольные фразы (Passphrase)**:
  - Мнемонические пароли из реальных слов (Diceware-метод).
  - Поддержка русских и английских словарей.
  - Настройка разделителей (дефис, пробел, точка и т.д.) и регистра.
- 👤 **Генератор никнеймов и логинов (Username)**:
  - Тематические наборы: *gamer*, *fantasy*, *space*, *cute*, *aesthetic*, *funny*, *mixed*.
- 🔢 **Генератор PIN-кодов (PIN)**:
  - Быстрый выбор 4 или 6 цифр, либо произвольная длина с проверкой на тривиальные комбинации.
- 🛡️ **Анализатор и проверка паролей (Check)**:
  - Локальная оценка стойкости пароля через алгоритм `zxcvbn`.
  - Проверка по локальной базе хэшей утечек (`leaked.bin`) и опционально через безопасный k-anonymity API HaveIBeenPwned.
- 📋 **Массовая генерация (Bulk)**:
  - Генерация списков паролей пачками (10, 50, 100+) с возможностью экспорта или копирования.
- 📶 **Wi-Fi QR-код**:
  - Создание карточки с QR-кодом для быстрого подключения гостей к Wi-Fi.
- 🌓 **Тёмная и светлая тема**:
  - Автоматическое определение системной темы устройства + переключатель в шапке.
- 🌐 **Двуязычный интерфейс (RU / EN)**:
  - Полноценная русская и английская локализация.
  - Автоматическое перенаправление на русскую версию для русскоязычных браузеров.
- 🔒 **Приватность и чистота**:
  - Полностью удалены Google Analytics, Google Tag Manager и телеметрия Cloudflare.
  - Все шрифты (*Titillium Web*, *Inconsolata*) и ассеты хранятся локально — никаких внешних CDN.

---

## 🚀 Быстрый запуск

### Вариант 1. Запуск готового контейнера из GitHub Packages (GHCR)

Без необходимости собирать образ локально:

```bash
docker run -d \
  --name passgen \
  -p 8080:80 \
  --restart unless-stopped \
  ghcr.io/ttolyanich/passgen-web:latest
```

Сервис сразу доступен в браузере: `http://localhost:8080`.

---

### Вариант 2. Запуск через Docker Compose

Клонируйте репозиторий:
```bash
git clone https://github.com/Ttolyanich/passgen-web.git
cd passgen-web
```

Запустите контейнер:
```bash
docker compose up -d
```

---

## 🌐 Развертывание на боевом сервере (Nginx Reverse Proxy)

Если генератор запускается в Docker на сервере, а перед ним стоит системный Nginx (например, для домена `passgen.your-domain.com`):

```nginx
server {
    listen 80;
    server_name passgen.your-domain.com;
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl http2;
    server_name passgen.your-domain.com;

    # SSL сертификаты (Certbot / Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/passgen.your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/passgen.your-domain.com/privkey.pem;

    location / {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

## 📁 Статическое развертывание (без Docker)

Так как проект полностью статический, его можно отдать любым веб-сервером напрямую из папки:

1. Скопируйте содержимое репозитория в `/var/www/passgen-web`.
2. Используйте готовый конфиг [nginx.conf](nginx.conf) в настройках виртуального хоста.
3. Перезагрузите Nginx: `nginx -s reload`.

---

## 🏗 Архитектура репозитория

```text
passgen-web/
├── .github/workflows/ # Автоматическая сборка Docker-образа в GHCR
├── assets/
│   ├── css/           # Стили (светлая/тёмная темы, адаптивная вёрстка)
│   ├── fonts/         # Автономные шрифты Titillium Web и Inconsolata
│   ├── js/            # Модули генерации, zxcvbn, QR-генератор
│   ├── i18n/          # Словари локализации (ru.js, en.js)
│   └── icons.svg      # SVG спрайты иконок
├── words/             # Словари фраз, темы никнеймов и база хэшей утечек
├── ru/                # Страницы русской локализации
├── passphrase/        # Генератор парольных фраз
├── username/          # Генератор логинов
├── pin/               # Генератор PIN-кодов
├── check/             # Модуль проверки пароля
├── bulk/              # Массовый генератор
├── wifi/              # Генератор Wi-Fi QR
├── index.html         # Главная страница
├── nginx.conf         # Готовая конфигурация Nginx (gzip, кэш, security headers)
├── Dockerfile         # Минималистичный образ на Alpine
└── docker-compose.yml # Compose-манифест
```

---

## 📄 Лицензия

MIT License.
