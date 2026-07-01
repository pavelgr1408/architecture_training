# Component Diagram — Order Service

## Назначение диаграммы

Component Diagram показывает внутреннюю структуру Order Service. Этот уровень нужен, чтобы объяснить, как внутри одного контейнера реализуется бизнес-сценарий оформления заказа.

## Компоненты

| Компонент | Ответственность |
|---|---|
| Order API | REST API для корзины и заказов. |
| Order Application Service | Оркестрация сценариев создания заказа и изменения статусов. |
| Order Repository | Доступ к данным заказов. |
| Ingredient Reservation Client | Синхронное бронирование ингредиентов. |
| Payment Event Producer | Публикация события запроса оплаты. |
| Cooking Event Producer | Публикация события задания на приготовление. |
| Payment Result Consumer | Получение результата оплаты. |
| Cooking Result Consumer | Получение результата приготовления. |

## Основной сценарий

1. Клиент отправляет запрос через API Gateway.
2. API Gateway передаёт запрос в Order API.
3. Order Application Service создаёт заказ.
4. Ingredient Reservation Client бронирует ингредиенты в Ingredient Service.
5. Order Repository сохраняет заказ в Order Database.
6. Payment Event Producer публикует событие `OrderPaymentRequested`.
7. После успешной оплаты Cooking Event Producer публикует событие `OrderCookingRequested`.
8. Consumer'ы получают результаты оплаты и приготовления, после чего Order Application Service обновляет статус заказа.

## Интерактивная диаграмма

<iframe class="structurizr-frame" src="../../structurizr/" loading="lazy"></iframe>

[Открыть диаграммы в полноэкранном режиме](../../structurizr/)
