#!/bin/bash
clear
echo "Скрипт установки/обновления программного обеспечения.
В режиме установки - устанавливает необходимую версию astra в /usr/bin, создает папку /etc/astra и устанавливает monit.
В режиме обновления - создает папку /astra-backup, архивирует туда текущую версию астры и папку /etc/astra.
Внимание! для версий 5.61 и 5.63 необходим действующий файл лицензии"

echo -n "
1) Обновление astra
2) Установка astra
3) Настройка буфера сетевых соединений

Или нажмите любую клавишу для выхода..
"
read item
case "$item" in
    1) echo "Выбрали обновление"
P=$(uname -m) ; arch=${P//x86_/}
PS3='Выберите версию: '
select version in "5.61" "5.63" "5.64-test"
do
echo
echo "Вы выбрали $version!"
echo
echo "Останавливаем Астру"
monit stop astra
service astra stop
ps auxw | grep -w /usr/bin/astra | grep -v grep  > /dev/null
if [ $? != 1 ]
then
killall astra &  echo "Пришлось убить процесс..."
fi


echo "Делаем резервную копию.."
if [ ! -d "/astra-backup" ]; then
        mkdir /astra-backup & echo "Каталог для резервной копии создан"
                fi
                tar -Pzcf /astra-backup/astra.tar.gz /usr/bin/astra /etc/astra
echo "Удаляем старую версию"
                rm -f /usr/bin/astra
echo "Получаем новую версию"
                wget -O /usr/bin/astra "http://cesbo.com/download/astra/$version/x86/linux-"$arch"bit/astra"
                chmod +x /usr/bin/astra
                monit start astra
                /usr/bin/astra -v
read -p "Готово! программа обновлена!
Резервная копия в каталоге /astra_backup" -n1 -s
exit 0
done
        ;;
   2) echo "Начинаем установку.."
P=$(uname -m) ; arch=${P//x86_/} ; echo $arch
PASSWD=$(date +%s | sha256sum | base64 | head -c 6 ; echo)
PS3='Выберите версию: '
select version in "5.61" "5.63" "5.64-test"
do
echo
echo "Вы выбрали $version!"
echo
ps auxw | grep -w /usr/bin/astra | grep -v grep  > /dev/null
if [ $? != 1 ]
then
read -p "Астра уже запущена! М.б Вы хотели обновить ее? 
Установка завершена" -n1 -s
exit 0
fi
apt-get update
apt-get install monit -y
mv /etc/monit/monitrc /etc/monit/monitrc_old
rm -f /etc/monit/monitrc
touch /etc/monit/monitrc
echo "set daemon 1" >> /etc/monit/monitrc
echo "  with start delay 1" >> /etc/monit/monitrc
echo "" >> /etc/monit/monitrc
echo "set logfile /var/log/monit.log" >> /etc/monit/monitrc
echo "set idfile /var/lib/monit/id" >> /etc/monit/monitrc
echo "set statefile /var/lib/monit/state" >> /etc/monit/monitrc
echo "" >> /etc/monit/monitrc
echo "set httpd port 2812 and" >> /etc/monit/monitrc
echo "  use address localhost" >> /etc/monit/monitrc
echo "  allow localhost" >> /etc/monit/monitrc
echo "" >> /etc/monit/monitrc
echo "include /etc/monit/conf.d/*" >> /etc/monit/monitrc
wget https://radiosintetica.ru/content/images/2016/04/astra.conf -O /etc/monit/conf.d/astra.conf
if [ ! -d "/astra-backup" ]; then
mkdir /astra-backup & echo "Каталог для резервной копии создан"
fi
if [ ! -d "/etc/astra" ]; then
mkdir /etc/astra & echo "Каталог для конфигураций создан"
fi
wget -O /usr/bin/astra "http://cesbo.com/download/astra/$version/x86/linux-"$arch"bit/astra"
chmod +x /usr/bin/astra
chmod 0700 /etc/monit/monitrc
service monit restart
sleep 5
echo "json.save(\"/etc/astra/astra.conf\", { users = { admin = { cipher = make_cipher(\"admin\", \"$PASSWD\"), created = os.time(), enable = true, type = 1 }}}); astra.exit()" | astra - --no-stdout
monit restart astra
/usr/bin/astra -v
read -p "Готово! программа установлена!
Веб-интерфейс доступен на порту 8000
Логин и пароль по умолчанию - admin/$PASSWD" -n1 -s
exit 0
done
;;

3) echo -n "Выберете пункт меню:
1) Показать текущие настройки буфера сетевых соединений
2) Настроить буфер сетевых соединений для адаптера 1G
3) Настроить буфер сетевых соединений для адаптера 10G
4) Настроить буфер сетевых соединений для адаптера 40G
(с применяемыми настройками Вы можете ознакомится на https://cesbo.com/en/linux/networking/
"
read item
case "$item" in
    1) echo "текущие настройки:"
    sysctl net.core.rmem_default net.core.rmem_max net.core.wmem_default net.core.wmem_max net.ipv4.udp_mem net.ipv4.tcp_wmem
