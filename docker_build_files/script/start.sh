#!/bin/sh
service mongod start
service httpd start

#Create database mongo, start mongo
mongo < /home/setupmongo.js
