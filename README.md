# ImageFeed

iOS-приложение для просмотра и добавления фотографий в избранное на основе Unsplash API.

## Описание

ImageFeed — это аналог ленты Instagram, использующий публичный API Unsplash. После авторизации через OAuth2 пользователь видит бесконечную ленту фотографий, может лайкать снимки, просматривать их в полноэкранном режиме и делиться ими. Профиль пользователя отображает имя, логин, аватар и описание.

## Функциональность

- OAuth2-авторизация через Unsplash
- Бесконечная лента фотографий с пагинацией
- Лайк / снятие лайка с синхронизацией через API
- Просмотр фото в полноэкранном режиме с поддержкой зума
- Поделиться фотографией через стандартный Share Sheet
- Профиль пользователя: имя, логин (@username), биография, аватар
- Индикаторы загрузки (ProgressHUD)
- Безопасное хранение токена в Keychain

## Технологии

- **Язык:** Swift
- **UI:** UIKit (Storyboard + программная вёрстка)
- **Архитектура:** MVP (Model-View-Presenter)
- **Сеть:** URLSession (Unsplash API)
- **Авторизация:** OAuth2
- **Хранение токена:** Keychain (SwiftKeychainWrapper)
- **Загрузка изображений:** Kingfisher
- **Минимальная версия iOS:** 13.0

## Структура проекта

```
ImageFeed/
├── Application/
│   ├── AppDelegate.swift
│   └── SceneDelegate.swift
├── Presentation/
│   ├── Splash/
│   │   └── SplashViewController.swift
│   ├── Auth/
│   │   ├── AuthViewController.swift
│   │   ├── WebViewViewController.swift
│   │   └── WebViewPresenter.swift
│   ├── ImagesList/
│   │   ├── ImagesListViewController.swift
│   │   └── ImagesListCell.swift
│   ├── SingleImage/
│   │   └── SingleImageViewController.swift
│   └── Profile/
│       └── ProfileViewController.swift
├── Services/
│   ├── OAuth2Service.swift
│   ├── OAuth2TokenStorage.swift
│   ├── ImageListService.swift
│   ├── ProfileService.swift
│   └── ProfileImageService.swift
└── Models/
```

## Установка зависимостей

Проект использует **CocoaPods**. Перед запуском выполните:

```bash
pod install
```

Затем откройте `ImageFeed.xcworkspace`.

## Зависимости

- **Kingfisher** — загрузка и кэширование изображений
- **ProgressHUD** — индикаторы загрузки
- **SwiftKeychainWrapper** — безопасное хранение OAuth-токена в Keychain

## Запуск

1. Клонируйте репозиторий
2. Выполните `pod install` в директории проекта
3. Откройте `ImageFeed.xcworkspace` в Xcode
4. Укажите ваш `Access Key` от Unsplash в файле конфигурации
5. Выберите симулятор или устройство с iOS 13.0+
6. Нажмите **Run** (⌘R)

## Получение Unsplash API Key

1. Зарегистрируйтесь на [unsplash.com/developers](https://unsplash.com/developers)
2. Создайте новое приложение
3. Скопируйте **Access Key** и добавьте его в проект

## Требования

- Xcode 14+
- iOS 13.0+
- CocoaPods
