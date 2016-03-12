#!/bin/bash -e

usage(){
  echo "Usage: ./startup.sh -m <MACHINE_NAME> -a <DIGITALOCEAN_ACCESS_TOKEN> -r <DIGITALOCEAN_REGION> (optional) -s <DIGITALOCEAN_SIZE> (optional) -b <DIGITALOCEAN_BACKUPS> (optional)"
}

# Defaults
export REGION=ams3
export SIZE=1gb
export BACKUPS=false

while getopts "m:a:r:s:b:" opt; do
  case $opt in
    m)
      export MACHINE_NAME=${OPTARG}
      ;;
    a)
      export ACCESS_TOKEN=${OPTARG}
      ;;
    r)
      export REGION=${OPTARG}
      ;;
    s)
      export SIZE=${OPTARG}
      ;;
    b)
      export BACKUPS=${OPTARG}
      ;;
    *)
      echo "Invalid parameter(s) or option(s)."
      usage
      exit 1
      ;;
  esac
done

if [ -z $MACHINE_NAME ] | [ -z $ACCESS_TOKEN ]; then
  usage
  exit 1
fi

source data-blog/env_blog

# Create Docker machine if one doesn't already exist with the same name
if $(docker-machine env $MACHINE_NAME > /dev/null 2>&1) ; then
    echo "Docker machine '$MACHINE_NAME' already exists"
else
    docker-machine create --driver digitalocean --digitalocean-access-token=$ACCESS_TOKEN --digitalocean-region=$REGION --digitalocean-size=$SIZE --digitalocean-backups=$BACKUPS --digitalocean-image ubuntu-14-04-x64 $MACHINE_NAME 
fi


eval "$(docker-machine env $MACHINE_NAME)"
export TARGET_HOST=$(docker-machine ip $MACHINE_NAME)

# Download the images
docker-compose pull

# Start the images
docker-compose up -d

echo
echo '##########################################################'
echo
echo SUCCESS, your new blog is created!
echo
echo Run these commands in your shell:
echo    eval "$(docker-machine env $MACHINE_NAME)"
echo '  source /conf/env_ghost'
echo
echo Navigate to http://$TARGET_HOST in your browser to use your new blog!
echo Do not forget to update your DNS records of $DOMAIN to point at $TARGET_HOST


