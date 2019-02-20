---
layout: post
title: astra - input id
tags: [astra]
---
Для создания карусели или переключения источников - можно использовать скрипт: 
<!-- more -->

Создаем скрипт /etc/astra/set-input.lua с содержимым:

```
control_api["set-input"] = function(server, client, request)
    local channel_data = channel_list_ID[request.id]
    local input_id = tonumber(request.input)
    channel_init_input(channel_data, input_id)
    for i,d in ipairs(channel_data.input) do
        if d.input and i ~= input_id then
            channel_kill_input(channel_data, i)
            log.debug("[" .. channel_data.config.name .. "] Destroy input #" .. i)
        end
    end
    control_api_response(server, client, { ["set-input"] = "ok" })
end
```


запустить астру: astra -c /etc/astra/astra.conf -p 8000 /etc/astra/set-input.lua

создать канал и прописать в нём все источники.

чтобы выбрать источник:

`curl -X POST -d '{"cmd":"set-input","id":"channel-id","input":X}'  http://admin:password@127.0.0.1:8000/`

channel-id - идентификатор канала. в адресе канала указывается. можно посмотреть в конфиге.
X - номер нужного входа. нумерация с единицы начинается


