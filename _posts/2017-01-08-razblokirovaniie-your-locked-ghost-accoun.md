---
layout: post
title: Разблокировка  аккаунта на ghost
tags: [post]
---
После 5 попыток входа учетная запись блокируется, и если вы не настроили электронную почту, вы не можете войти в панель управления....

<!-- more -->

Но мы можем  изменить свой пароль и разблокировать учетную запись непосредственно в базе данных.
<pre>
Находим свой файл базы данных в том месте, где установлен ghost. Предположим, что это 
/var/www/blog/ghost;

Файлы БД должны находиться в каталоге 
/var/www/blog/ghost/content/data;

Поставим Sqlite3, если его нет:
 sudo apt-get install sqlite3

Открываем базу данных с помощью sqlite3:
sqlite3 ghsot.db;

Ищем нужный аккаунт
select * from users;

Мы должны увидеть, что есть один аккаунт, который заблокирован.

Генерировать пароль BCrypt Hash можно с помощью сервиса http://bcrypthashgenerator.apphb.com/

Сменим пароль на test:
update from users set password="$2a$10$ImM7dqlGczqWk2gNFRP0tuXh6I0nTDxFbwv57tNEqDOAkcC/odICa" where id=1;

Активируем учетную запись:
update from users set status="active" where id=1;
</pre>