read -p "" -n1 -s
        ;;
2)
cp /etc/sysctl.conf   /etc/sysctl.conf.back
cat /etc/sysctl.conf | grep -w "net.core.rmem_max" | grep -v grep  > /dev/null
if [ $? != 0 ]
then
echo "nnet.core.rmem_max = 16777216" >> /etc/sysctl.conf
fi
sed -i 's/.*net.core.rmem_max.*/net.core.rmem_max = 16777216/' /etc/sysctl.conf
cat /etc/sysctl.conf | grep -w "net.core.wmem_max" | grep -v grep  > /dev/null
if [ $? != 0 ]
then
echo "net.core.wmem_max = 16777216" >> /etc/sysctl.conf
fi
sed -i 's/.*net.core.wmem_max.*/net.core.wmem_max = 16777216/' /etc/sysctl.conf 
cat /etc/sysctl.conf | grep -w "net.ipv4.udp_mem" | grep -v grep  > /dev/null
if [ $? != 0 ]
then
echo "net.ipv4.udp_mem = 8388608 12582912 16777216" >> /etc/sysctl.conf
fi
sed -i 's/.*net.ipv4.udp_mem.*/net.ipv4.udp_mem = 8388608 12582912 16777216/' /etc/sysctl.conf 
cat /etc/sysctl.conf | grep -w "net.ipv4.tcp_rmem" | grep -v grep  > /dev/null
if [ $? != 0 ]
then
echo "net.ipv4.tcp_rmem = 4096 87380 8388608" >> /etc/sysctl.conf
fi
sed -i 's/.*net.ipv4.tcp_rmem.*/net.ipv4.tcp_rmem = 4096 87380 8388608/' /etc/sysctl.conf 
cat /etc/sysctl.conf | grep -w "net.ipv4.tcp_wmem" | grep -v grep  > /dev/null
if [ $? != 0 ]
then
echo "net.ipv4.tcp_wmem = 4096 65536 8388608" >> /etc/sysctl.conf
fi
sed -i 's/.*net.ipv4.tcp_wmem.*/net.ipv4.tcp_wmem = 4096 65536 8388608/' /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
read -p "
Настройки sysctl для сетевых адаптеров 1G выполнены!
Примечание:
Предыдущий файл sysctl.conf был сохранен как /etc/sysctl.conf.back
" -n1 -s
        ;;
    3)
