server-bootstrap
================

Bootstrap all application that I need to run django/nginx/mysql/supervisor with easy add/remove lib/programs

It`s used when you get a brand new server and want to make all boring proccess of installation.
Take a look at the bootstrap.sh file and see with libs is installed.

Main libs/programs
  git
  fabric
  ruby
  compass
  pip
  virtualenv
  supervisor
  nginx
  mysql
  lib of PIL
  
It needs node and npm, I don`t put here because I install node from command line (yes, I`ll put the instalation proccess here too)

This configuration is to run a django server. But it can help you to create your own, who know, ruby server bootstrap
