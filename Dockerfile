FROM nginx:1.9.3
RUN apt-get update && apt-get -y install git
RUN apt-get -y install cron
RUN mkdir /www && mkdir /sites
ADD ./run.sh /run.sh
ADD ./default.conf /etc/nginx/conf.d/default.conf

CMD /run.sh
