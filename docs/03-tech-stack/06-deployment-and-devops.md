---
project: "vellum"
phase: "03-tech-stack"
artifact: "06-deployment-and-devops"
title: "CI/CD, окружения и регламент развертывания (DevOps)"
status: "approved"
created_at: "2026-09-29"
tags:
  - airam
  - tech-stack
  - devops
  - cicd
  - flutter
  - fastlane
  - testflight
---

# 🚀 CI/CD, окружения и регламент развертывания (DevOps): Vellum

> **Назначение:**  
> Документ регламентирует порядок локальной сборки Flutter-проекта, кодогенерации Isar, спецификацию GitHub Actions CI/CD и автоматическую доставку сборок в Apple TestFlight через Fastlane.

---

## 1. Локальное окружение разработки (Local Dev Runbook)

### Системные требования:
- **Flutter SDK:** `>= 3.24.x (Channel stable)` + Dart `>= 3.5.x`
- **Xcode:** `>= 15.4` (с установленными iOS 17/18 Simulator)
- **CocoaPods:** `>= 1.15.x`
- **Fastlane:** `>= 2.220.x` (Ruby `>= 3.1`)

### Пошаговый запуск с нуля (за 1 минуту):
```bash
# 1. Клонирование репозитория
git clone https://github.com/alexche/vellum-app.git && cd vellum-app

# 2. Установка Flutter-зависимостей и CocoaPods
flutter pub get
cd ios && pod install && cd ..

# 3. Генерация Isar-моделей базы данных
dart run build_runner build --delete-conflicting-outputs

# 4. Запуск всех Unit и Widget тестов
flutter test

# 5. Запуск приложения на симуляторе iPhone 15 Pro
flutter run -d "iPhone 15 Pro"
```

---

## 2. Матрица сборок и сред (Environments & Flavors)

| Среда (Flavor) | Bundle ID | Назначение | База стихов | Секреты |
| :--- | :--- | :--- | :--- | :--- |
| **Development** | `app.vellum.dev` | Локальная разработка и симуляторы | 20 тестовых стихов | Локальный sandbox |
| **Beta (TestFlight)** | `app.vellum.beta` | Внутреннее тестирование (50 тестеров) | 365 стихов Public Domain | Fastlane Match / TestFlight |
| **Production** | `app.vellum` | Публичный релиз в App Store | Полный кураторский каталог | App Store Connect API Key |

---

## 3. Спецификация GitHub Actions CI Pipeline (`.github/workflows/ci.yml`)

Каждый Pull Request и коммит в ветку `main` проходит 4 обязательных гейта:

```yaml
name: Vellum CI Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  validate:
    runs-on: macos-14
    steps:
      - uses: actions/checkout@v4

      - name: Setup Java 17
        uses: actions/setup-java@v4
        with:
          distribution: 'zulu'
          java-version: '17'

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.24.3'
          channel: 'stable'
          cache: true

      - name: Install Dependencies
        run: flutter pub get

      - name: Verify Code Generation
        run: |
          dart run build_runner build --delete-conflicting-outputs
          git diff --exit-code || (echo "ОШИБКА: Isar модели не сгенерированы! Запустите build_runner." && exit 1)

      - name: Static Analysis (Linter)
        run: flutter analyze --fatal-infos

      - name: Run Unit & Algorithm Tests
        run: flutter test --coverage test/domain/cloze_algorithm_test.dart test/data/poem_repository_test.dart
```

---

## 4. Непрерывная доставка в TestFlight (`Fastfile`)

Автоматический релиз ночной сборки (Nightly Build) запускается через Fastlane:

```ruby
default_platform(:ios)

platform :ios do
  desc "Сборка и публикация в Apple TestFlight"
  lane :beta do
    setup_ci if ENV['CI']
    
    # 1. Синхронизация сертификатов через Match
    match(type: "appstore", readonly: is_ci)
    
    # 2. Инкремент номера сборки
    increment_build_number(xcodeproj: "ios/Runner.xcodeproj")
    
    # 3. Сборка подписанного IPA
    build_app(
      workspace: "ios/Runner.xcworkspace",
      scheme: "Runner",
      export_method: "app-store"
    )
    
    # 4. Загрузка в TestFlight
    upload_to_testflight(
      skip_waiting_for_build_processing: true,
      changelog: "Обновления алгоритма заучивания Cloze Deletion и новые темы звука."
    )
  end
end
```
