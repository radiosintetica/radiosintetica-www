---
layout: post
title: Astra + Grafana
tags: [astra]
---

Небольшой мануал:

<!-- more -->

![](/content/images/2018/03/post-2225-0-59081600-1487532724-1.png)
Небольшой мануал:

* Устанавливаем Influxdb (https://portal.influxdata.com/downloads)
 * После установки редактируем конфигурацию: в файле  "/etc/influxdb/influxdb.conf" раскоментируем поля в секции Admin, что бы включить веб-интерфейс influxdb, и делаем "service influxdb restart".
 * Идем на http://айпинашегосервера:8083  - должна открыться админка influxdb, далее нажимаем CREATE DATABASE и называем её "Astra". Тут закончили.
_____________

*  Качаем и ставим Grafana - (не ставим из apt-а - там старая версия. Нам нужна версия не ниже 4.2. Потому идем на http://grafana.org/builds/ и выбираем нужную версию там.) 
 * Делаем dpkg -i grafanа-*.deb
 *  Идем на http://айпинашегосервера:3000 - должен заработать веб-интерфейс. Логин и пароль по умолчанию -  admin/admin
 * Подключаем influxdb: Жмем кнопку Data Sources -> Add Data Source - откроется меню настроек db. пишем туда:
<pre> Name: Astra
 Type: InfluxDB
 URL: http://айпинашегосервера:8086 (или localhost)
 Database: Astra
</pre>
________
* Если в админ-панели influxdb не указывали логин и пароль, то больше ничего никуда не пишем, жмем кнопку Add. Должна появится зеленая табличка говорящая все ОК! 
* Качаем [дашборд](https://radiosintetica.ru/content/images/2016/04/Dashboard_Astra_Autogen.json) или 
[этот](https://radiosintetica.ru/content/images/2016/04/Astra_template.json) и импортируем его: Жмем кнопку Dashboards -> Import
_______
* Создаем папку "/etc/astra/mod", в нее кладем  скрипт [event.lua](https://radiosintetica.ru/content/images/2016/04/event.lua)
_______ 
* В Веб - интерфейсе Астре прописываем адрес к influxdb: (http://айпинашегосервера:8086/write?db=Astra#interval=60&total=1)
* Для отображения названий каналов нужно названия прописать в поле id без пробелов - ("id": "Матч_ТВ",)
* Перезапускаем Астру.



![](/content/images/2018/03/post-2225-0-35628500-1487532728.png)

Все сделано силами сообщества пользователей Astra.
Благодарности: @Yumaxx, @VladZaitov. Если кого забыл - напишите. 
Наш телеграмм - канал: [ТЫЦ!](https://t.me/cesbo_ru)
