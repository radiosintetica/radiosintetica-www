---
layout: post
title: Основные команды для работы с докером
tags: [post]
---
<!-- more -->


<h2>boot2docker</h2>

<pre><code># Выяснить на каком ip адресе работает виртуальная машина с докером
$ boot2docker ip
The VM's Host only interface IP address is: 192.168.59.103

# Строка для добавления в .bash_profile, которая выставляет правильные
# переменные окружения
eval $(boot2docker shellinit 2&gt; /dev/null)
</code></pre>

<h2>Образы</h2>

<pre><code># Скачать образ ubuntu с тегом latest
docker pull ubuntu

# То же самое, но указанное явно
docker pull ubuntu:latest

# Скачать все теги образа ubuntu
docker pull --all-tags ubuntu

# Получить список образов, которые есть на локальной машине
$ docker images
REPOSITORY          TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
ubuntu              14.04               9cbaf023786c        4 days ago          192.8 MB

# Просмотр информации об образе
# Пример вывода — https://gist.github.com/bessarabov/4afa32c1ff3c958d4a9f
docker inspect bessarabov/sample_nginx

# Удалить образ ubuntu:latest (так же можно удалять используя IMAGE ID)
docker rmi ubuntu

# Создать образ (в текущей папке должен находится файл Dockerfile)
# Эта команда создаст образ bessarabov/sample_nginx с тегом latest
docker build --tag bessarabov/sample_nginx .

# Создать новый тег на основе уще существующего образа
$ docker tag bessarabov/sample_nginx:latest 192.168.59.103:5000/bessarabov/sample_nginx:latest
$ docker images
REPOSITORY                                    TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
bessarabov/sample_nginx                       latest              b2d112ab861d        18 hours ago        231.6 MB
192.168.59.103:5000/bessarabov/sample_nginx   latest              b2d112ab861d        18 hours ago        231.6 MB
</code></pre>

<h2>Работа с контейнерами</h2>

<pre><code># Запустить контенейр в интерактивном режиме
# (ключи -i -t можно объединить в -it)
$ docker run -i -t ubuntu:14.04 /bin/bash
root@b9ee3d48bf59:/#

# Получить список контенеров
# (если не указать ключ -a, то будет показаны только работающие контенеры)
$ docker ps -a
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS                     PORTS               NAMES
7aacffdfb531        ubuntu:14.04        "/bin/bash"         3 seconds ago       Exited (0) 1 seconds ago                       silly_hopper

# Удалить контенер (можно удалить только остановленный контейнер).
# Команде можно передать как CONTAINER ID, так и NAME
docker rm 7aacffdfb531

# Запустить контейнер и автоматически удалить его после того как он
# остановится
docker run --rm -it ubuntu:14.04 /bin/bash

# Запустить контейнер и указать ему имя 'sample'. Если явно не указывать
# имя, то оно будет создано автоматически, типа 'silly_hopper'
docker run -it --name sample ubuntu:14.04 /bin/bash

# Запустить контейнер в виде демона, сделать чтобы порт 8000 на хост
# машине соответствовал 80 порту в контейнере
docker run --detach --publish 8000:80 --name sample bessarabov/sample_nginx

# Вот как выглядит инфа об этом контейнере:
$ docker ps -a
CONTAINER ID        IMAGE                            COMMAND                CREATED             STATUS              PORTS                  NAMES
5124abdf830b        bessarabov/sample_nginx:latest   "/bin/sh -c 'nginx -   3 seconds ago       Up 2 seconds        0.0.0.0:8000-&gt;80/tcp   sample

# Ну и дальше с помощью `boot2docker ip` можно узать ip адрес хост
# машины и как-нибудь обратиться к ней:
curl 192.168.59.103:8000

# Для того чтобы остановить контейнер
docker stop sample

# После того как контейнер остановлен его можно удать (и он больше не
# будет показываться в `docker ps -a`:
docker rm sample
</code></pre>

<h2>Автокомлит для команды docker на Mac OS X</h2>

<p><a href="http://stackoverflow.com/questions/26132451/how-to-add-bash-command-completion-for-docker-on-mac-os-x">Обсуждение на stackoverflow</a>.</p>

<pre><code>brew update
brew install bash-completion
curl -GET https://raw.githubusercontent.com/docker/docker/master/contrib/completion/bash/docker &gt; `brew --prefix`/etc/bash_completion.d/docker
</code></pre>

<p>И в .bash_profile вставить:</p>

<pre><code># http://superuser.com/questions/819221/how-to-install-the-debian-bash-completion-using-homebrew
if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
fi
</code></pre>
</script></body></html>