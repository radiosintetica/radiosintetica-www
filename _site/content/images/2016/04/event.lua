function event_request_send(info)
    local content = {}

    for _,v in ipairs(info) do
        if v.channel_id then
            table.insert(content, "stream" ..
                ",host=" .. hostname ..
                ",id=" .. v.channel_id ..
                ",input=" .. v.input_id ..
                " onair=" .. tostring(v.onair) ..
                ",bitrate=" .. v.bitrate ..
                ",scrambled=" .. tostring(v.scrambled) ..
                ",cc=" .. v.cc_error ..
                ",pes=" .. v.pes_error ..
                " " .. v.timestamp .. "000000000")
        elseif v.dvb_id then
            table.insert(content, "dvb" ..
                ",host=" .. hostname ..
                ",id=" .. v.dvb_id ..
                " lock=" .. bit32.rshift(v.status, 4) ..
                ",signal=" .. v.signal ..
                ",snr=" .. v.snr ..
                ",ber=" .. v.ber ..
                ",unc=" .. v.unc ..
                " " .. v.timestamp .. "000000000")
        end
    end

    if #content == 0 then
        return nil
    end

    content = table.concat(content, "\n")

    local event_config = {
        host = _event_request.host,
        port = _event_request.port,
        path = _event_request.path,
        method = "POST",
        headers = {
            "User-Agent: Astra " .. astra.version,
            "Host: " .. _event_request.host .. ":" .. _event_request.port,
            "Content-Type: application/x-www-form-urlencoded",
            "Content-Length: " .. #content,
            "Connection: close"
        },
        callback = function(self, response)
            if response.code ~= 200 then
                log.error(("[stream.lua] event_request_send() failed %d:%s")
                          :format(response.code, response.message))
            end
        end,
        content = content,
    }

    http_request(event_config)
end