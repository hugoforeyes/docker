#!/bin/sh
service httpd start
service mongod start

#Create database mongo, start mongo
mongo < /home/setupmongo.js
