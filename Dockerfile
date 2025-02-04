FROM ubuntu:16.04
ENV DEBIAN_FRONTEND noninteractive
ENV PYTHONPATH $PYTHONPATH:/src/

# setup tools
RUN apt-get update -y
RUN apt-get install -y build-essential python python-setuptools curl python-pip libssl-dev
RUN apt-get update -y
RUN apt-get install -y python-software-properties python-mysqldb libmysqlclient-dev libffi-dev libssl-dev python-dev
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get -y install nodejs

RUN apt-get install -y nginx supervisor
RUN pip install --upgrade pip
RUN pip install uwsgi

# Add and install Python modules
ADD requirements.txt /src/requirements.txt
RUN cd /src; pip install -r requirements.txt

# Bundle app source
ADD . /src

# configuration
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
RUN rm /etc/nginx/sites-enabled/default
RUN ln -s /src/conf/nginx-app.conf /etc/nginx/sites-enabled/
RUN ln -s /src/conf/supervisor-app.conf /etc/supervisor/conf.d/

RUN cd /src/ && make build

# Expose - note that load balancer terminates SSL
EXPOSE 80

# RUN
CMD ["supervisord", "-n"]

