---
layout: post
title: astra - input id
tags: [astra]
---
Для создания карусели или переключения источников - можно использовать скрипт: 
<!-- more -->

[ссыка](https://s3.radiosintetica.ru/all/set-input.lua)

Сохраняем в /etc/astra/set-input.lua
запустить астру: astra -c /etc/astra/astra.conf -p 8000 /etc/astra/set-input.lua

создать канал и прописать в нём все источники.

чтобы выбрать источник:

`curl -X POST -d '{"cmd":"set-input","id":"channel-id","input":X}'  http://admin:password@127.0.0.1:8000/`

channel-id - идентификатор канала. в адресе канала указывается. можно посмотреть в конфиге.
X - номер нужного входа. нумерация с единицы начинается


