---
layout: post
title: cesbo astra - правим css
tags: [astra]
---
Для чего? а вот к примеру: 
<!-- more -->

Вывести кучу каналов на тв:
![](/content/images/2017/11/--------------2017-11-08---20.42.08.png)

Создаем файл /etc/astra/mod_theme/theme.lua :
<pre><code>astra_storage["/tv-c.css"] = [[
.tv-c .card { margin: 1px; }
.tv-c .card .card-image { display: none; }
.tv-c .card .card-status { display: none; }
.tv-c .card div { background-color: inherit; }
.tv-c .card.card-true-3, .dark-c .card.card-false-0 { background-color: #434857; }
.tv-c .card.card-true-2 { background-color: #66bb6a; }
.tv-c .card.card-true-0, .dark-c .card.card-true-1  { background-color: #ef5350; }
#.main-menu.fixed { position: fixed; top: 0; left: 0; width: 0%; }
.main-menu { z-index: 0; }
.button.icon.small { height: 0px; width: 0px; background-size: 20px; }
.version { font-size: 0; }
.card-stack[data-header]:before { font-size: 0px; }
.card .card-name {font-weight: 600;}
.main-menu.fixed+.main-content { padding-top: 2px;}
]]

astra_storage["/mod.js"] = astra_storage["/mod.js"] .. [[
(function() {
    app.themes.push({ value: "dark tv-c", label: "For TV" });

    $.head.addChild($.element("link")
        .addAttr("rel", "stylesheet")
        .addAttr("type", "text/css")
        .addAttr("href", "/tv-c.css")
        .addAttr("media", "all"));
})();
]]
</code></pre> 
Создаем новый процесс Астры, и запускаем:  /usr/bin/astra  /etc/astra/mod_theme/theme.lua -p 9000 -c /etc/monitor.conf .  
Добавляем туда через сервера все остальные процессы астр, в настройках меняем тему  и выводим на смарт тв) 
(меню позади всех элементов - неудобно но попасть можно)))

![](/content/images/2017/11/--------------2017-11-17---15.09.08.png)