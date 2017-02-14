#!/bin/sh

####################################
# CONFIG
# Config information depend on your computer
default_image_name="docker_streamed"
host_ip="127.0.0.1"
host_port="80"
source_dir="/Users/congdinh/Documents/Projects/angular_streamed"
host_mysql_user="root"
host_mysql_user_pass="123456"
docker_mysql_user="root"
docker_mysql_user_pass="123456"
####################################


type=$1
image_name=$default_image_name
# Build image from Dockerfile
if [ $type = "-b" ]
then
	image_name=$2
	if [ -z $image_name ]
	then
		image_name=$default_image_name
	fi
	docker build -t $image_name .

	# Remove <none> image
	# rmi $(docker images -f dangling=true -q)
fi

# Get current host ip
current_ip="$(ifconfig en1| grep 'inet' | cut -d: -f2 | awk '{getline; print $2}')"

# CREATE MYSQL USER
is_exist_user="$(/Applications/MAMP/Library/bin/mysql -u$host_mysql_user -p$host_mysql_user_pass -e "SELECT EXISTS(SELECT 1 FROM mysql.user WHERE user = '$docker_mysql_user' AND host = '$current_ip')" | awk '{getline; print $1}')"

if [ $is_exist_user = 0 ]
then
    /Applications/MAMP/Library/bin/mysql -u$host_mysql_user -p$host_mysql_user_pass -e "CREATE USER '$docker_mysql_user'@'$current_ip' IDENTIFIED BY '$docker_mysql_user_pass';"
	/Applications/MAMP/Library/bin/mysql -u$host_mysql_user -p$host_mysql_user_pass -e "GRANT ALL PRIVILEGES ON *.* TO '$docker_mysql_user'@'$current_ip';"
fi

# START DOCKER
# Run docker
current_container="$(docker run -v $source_dir:/var/www/html -dit -p $host_ip:$host_port:80 --add-host=docker:$current_ip $image_name)"

# Start service in current container
docker exec -it $current_container /home/start.sh

# Remove all exited container
docker rm $(docker ps -q -f status=exited)

# Connect to current container
# docker attach $current_container
