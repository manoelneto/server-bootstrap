#!/bin/bash

#User editable
USER='athenas'
DEFAULT_LOCALE='pt_BR.utf8'
APPS_DIR='/deploy'

# execuable:apt-get isntaler
APT_BINARIES=('mysql-server' 'libmysqlclient-dev' 'nginx' 'python-pip' 'python-virtualenv' 'git' 'fabric' 'ruby' 'rubygems' 'build-essential' 'python-dev' 'graphicsmagick' 'python-libtiff' 'libjpeg8' 'libjpeg62-dev' 'libfreetype6' 'libfreetype6-dev' 'supervisor')
NPM_BINARIES=('grunt:grunt-cli' 'bower:bower')
PYTHON_LIBS=('PIL')
GEM_LIBS=('compass')

# variables
n=/dev/null

# if you get PIL install error, uncomment these lines
# export CFLAGS=-Qunused-arguments
# export CPPFLAGS=-Qunused-arguments

# updating system
# apt-get update

# configuring locale
locale -a | grep $DEFAULT_LOCALE > $n
if [ $? != 0 ]
    then
    locale-gen $DEFAULT_LOCALE
    dpkg-reconfigure locales
    echo 'please, reopen shell (ssh) to load locale'
    exit 0
fi

# adding user
getent passwd $USER > $n
if [ $? != 0 ]
    then
    echo "Adding User '$USER'"
    adduser $USER
fi

check_and_install(){
    local lib=$1
    local installer_command=$2

    dpkg -s $lib &> $n
    if [ $? != 0 ]
        then
        $installer_command $lib
    fi
}

check_and_install_npm(){
    local bin=$1
    local installer=$2
    local installer_command=$3

    which $bin &> $n
    if [ $? != 0 ]
        then
        $installer_command $installer
    fi
}

# Instaling apt libs
for lib in "${APT_BINARIES[@]}"
do
    check_and_install $lib "apt-get install -y"
    # check if bin is installed
done

# for PIL
[ ! -e /usr/lib/libjpeg.so ] && ln -s /usr/lib/x86_64-linux-gnu/libjpeg.so /usr/lib/
[ ! -e /usr/lib/libfreetype.so ] && ln -s /usr/lib/x86_64-linux-gnu/libfreetype.so /usr/lib/
[ ! -e /usr/lib/libz.so ] && ln -s /usr/lib/x86_64-linux-gnu/libz.so /usr/lib/

# Instaling npm binaries
for bin_installer in "${NPM_BINARIES[@]}"
do
    bin=`echo $bin_installer | cut -d':' -f1`
    installer=`echo $bin_installer | cut -d':' -f2`
    check_and_install_npm $bin $installer "npm install -g"
    # check if bin is installed
done

# Instaling python libs
for lib in "${PYTHON_LIBS[@]}"
do
    /usr/bin/python -c "import $lib"
    if [ $? != 0 ]
        then
        pip install $lib
    fi
done

# Instaling ruby libs
for lib in "${GEM_LIBS[@]}"
do
    gem list $lib -i &> $n
    if [ $? != 0 ]
        then
        gem install $lib --no-ri --no-rdoc
    fi
done

# check of apps dir
if [ ! -d $APPS_DIR ]
    then
    echo "Creating \"$APPS_DIR\" folder and setting \"$USER\" as owner"
    # creating folders
    mkdir $APPS_DIR

    # setting folder user
    chown $USER: $APPS_DIR
fi

# in some cases, apache is installed, so we need to purge
dpkg -s apache2 &> $n
if [ $? == 0 ]
    then
    apt-get purge apache2 -y
fi

if [ ! -e "/home/$USER/.ssh/id_rsa" ]
    then
    su $USER -c "ssh-keygen -t rsa"
    echo "Copy your ssh pub to your github account"
    echo ""
    su $USER -c "cat ~/.ssh/id_rsa.pub"
    echo ""
fi

echo "Everything is ok"
echo ""
echo "SUPERVISOR"
echo "Please, alter your /etc/supervisor/supervisord.conf"
echo "where is: files = /etc/supervisor/conf.d/*.conf"
echo "change to: files = $APPS_DIR/*/supervisor.conf"
echo ""
echo "NGINX"
echo "Please, add in /etc/nginx/nginx.conf"
echo "above: include /etc/nginx/conf.d/*.conf;"
echo "add: include $APPS_DIR/*/nginx.conf;"
echo ""
echo "SUDOERS"
echo "If you want to $USER be able to use sudo, then"
echo "Add \"$USER   ALL = (ALL)    ALL\""
echo "Do you want to do it now? (y/n)"
read add_sudoers
if [ $add_sudoers == 'y' ]
    then
    echo "$USER   ALL = (ALL)    ALL" >> /etc/sudoers
    echo "User \"$USER\" added to sudoers file"
fi
