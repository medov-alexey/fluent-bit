Russian:

В этом примере при выполнении скрипта ./demonstration.sh произойдет:

1) автоматический подъем Graylog инстанса (graylog, mongo, elasticsearch)
2) автоматическая настройка в Graylog TCP GELF Input
3) автоматическое поднятие контейнера с настроенным в Fluent-Bit input "forward", и output "gelf" который отправляет логи в Graylog


