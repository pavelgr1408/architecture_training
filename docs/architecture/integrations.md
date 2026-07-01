# Интеграции

## Типы взаимодействия

В архитектуре используются два типа интеграций:

| Тип | Где применяется | Причина |
|---|---|---|
| HTTPS / REST | Клиентские запросы, API Gateway, бронирование ингредиентов, платёжный шлюз | Нужен быстрый ответ в рамках пользовательского сценария. |
| Kafka | Оплата, приготовление, обновление статусов, обновление доступности меню | Нужна слабая связанность и асинхронная обработка. |

## Синхронные взаимодействия

Синхронные REST-вызовы используются там, где вызывающая сторона должна получить результат сразу:

- клиентские приложения → API Gateway;
- API Gateway → Auth Service;
- API Gateway → Menu Service;
- API Gateway → Order Service;
- API Gateway → Payment Service;
- Order Service → Ingredient Service;
- Payment Service → Payment Gateway.

## Асинхронные события

Асинхронные события используются там, где бизнес-процесс может продолжаться независимо от исходного HTTP-запроса:

| Событие | Producer | Consumer | Назначение |
|---|---|---|---|
| IngredientAvailabilityChanged | Ingredient Service | Menu Service | Обновление доступности блюд. |
| OrderPaymentRequested | Order Service | Payment Service | Запрос на проведение оплаты. |
| PaymentCompleted | Payment Service | Order Service | Успешная оплата. |
| PaymentFailed | Payment Service | Order Service | Ошибка оплаты. |
| OrderCookingRequested | Order Service | Robot Service | Запрос на приготовление. |
| CookingCompleted | Robot Service | Order Service | Заказ приготовлен. |
| CookingFailed | Robot Service | Order Service | Ошибка приготовления. |
