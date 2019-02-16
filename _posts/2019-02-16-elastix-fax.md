---
layout: post
title: Elastix - проигрывание сообщения перед отправкой факса
tags: [linux]
---
Если у вас установлен дистрибутив Elastix, то hylafax и iaxmodem у вас уже настроены.
<!-- more -->

 Так же  исходим из того что факсы у вас настроены и нормально проходят. Нужно только, чтобы удаленному абоненту перед отправкой факса проигралось голосовое сообщение "Примите, пожалуйста, факс". 

Для того чтобы это осуществить, надо напрямую исправить конфигурационные файла Asterisk  из консоли. Нужно сделать сделующее:

Скопировать макрос [macro-dialout-trunk] из файла extensions_additional.conf в файл extensions_override_freepbx.conf
После строчки  
```exten => s,n,ExecIf($["${FORCE_CONFIRM}"!="" ]?Set(DIAL_TRUNK_OPTIONS=${DIAL_TRUNK_OPTIONS}M(confirm)))```
нужно вставить:  
```exten => s,n,ExecIf($["${AMPUSER}" = "215"]?Set(DIAL_TRUNK_OPTIONS=${DIAL_TRUNK_OPTIONS}A(faxmsg)))```

Предполагается, что факс у нас один и его внутренний номер 215, файл faxmsg.wav записан с параметрами 8кГц,16 бит и лежит в каталоге /var/lib/asterisk/sounds/ru , если у вас установлена поддержка русского языка.  

В двух словах, строчка проверяет, не с факса ли звоним, и добавляет голосовое приветствие в этом случае.  

Использован материал из 
http://www.asteriskforum.ru/viewtopic.php?p=63041  
http://asterisk-support.ru/question/15122/free-fax-digium/  
http://mtaalamu.ru/blog/admining/2161.html  