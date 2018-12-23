---
layout: post
title: Мониторинг astra через zabbix
tags: [astra,zabbix]
---
Чуть больше года назад мной было принято волевое усилие: все, сношу в родной конторе все и ставлю что нить ~~понятное, удобное и вкусное~~ -к примеру Zabbix.
<!-- more -->
Все отлично: но что делать с cesbo astra? (для тех, кто не в курсе: Это отличное решение за очень небольшие деньги для вещания IPTV-KTV и прочее)

Требования:

* Python 3.5.2
* Astra не ниже 5.62-test от 12.11.2016

Итак - прикручиваем: определяемся где будет стоять коллектор. жрет он мало, потому поставим его на сервер с астрой. 

<pre><code>#Ставим python3 и monit:
apt install python3-pip
pip3 install aiohttp
apt install monit
#Смотрим что поставилось:
python3 --version
#Python 3.5.2 - Отлично!
mkdir /astra_mon
cd /astra_mon
</code></pre> 
Сам коллектор: astra_mon
<pre><code>#! /usr/bin/env python3

from app import app
from aiohttp import web

web.run_app(app, port = 8080)
</code></pre>
И app.py:

<pre><code>from aiohttp import web
import asyncio
from time import time



async def receiveDataFromStreamAstra(request):
  json = await request.json()
  json = json.pop()
  if "channel_id" not in json:
    raise RuntimeError("Ошибка!")
  request.app.channels[json["channel_id"]] = json
  return web.Response(text = "ok")



async def getChannelInfo(request):
  channelId = request.match_info['channelId']
  if channelId not in request.app.channels:
    return web.Response(text = "Not found channel with id = {}".format(channelId), status = 404)
  return web.json_response(request.app.channels[channelId])



async def getChannelsInfo(request):
  return web.json_response(request.app.channels)



app = web.Application(loop = asyncio.get_event_loop())
app.router.add_post('/astra/', receiveDataFromStreamAstra)
app.router.add_get('/channel/{channelId}', getChannelInfo)
app.router.add_get('/channels/', getChannelsInfo)
app.channels = {}



# стирает данные если мониторинг не присылает их больше 5 минут
async def removeExpiredData(app):
  try:
    otmetka = time() - 60 * 5
    for channel, data in app.channels.items():
      timestamp = int(data["timestamp"])
      if timestamp < otmetka:
        del(app.channels[channel])
  except Exception as e:
    pass
  finally:
    await asyncio.sleep(5)
    app.loop.create_task(removeExpiredData(app))


app.loop.create_task(removeExpiredData(app))

if __name__ == "__main__":
  web.run_app(app, port = 8080)</code></pre>

Создав файлы - даем права astra_mon на запуск:<pre><code>chmod +x astra_mon</code></pre>

ну и запускаем: ./astra_mon

<pre><code>
======== Running on http://0.0.0.0:8080 ========
(Press CTRL+C to quit)
</code></pre>
О! оно работает! 
Круто! 

делаем юзера astramon от имени которого наше поделие будет работать:
adduser astramon

Создаем файл /etc/monit/conf.d/astra_mon.conf :
<pre><code>check process astra_mon with pidfile /var/run/astra_mon.pid
  start "/sbin/start-stop-daemon -Sb -N -10 -g astramon -c astramon -mp /var/run/astra_mon.pid -x /scripts/astra_mon/astra_mon"
  stop "/sbin/start-stop-daemon -K -p /var/run/astra_mon.pid"</code></pre>

Готово! Идем в Астру: 

Проставим ID у каналов:

![](/content/images/2017/10/--------------2017-10-09---19.44.28.png)

И, так как мониторинг у нас на этой же машине - в строке мониторинга пишем:
http://127.0.0.1:8080/astra/#total
![](/content/images/2017/10/--------------2017-10-09---19.44.38-1.png)
После чего астру рестартуем. 

Попробуем сходить - глянуть на то, что нам астра отправила: Для этого, в адресной строке любимого браузера пишем:<pre><code>http://айпи нашего сервера:8080/channel/ид канала
</code></pre>
Мы должны получить что то типа:
<pre><code>{"input_id": 1, "channel_id": "829nby", "pes_error": 0, "bitrate": 3497, "count": 30, "scrambled": false, "cc_error": 0, "timestamp": 1507560489, "onair": true}</code></pre>

