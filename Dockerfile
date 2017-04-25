FROM ubuntu:latest

#install dependencies
RUN apt-get -y update && apt-get install -y curl postgresql redis-server openjdk-8-jre wget git libpq-dev qt4-default libqtwebkit4 libqtwebkit-dev software-properties-common bzip2 gawk make libyaml-dev libsqlite3-dev sqlite3 autoconf libgmp-dev libgdbm-dev libncurses5-dev automake libtool bison pkg-config libffi-dev libgmp-dev libreadline6-dev

#create user
RUN useradd -m tagteam && echo "tagteam:tagteam" | chpasswd  

#start local db
RUN /etc/init.d/postgresql start && su -c "createuser -d -l -r tagteam" postgres

USER tagteam
WORKDIR /home/tagteam
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys D39DC0E3
RUN curl -sSL https://get.rvm.io | bash -s -- --autolibs=read-fail
RUN /bin/bash -l -c ". ~/.rvm/scripts/rvm && rvm install 2.3.3"
RUN /bin/bash -l -c "echo 'gem: --no-ri --no-rdoc' > ~/.gemrc"
RUN /bin/bash -l -c ". ~/.rvm/scripts/rvm && rvm use 2.3.3@tagteam --create && gem install bundler pq --no-ri --no-rdoc"
#RUN  git clone https://github.com/berkmancenter/tagteam.git tagteam

RUN wget https://github.com/berkmancenter/tagteam/archive/v2.1.0.2.tar.gz
RUN tar -xzf v2.1.0.2.tar.gz

#From here, work in the tagteam directory
WORKDIR /home/tagteam/tagteam-2.1.0.2
#install tagteam
RUN /bin/bash -l -c ". ~/.rvm/scripts/rvm && rvm use 2.3.3@tagteam && bundle"

# copy config files ready to be modified
RUN cp config/sunspot.yml.example config/sunspot.yml && cp config/database.yml.example config/database.yml && cp config/tagteam.yml.example config/tagteam.yml 
# fix database config :-(
RUN sed -i -e '13i\ \ template: template0' -e '39i\ \ template: template0' -e '46i\ \ template: template0' config/database.yml