cp /etc/sysctl.conf   /etc/sysctl.conf.back
cat /etc/sysctl.conf | grep -w "net.core.rmem_max" | grep -v grep  > /dev/null
if [ $? != 0 ]
then
echo "nnet.core.rmem_max = 67108864" >> /etc/sysctl.conf
fi
sed -i 's/.*net.core.rmem_max.*/net.core.rmem_max = 67108864/' /etc/sysctl.conf
cat /etc/sysctl.conf | grep -w "net.core.wmem_max" | grep -v grep  > /dev/null
if [ $? != 0 ]
then
echo "net.core.wmem_max = 67108864" >> /etc/sysctl.conf
fi
sed -i 's/.*net.core.wmem_max.*/net.core.wmem_max = 67108864/' /etc/sysctl.conf 
cat /etc/sysctl.conf | grep -w "net.ipv4.udp_mem" | grep -v grep  > /dev/null
if [ $? != 0 ]
then
echo "net.ipv4.udp_mem = 8388608 16777216 33554432" >> /etc/sysctl.conf
fi
sed -i 's/.*net.ipv4.udp_mem.*/net.ipv4.udp_mem = 8388608 16777216 33554432/' /etc/sysctl.conf 
cat /etc/sysctl.conf | grep -w "net.ipv4.tcp_rmem" | grep -v grep  > /dev/null
if [ $? != 0 ]
then
echo "net.ipv4.tcp_rmem = 4096 87380 33554432" >> /etc/sysctl.conf
fi
sed -i 's/.*net.ipv4.tcp_rmem.*/net.ipv4.tcp_rmem = 4096 87380 33554432/' /etc/sysctl.conf 
cat /etc/sysctl.conf | grep -w "net.ipv4.tcp_wmem" | grep -v grep  > /dev/null
if [ $? != 0 ]
then
echo "net.ipv4.tcp_wmem = 4096 65536 33554432" >> /etc/sysctl.conf
fi
sed -i 's/.*net.ipv4.tcp_wmem.*/net.ipv4.tcp_wmem = 4096 65536 33554432/' /etc/sysctl.conf
cat /etc/sysctl.conf | grep -w "net.ipv4.tcp_congestion_control" | grep -v grep  > /dev/null
if [ $? != 0 ]
then
echo "net.ipv4.tcp_congestion_control=htcp" >> /etc/sysctl.conf
fi
sed -i 's/.*net.ipv4.tcp_congestion_control.*/net.ipv4.tcp_congestion_control=htcp/' /etc/sysctl.conf
read -p "
Настройки sysctl для сетевых адаптеров 10G выполнены!
Примечание:
Предыдущий файл sysctl.conf был сохранен как /etc/sysctl.conf.back
" -n1 -s
        ;;
    4) 
cp /etc/sysctl.conf   /etc/sysctl.conf.back
cat /etc/sysctl.conf | grep -w "net.core.rmem_max" | grep -v grep  > /dev/null
if [ $? != 0 ]
then
echo "nnet.core.rmem_max = 134217728" >> /etc/sysctl.conf
fi
sed -i 's/.*net.core.rmem_max.*/net.core.rmem_max = 134217728/' /etc/sysctl.conf
cat /etc/sysctl.conf | grep -w "net.core.wmem_max" | grep -v grep  > /dev/null
if [ $? != 0 ]
then
echo "net.core.wmem_max = 134217728" >> /etc/sysctl.conf
fi
sed -i 's/.*net.core.wmem_max.*/net.core.wmem_max = 134217728/' /etc/sysctl.conf 
cat /etc/sysctl.conf | grep -w "net.ipv4.udp_mem" | grep -v grep  > /dev/null
if [ $? != 0 ]
then
echo "net.ipv4.udp_mem = 8388608 33554432 67108864" >> /etc/sysctl.conf
fi
sed -i 's/.*net.ipv4.udp_mem.*/net.ipv4.udp_mem = 8388608 33554432 67108864/' /etc/sysctl.conf 
cat /etc/sysctl.conf | grep -w "net.ipv4.tcp_rmem" | grep -v grep  > /dev/null
if [ $? != 0 ]
then
echo "net.ipv4.tcp_rmem = 4096 87380 67108864" >> /etc/sysctl.conf
fi
sed -i 's/.*net.ipv4.tcp_rmem.*/net.ipv4.tcp_rmem = 4096 87380 67108864/' /etc/sysctl.conf 
cat /etc/sysctl.conf | grep -w "net.ipv4.tcp_wmem" | grep -v grep  > /dev/null
if [ $? != 0 ]
then
echo "net.ipv4.tcp_wmem = 4096 65536 67108864" >> /etc/sysctl.conf
fi
sed -i 's/.*net.ipv4.tcp_wmem.*/net.ipv4.tcp_wmem = 4096 65536 67108864/' /etc/sysctl.conf
cat /etc/sysctl.conf | grep -w "net.ipv4.tcp_congestion_control" | grep -v grep  > /dev/null
if [ $? != 0 ]
then
echo "net.ipv4.tcp_congestion_control=htcp" >> /etc/sysctl.conf
fi
sed -i 's/.*net.ipv4.tcp_congestion_control.*/net.ipv4.tcp_congestion_control=htcp/' /etc/sysctl.conf
sysctl -p /etc/sysctl.conf
read -p "
Настройки sysctl для сетевых адаптеров 40G выполнены!
Примечание:
Предыдущий файл sysctl.conf был сохранен как /etc/sysctl.conf.back
" -n1 -s
        ;;
esac
;;
*) echo "Ничего не выбрано..."
exit 0
;;
esac

