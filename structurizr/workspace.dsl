workspace {
    name "BeamIt Messenger"

    model {
        user = person "Пользователь" {
            description "Использует приложение для общения и управления чатами."
        }

        beamit = softwareSystem "BeamIt" {

            # Контейнер для фронтенда
            webApp = container "Web Application" {
                description "Интерфейс для взаимодействия пользователей с мессенджером."
                technology "HTML/CSS"

                registrationForm = component "Форма регистрации/авторизации" {
                    description "Позволяет пользователям зарегистрироваться и войти в систему."

                }

                messengerForm = component "Форма мессенджера" {
                    description "Отображает сообщения и позволяет их отправлять."
                }

                chatForm = component "Форма чатов" {
                    description "Управление групповыми и PtP чатами."
                }

                user -> registrationForm "Использует"

                user -> messengerForm "Использует"

                user -> chatForm "Использует"
            }

            //user -> webApp "Взаимодействует"

            # База данных
            database = container "PostgreSQL Database" {
                description "Хранит информацию о пользователях, чатах и сообщениях."
                technology "PostgreSQL"
            }

            # Микросервис аутентификации
            authService = container "Auth Service" {
                description "Управляет входом пользователей и токенами безопасности."
                technology "Flask/Python"

                authService -> database "Сохраняет и извлекает данные пользователей и их аутентификацию." "SQL"
            }

            # Микросервис мессенджера
            messengerService = container "Messenger Service" {
                description "Обрабатывает отправку и получение сообщений."
                technology "Flask/Python"

                encryptService = component "Encrypt" {
                    description "Отвечает за шифрование/расшифровку сообщений."
                    technology "Flask/Python"
                }

                messengerModel = component "Model" {
                    description "Содержит ORM-модели для работы с базой данных."
                    technology "Flask/Python"

                    -> database "Сохраняет сообщения." "SQL"
                }

                messageHandlersService = component "messageHandlers" {
                    description "Отвечает за Обработку собщений."
                    technology "Flask/Python"

                    -> encryptService "Шифрует сообщение"
                    -> messengerModel "Отправляет сообщение на запиь в базу данных"
                }

                messengerController = component "Controller" {
                    description "Отвечает за обработку HTTP-запросов и передачу их на уровень бизнес-логики."
                    technology "Flask/Python"

                    -> messageHandlersService "отправляет сообщение на обработку"
                }
            }

            # Микросервис чатов
            chatService = container "Chat Service" {
                description "Управляет чатом и его участниками."
                technology "Flask/Python"

                chatService -> database "Управляет данными чатов и участниками." "SQL"
            }

            # API Gateway
            apiGateway = container "API Gateway" {
                description "Объединяет клиентские запросы и перенаправляет их к сервисам."
                technology "Flask/Python"

                apiGateway -> messengerController "Маршрутизирует запросы к мессенджеру" "HTTPs"
                apiGateway -> authService "Авторизируется/получает токен" "HTTPs"
                apiGateway -> chatService "Маршрутизирует запросы для чатов" "HTTPs"
            }

            registrationForm -> apiGateway "Отправляет данные" "HTTPs"
            messengerForm -> apiGateway "Отправляет данные" "HTTPs"
            chatForm -> apiGateway "Отправляет данные" "HTTPs"

            webApp -> apiGateway "Перенаправляет запросы API" "HTTPs"
        }
    }

    views {
        theme default

        systemContext beamit {
            description "Контекст Мессенджера BeamIt."
            include *
            autolayout lr
        }

        container beamit {
            description "Контекст Мессенджера BeamIt."
            include *
            autolayout lr
        }

        component webApp {
            include *
            autolayout lr
        }

        component messengerService {
            include *
            autolayout lr
        }

        dynamic webApp {
            description "Последовательность авторизации пользователя"
            autolayout lr

            user -> messengerForm "Написал сообщение в чат другому пользователю и нажал кнопку отправить"
            messengerForm -> apiGateway "Пересылает сообщение по HTTPs"

            apiGateway -> authService "Запрос аутентификации"
            authService -> database "Проверка данных пользователя"
            database -> authService "Возврат результата"
            authService -> apiGateway "Ответ с токеном"

            apiGateway -> messengerController "Передача передаёт сообщение в сервис обработки сообщений"
            messengerController -> messageHandlersService "Отдаёт сообщение обработчику"
            messageHandlersService -> encryptService "Отправляет сообщение в исходном виде"
            encryptService -> messageHandlersService "Отправляет зашифрованое сообщение"
            messageHandlersService -> messengerModel "Отправляет сообщение для записи в базу данных"
            messengerModel -> database "Записывает сообщение в базу даных"
        }
    }


}