#!/bin/sh
if [ $# -ne 1 ]
then
  echo "Usage: `basename $0` <deploy_base_folder>"
  exit 1
fi
FILE=$1'/acdata-web/shared/config'
if [ ! -d $FILE ]
then
   echo "Folder $FILE does not exist. "
   exit 1
fi

#actual copy
cp $FILE/acdata_config.yml $PWD/config/acdata_config.yml
cp $FILE/production.rb $PWD/config/environments/production.rb
cp $FILE/device.rb $PWD/config/initializers/devise.rb
cp $FILE/production_local.rb $PWD/config/deploy/production_local.rb
cp $FILE/ldap.yml $PWD/config/ldap.yml
