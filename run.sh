#!/bin/bash

if [[ -z ${WEB_DIR} ]];then

WEB_DIR=/www

fi

if [[ -z ${CONF_DIR} ]];then

CONF_DIR=/sites

fi

CONFS=$(cd ${CONF_DIR};ls *.conf)

for conf in ${CONFS}; do


site=$(echo ${conf}|sed s/.conf//)
conf_file=${CONF_DIR}/${conf}
mkdir ${WEB_DIR}/${site}

site_relative_dir=$(cat ${conf_file}| grep "dir"| sed s/"#"/""/ | cut -d '=' -f2)
site_repo=$(cat ${conf_file}| grep "repo"| sed s/"#"/""/ | cut -d '=' -f2)
site_cron=$(cat ${conf_file}| grep "cron"| sed s/"#"/""/ | cut -d '=' -f2)

site_absolute_dir="${WEB_DIR}/${site}/repo"



if [[ ! -z ${site_relative_dir} ]];then
  site_absolute_dir=${site_absolute_dir}/${site_relative_dir}
fi



#Clone repo
if [[ ! -z ${site_repo} ]];then

  #clone repo if it does not exists
  if [[ ! -d ${site_absolute_dir} ]]; then

    cd ${WEB_DIR}/${site}
    git clone ${site_repo} repo

  fi
fi


#replace %WWW_PATH% with actual path and add configuration into nginx conf dir
cat ${conf_file}|sed "s@%WWW_PATH%@${site_absolute_dir}@g" > /etc/nginx/conf.d/${conf}


#Add cron job
if [[ ! -z ${site_cron} ]]; then
crontab -l | { cat; echo "${site_cron} cd ${site_absolute_dir};git pull origin"; } | crontab -
fi

done



#RUN NGINX
nginx -g 'daemon off;'