О! канал работает, вход 1, битрейт есть и вообще он onair. 

Идем на сервер zabbix и создаем в каталоге 
/usr/lib/zabbix/externalscripts/ файл astra:


<pre><code>#!/usr/bin/env python3
import argparse
from requests import get

parser = argparse.ArgumentParser(description = "Мониторинг Astra")
parser.add_argument('channel', help = 'channel name')
parser.add_argument('param', help = 'Параметр')
args = parser.parse_args()

try:
  r = get("http://айпи сервера 
 с астрой:8080/channel/{}".format(args.channel), timeout = 15)
  json = r.json()
  if args.param not in json:
    raise RuntimeError("Нет такого параметра")
  print(json[args.param])
except:
  print("nodata")</code></pre>

Ну и дав ему права <pre><code>chmod +x /usr/lib/zabbix/externalscripts/astra</code></pre> - пробуем:

<pre><code> /usr/lib/zabbix/externalscripts/astra 829nby bitrate
3497</code></pre>
Готово. Остается заббикс.
(Сохраняем как .xml и импортируем)

```
<?xml version="1.0" encoding="UTF-8"?>
<zabbix_export>
    <version>3.2</version>
    <date>2017-10-09T15:28:21Z</date>
    <groups>
        <group>
            <name>Templates</name>
        </group>
    </groups>
    <templates>
        <template>
            <template>astra</template>
            <name>Astra_monitoring</name>
            <description/>
            <groups>
                <group>
                    <name>Templates</name>
                </group>
            </groups>
            <applications/>
            <items>
                <item>
                    <name>CH-BT</name>
                    <type>10</type>
                    <snmp_community/>
                    <multiplier>1</multiplier>
                    <snmp_oid/>
                    <key>astra[ {$CH_ID}, &quot;bitrate&quot;]</key>
                    <delay>60</delay>
                    <history>90</history>
                    <trends>365</trends>
                    <status>0</status>
                    <value_type>3</value_type>
                    <allowed_hosts/>
                    <units>bps</units>
                    <delta>0</delta>
                    <snmpv3_contextname/>
                    <snmpv3_securityname/>
                    <snmpv3_securitylevel>0</snmpv3_securitylevel>
                    <snmpv3_authprotocol>0</snmpv3_authprotocol>
                    <snmpv3_authpassphrase/>
                    <snmpv3_privprotocol>0</snmpv3_privprotocol>
                    <snmpv3_privpassphrase/>
                    <formula>1000</formula>
                    <delay_flex/>
                    <params/>
                    <ipmi_sensor/>
                    <data_type>0</data_type>
                    <authtype>0</authtype>
                    <username/>
                    <password/>
                    <publickey/>
                    <privatekey/>
                    <port/>
                    <description/>
                    <inventory_link>0</inventory_link>
                    <applications/>
                    <valuemap/>
                    <logtimefmt/>
                </item>
                <item>
                    <name>CH-CC</name>
                    <type>0</type>
                    <snmp_community/>
                    <multiplier>1</multiplier>
                    <snmp_oid/>
                    <key>astra[ {$CH_ID}, &quot;cc_error&quot;]</key>
                    <delay>60</delay>
                    <history>90</history>
                    <trends>365</trends>
                    <status>0</status>
                    <value_type>3</value_type>
                    <allowed_hosts/>
                    <units>bps</units>
                    <delta>0</delta>
                    <snmpv3_contextname/>
                    <snmpv3_securityname/>
                    <snmpv3_securitylevel>0</snmpv3_securitylevel>
                    <snmpv3_authprotocol>0</snmpv3_authprotocol>
                    <snmpv3_authpassphrase/>
                    <snmpv3_privprotocol>0</snmpv3_privprotocol>
                    <snmpv3_privpassphrase/>
                    <formula>1000</formula>
                    <delay_flex/>
                    <params/>
                    <ipmi_sensor/>
                    <data_type>0</data_type>
                    <authtype>0</authtype>
                    <username/>
                    <password/>
                    <publickey/>
                    <privatekey/>
                    <port/>
                    <description/>
                    <inventory_link>0</inventory_link>
                    <applications/>
                    <valuemap/>
                    <logtimefmt/>
                </item>
                <item>
                    <name>CH-ONAIR</name>
                    <type>0</type>
                    <snmp_community/>
                    <multiplier>0</multiplier>
                    <snmp_oid/>
                    <key>astra[ {$CH_ID}, &quot;onair&quot;]</key>
                    <delay>60</delay>
                    <history>90</history>
                    <trends>0</trends>
                    <status>0</status>
                    <value_type>4</value_type>
                    <allowed_hosts/>
                    <units/>
                    <delta>0</delta>
                    <snmpv3_contextname/>
                    <snmpv3_securityname/>
                    <snmpv3_securitylevel>0</snmpv3_securitylevel>
                    <snmpv3_authprotocol>0</snmpv3_authprotocol>
                    <snmpv3_authpassphrase/>
                    <snmpv3_privprotocol>0</snmpv3_privprotocol>
                    <snmpv3_privpassphrase/>
                    <formula>1</formula>
                    <delay_flex/>
                    <params/>
                    <ipmi_sensor/>
                    <data_type>0</data_type>
                    <authtype>0</authtype>
                    <username/>
                    <password/>
                    <publickey/>
                    <privatekey/>
                    <port/>
                    <description/>
                    <inventory_link>0</inventory_link>
                    <applications/>
                    <valuemap/>
                    <logtimefmt/>
                </item>
            </items>
            <discovery_rules/>
            <httptests/>
            <macros>
                <macro>
                    <macro>{$CH_ID}</macro>
                    <value>test</value>
                </macro>
            </macros>
            <templates/>
            <screens/>
        </template>
    </templates>
    <triggers>
        <trigger>
            <expression>{astra:astra[ {$CH_ID}, &quot;onair&quot;].str(True,240)}=0</expression>
            <recovery_mode>0</recovery_mode>
            <recovery_expression/>
            <name>No signal</name>
            <correlation_mode>0</correlation_mode>
            <correlation_tag/>
            <url/>
            <status>0</status>
            <priority>0</priority>
            <description/>
            <type>0</type>
            <manual_close>0</manual_close>
            <dependencies/>
            <tags/>
        </trigger>
    </triggers>
    <graphs>
        <graph>
            <name>Channel</name>
            <width>900</width>
            <height>200</height>
            <yaxismin>0.0000</yaxismin>
            <yaxismax>100.0000</yaxismax>
            <show_work_period>1</show_work_period>
            <show_triggers>1</show_triggers>
            <type>0</type>
            <show_legend>1</show_legend>
            <show_3d>0</show_3d>
            <percent_left>0.0000</percent_left>
            <percent_right>0.0000</percent_right>
            <ymin_type_1>0</ymin_type_1>
            <ymax_type_1>0</ymax_type_1>
            <ymin_item_1>0</ymin_item_1>
            <ymax_item_1>0</ymax_item_1>
            <graph_items>
                <graph_item>
                    <sortorder>0</sortorder>
                    <drawtype>1</drawtype>
                    <color>1A7C11</color>
                    <yaxisside>0</yaxisside>
                    <calc_fnc>2</calc_fnc>
                    <type>0</type>
                    <item>
                        <host>astra</host>
                        <key>astra[ {$CH_ID}, &quot;bitrate&quot;]</key>
                    </item>
                </graph_item>
                <graph_item>
                    <sortorder>1</sortorder>
                    <drawtype>5</drawtype>
                    <color>F63100</color>
                    <yaxisside>1</yaxisside>
                    <calc_fnc>2</calc_fnc>
                    <type>0</type>
                    <item>
                        <host>astra</host>
                        <key>astra[ {$CH_ID}, &quot;cc_error&quot;]</key>
                    </item>
                </graph_item>
            </graph_items>
        </graph>
    </graphs>
</zabbix_export>
```

В настройках нового хоста: меняем макрос под ID нашего канала... 
![](/content/images/2017/10/--------------2017-10-09---20.29.56.png)

И любуемся: 
![](/content/images/2017/10/--------------2017-10-09---20.32.07.png)