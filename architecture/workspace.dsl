workspace "Food Ordering Platform" "Архитектура платформы оформления заказов еды для проектной работы по микросервисной архитектуре." {

    !docs docs
    !adrs adr

    model {
        customer = person "Customer" "Клиент, который использует фронтальные приложения для просмотра меню, оформления заказа и оплаты."
        operator = person "Operator" "Сотрудник, который использует веб-терминал для контроля заказов и статусов приготовления."

        paymentGateway = softwareSystem "Payment Gateway" "Внешняя платёжная система для проведения оплаты." {
            tags "External System"
        }

        warehouseAccountingSystem = softwareSystem "Warehouse Accounting System" "Внешняя система складского учёта для получения данных об остатках ингредиентов." {
            tags "External System"
        }

        roboticConveyor = softwareSystem "Robotic Conveyor" "Роботизированная линия приготовления блюд." {
            tags "External System"
        }

        foodOrderingPlatform = softwareSystem "Food Ordering Platform" "Система для просмотра меню, оформления заказов, авторизации клиентов, проведения оплаты и управления роботизированным приготовлением блюд." {
            iosApp = container "iOS App" "Мобильное приложение для клиентов на iOS." "Swift"
            androidApp = container "Android App" "Мобильное приложение для клиентов на Android." "Kotlin"
            webApp = container "Web App" "Веб-приложение для клиентов." "TypeScript / React"
            webTerminal = container "Web Terminal" "Веб-терминал для операторов или сотрудников." "TypeScript / React"

            apiGateway = container "API Gateway" "Единая точка входа для всех фронтальных приложений. Выполняет маршрутизацию запросов и обращается к сервису авторизации для проверки токенов." "Nginx"

            orderService = container "Order Service" "Сервис управления корзиной и заказами. Оформляет заказы, бронирует ингредиенты, передаёт данные для оплаты и отправляет заказы на приготовление." "Java / Spring Boot" {
                orderApi = component "Order API" "REST API для работы с корзиной и заказами." "Spring MVC Controller"
                orderApplicationService = component "Order Application Service" "Оркестрирует сценарии создания заказа, подтверждения оплаты и изменения статусов заказа." "Spring Service"
                orderRepository = component "Order Repository" "Читает и записывает агрегаты заказа в базу данных Order Database." "Spring Data JDBC"
                ingredientReservationClient = component "Ingredient Reservation Client" "Синхронно запрашивает бронирование ингредиентов в Ingredient Service." "HTTP REST Client"
                paymentEventProducer = component "Payment Event Producer" "Публикует событие с запросом на оплату заказа." "Kafka Producer"
                cookingEventProducer = component "Cooking Event Producer" "Публикует событие с заданием на приготовление заказа." "Kafka Producer"
                paymentResultConsumer = component "Payment Result Consumer" "Получает результат оплаты и обновляет статус заказа." "Kafka Consumer"
                cookingResultConsumer = component "Cooking Result Consumer" "Получает результат приготовления и обновляет статус заказа." "Kafka Consumer"
            }

            orderDatabase = container "Order Database" "Хранит корзины, заказы, позиции заказов и статусы жизненного цикла заказа." "PostgreSQL" {
                tags "Database"
            }

            menuService = container "Menu Service" "Сервис управления меню. Предоставляет позиции меню и может исключать позиции, если недостаточно ингредиентов." "Java / Spring Boot"
            menuDatabase = container "Menu Database" "Хранит список меню, состав позиций меню и данные для отображения доступности." "PostgreSQL" {
                tags "Database"
            }

            ingredientService = container "Ingredient Service" "Сервис управления ингредиентами. Является мастер-сервисом по данным об ингредиентах и их доступности." "Java / Spring Boot"
            ingredientDatabase = container "Ingredient Database" "Хранит ингредиенты, остатки и данные о бронировании ингредиентов под заказы." "PostgreSQL" {
                tags "Database"
            }

            authService = container "Auth Service" "Сервис авторизации клиентов. Выполняет авторизацию, выдачу токенов и проверку актуальности токенов." "Java / Spring Boot"
            authDatabase = container "Auth Database" "Хранит пользователей и данные, необходимые для авторизации." "PostgreSQL" {
                tags "Database"
            }

            authTokenCache = container "Auth Token Cache" "Хранит актуальные авторизационные токены для быстрой проверки каждого запроса." "Redis" {
                tags "Database"
            }

            paymentService = container "Payment Service" "Сервис проведения оплаты. Проверяет данные оплаты по собственному хранилищу и инициирует платёж во внешнем платёжном шлюзе." "Java / Spring Boot"
            paymentDatabase = container "Payment Database" "Хранит идентификатор заказа, идентификатор клиента, сумму к оплате и статус оплаты для валидации платёжного запроса." "PostgreSQL" {
                tags "Database"
            }

            robotService = container "Robot Service" "Сервис управления приготовлением блюд. Передаёт задания на роботизированный конвейер и получает результат готовности блюда." "Java / Spring Boot"
            robotDatabase = container "Robot Database" "Хранит ключи и статусы отправленных запросов на приготовление блюд." "PostgreSQL" {
                tags "Database"
            }
        }

        customer -> iosApp "Использует для просмотра меню и оформления заказа"
        customer -> androidApp "Использует для просмотра меню и оформления заказа"
        customer -> webApp "Использует для просмотра меню и оформления заказа"
        operator -> webTerminal "Использует для контроля заказов"

        iosApp -> apiGateway "Выполняет запросы к API" "HTTPS / REST"
        androidApp -> apiGateway "Выполняет запросы к API" "HTTPS / REST"
        webApp -> apiGateway "Выполняет запросы к API" "HTTPS / REST"
        webTerminal -> apiGateway "Выполняет запросы к API" "HTTPS / REST"

        apiGateway -> authService "Авторизует пользователя и проверяет токены" "REST"
        apiGateway -> orderService "Управляет корзиной и оформляет заказ" "REST"
        apiGateway -> menuService "Получает меню" "REST"
        apiGateway -> paymentService "Проводит оплату заказа" "REST"

        authService -> authDatabase "Читает и записывает пользователей" "JDBC"
        authService -> authTokenCache "Сохраняет и проверяет актуальные авторизационные токены" "Redis protocol"

        orderService -> orderDatabase "Читает и записывает корзины и заказы" "JDBC"
        orderService -> ingredientService "Бронирует ингредиенты для заказа" "HTTP REST"

        menuService -> menuDatabase "Читает позиции меню, состав позиций и данные доступности" "JDBC"

        ingredientService -> ingredientDatabase "Читает и записывает ингредиенты, остатки и бронирования" "JDBC"
        ingredientService -> warehouseAccountingSystem "Получает данные складского учёта по ингредиентам" "HTTP REST"

        ingredientService -> menuService "Публикует данные об ингредиентах и их доступности" "Kafka" {
            tags "Asynchronous"
        }

        orderService -> paymentService "Публикует запрос на оплату заказа" "Kafka" {
            tags "Asynchronous"
        }

        paymentService -> paymentDatabase "Читает и записывает данные оплаты и статус платежа" "JDBC"
        paymentService -> paymentGateway "Проводит оплату" "HTTPS / REST"

        paymentService -> orderService "Публикует результат проведения оплаты" "Kafka" {
            tags "Asynchronous"
        }

        orderService -> robotService "Публикует задание на приготовление блюда" "Kafka" {
            tags "Asynchronous"
        }

        robotService -> robotDatabase "Читает и записывает ключи и статусы запросов на приготовление" "JDBC"

        robotService -> roboticConveyor "Передаёт задание на приготовление блюда" "Kafka" {
            tags "Asynchronous"
        }

        roboticConveyor -> robotService "Публикует результат готовности блюда" "Kafka" {
            tags "Asynchronous"
        }

        robotService -> orderService "Публикует результат готовности блюда" "Kafka" {
            tags "Asynchronous"
        }

        apiGateway -> orderApi "Передаёт запросы по корзине и заказам" "HTTPS / REST"
        orderApi -> orderApplicationService "Вызывает бизнес-сценарии заказов"
        orderApplicationService -> orderRepository "Сохраняет и загружает заказы"
        orderRepository -> orderDatabase "Читает и записывает данные заказов" "JDBC"
        orderApplicationService -> ingredientReservationClient "Запрашивает бронирование ингредиентов"
        ingredientReservationClient -> ingredientService "Бронирует ингредиенты" "HTTP REST"
        orderApplicationService -> paymentEventProducer "Передаёт команду на публикацию запроса оплаты"
        paymentEventProducer -> paymentService "Публикует OrderPaymentRequested" "Kafka" {
            tags "Asynchronous"
        }
        orderApplicationService -> cookingEventProducer "Передаёт команду на публикацию задания приготовления"
        cookingEventProducer -> robotService "Публикует OrderCookingRequested" "Kafka" {
            tags "Asynchronous"
        }
        paymentResultConsumer -> orderApplicationService "Передаёт результат оплаты"
        paymentService -> paymentResultConsumer "Публикует PaymentCompleted или PaymentFailed" "Kafka" {
            tags "Asynchronous"
        }
        cookingResultConsumer -> orderApplicationService "Передаёт результат приготовления"
        robotService -> cookingResultConsumer "Публикует CookingCompleted или CookingFailed" "Kafka" {
            tags "Asynchronous"
        }
    }

    views {
        systemContext foodOrderingPlatform "System_Context" "Контекстная диаграмма Food Ordering Platform." {
            include *
            autolayout lr
        }

        container foodOrderingPlatform "Container_Diagram" "Контейнерная диаграмма Food Ordering Platform." {
            include *
            autolayout lr
        }

        component orderService "Order_Service_Components" "Компонентная диаграмма Order Service." {
            include *
            include apiGateway
            include ingredientService
            include paymentService
            include robotService
            include orderDatabase
            autolayout lr
        }

        styles {
            element "Person" {
                shape Person
                background "#08427B"
                color "#FFFFFF"
            }

            element "Software System" {
                background "#1168BD"
                color "#FFFFFF"
            }

            element "External System" {
                background "#999999"
                color "#FFFFFF"
            }

            element "Container" {
                background "#438DD5"
                color "#FFFFFF"
            }

            element "Component" {
                background "#85BBF0"
                color "#000000"
            }

            element "Database" {
                shape Cylinder
                background "#438DD5"
                color "#FFFFFF"
            }

            relationship "Asynchronous" {
                dashed true
                color "#707070"
            }
        }
    }
}
