#! /bin/bash
#===============================================================================================
#   System Required:  CentOS / RedHat / Fedora 
#   Description:  Install SVNadmin(Linux + Apache + MySQL +JDK +Tomcat + SVN +SVNadmin ) for CentOS / RedHat / Fedora
#   Author: hehaipi <mysql@mail.com>
#   Intro:  http://www.heibai.info/svn.html
#===============================================================================================

clear
echo ""
echo "#############################################################"
echo "# LAMJTSS Auto Install Script for CentOS / RedHat / Fedora  #"
echo "# Intro: http://www.heibai.info/svn.html                      #"
echo "# Author: haipi <mysql@mail.com>                            #"
echo "#############################################################"
echo ""

# Install time state
StartDate=''
StartDateSecond=''
# Software Version
MySQLVersion='mysql-5.6.23'
MySQLVersion2='mysql-5.5.42'
ApacheVersion='httpd-2.2.22'
aprVersion='apr-1.3.6'
aprutilVersion='apr-util-1.3.8'
zlibVersion='zlib-1.2.3'
libiconvVersion='libiconv-1.14'
libmcryptVersion='libmcrypt-2.5.8'
pcreVersion='pcre-8.36'
libeditVersion='libedit-20141030-3.1'
imapVersion='imap-2007f'
jdkVersion='jdk1.7.0_80'
nenoVersion='neon-0.29.6'
svnVersion='subversion-1.7.5'
tomcatVersion='tomcat-7.0.73'
sqliteVersion='sqlite-autoconf-3080900'
# Current folder
cur_dir=`pwd`
# CPU Number
Cpunum=`cat /proc/cpuinfo | grep 'processor' | wc -l`;

# Install svn Script
function install_svnadmin(){
    rootness
    disable_selinux
	  disable_iptables
    pre_installation_settings
    untar_all_files
	  install_apr
	  install_apr-util
	  install_zlib
    install_pcre
	  install_neno
	  install_sqlite
    install_apache
    install_database
    install_libiconv
    install_libmcrypt
    install_libedit
    install_imap
	  install_jdk
	  install_svn
	  install_tomcat
}

# is 64bit or not
function is_64bit(){
    if [ `getconf WORD_BIT` = '32' ] && [ `getconf LONG_BIT` = '64' ] ; then
        return 0
    else
        return 1
    fi        
}

# Get version
function getversion(){
    if [[ -s /etc/redhat-release ]];then
        grep -oE  "[0-9.]+" /etc/redhat-release
    else    
        grep -oE  "[0-9.]+" /etc/issue
    fi    
}

# CentOS version
function centosversion(){
    local code=$1
    local version="`getversion`"
    local main_ver=${version%%.*}
    if [ $main_ver == $code ];then
        return 0
    else
        return 1
    fi        
}

# Make sure only root can run our script
function rootness(){
    if [[ $EUID -ne 0 ]]; then
       echo "Error:This script must be run as root!" 1>&2
       exit 1
    fi
}

# Disable selinux
function disable_selinux(){
    if [ -s /etc/selinux/config ] && grep 'SELINUX=enforcing' /etc/selinux/config; then
        sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
        setenforce 0
    fi
}

# Disable iptables
function disable_iptables(){
     service iptables stop
	 chkconfig iptables off
}

# Pre-installation settings
function pre_installation_settings(){
    echo ""
    # Choose databese
    while true
    do
    echo "Please choose a version of the Database:"
    echo -e "\t\033[32m1\033[0m. Install MySQL-5.6(recommend)"
    echo -e "\t\033[32m2\033[0m. Install MySQL-5.5"
    read -p "Please input a number:(Default 1) " DB_version
    [ -z "$DB_version" ] && DB_version=1
    case $DB_version in
        1|2)
        echo ""
        echo "---------------------------"
        echo "You choose = $DB_version"
        echo "---------------------------"
        echo ""
        break
        ;;
        *)
        echo "Input error! Please only input number 1,2"
    esac
    done
    # Set MySQL root password
    echo "Please input the root password of MySQL:"
    read -p "(Default password: root):" dbrootpwd
    if [ "$dbrootpwd" = "" ]; then
        dbrootpwd="root"
    fi
    echo ""
    echo "---------------------------"
    echo "Password = $dbrootpwd"
    echo "---------------------------"
    echo ""
    if [ $DB_version -eq 1 -o $DB_version -eq 2 ]; then
        # Define the MySQL data location.
        echo "Please input the MySQL data location:"
        read -p "(leave blank for /usr/local/mysql/data):" datalocation
        [ -z "$datalocation" ] && datalocation="/usr/local/mysql/data"
        echo ""
        echo "---------------------------"
        echo "Data location = $datalocation"
        echo "---------------------------"
        echo ""
    fi

    get_char(){
        SAVEDSTTY=`stty -g`
        stty -echo
        stty cbreak
        dd if=/dev/tty bs=1 count=1 2> /dev/null
        stty -raw
        stty echo
        stty $SAVEDSTTY
    }
    echo ""
    echo "Press any key to start...or Press Ctrl+C to cancel"
    char=`get_char`

    #Remove Packages
    yum -y remove httpd*
    yum -y remove mysql
	yum -y remove subversion*
	
    #Set timezone
    rm -f /etc/localtime
    ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    yum -y install ntp
    ntpdate -d cn.pool.ntp.org
    StartDate=$(date);
    StartDateSecond=$(date +%s);
    echo "Start time: ${StartDate}";
    #Install necessary tools
    if [ ! -s /etc/yum.conf.bak ]; then
        cp /etc/yum.conf /etc/yum.conf.bak
    fi
    sed -i 's:exclude=.*:exclude=:g' /etc/yum.conf
    packages="wget autoconf automake bison bzip2 bzip2-devel curl curl-devel cmake cpp crontabs diffutils elinks e2fsprogs-devel expat* file flex freetype-devel gcc gcc-c++ gd glibc-devel glib2-devel gettext-devel gmp-devel icu kernel-devel libaio libtool-libs libjpeg-devel libpng-devel libxslt libxslt-devel libxml* libidn-devel libcap-devel libtool-ltdl-devel libc-client-devel libicu libicu-devel lynx zip zlib-devel unzip patch mlocate make ncurses-devel readline readline-devel vim-minimal sendmail pam-devel pcre pcre-devel openldap openldap-devel openssl openssl-devel perl-DBD-MySQL glibc.i686"
    for package in $packages;
    do yum -y install $package; done
}


# Untar all files
function untar_all_files(){
    echo "Untar all files, please wait a moment..."
    if [ -d $cur_dir/untar ]; then
        rm -rf $cur_dir/untar
    fi
    mkdir -p $cur_dir/untar
    for file in `ls *.tar.gz`;
    do
        tar -zxf $file -C $cur_dir/untar
    done
    echo "Untar all files completed!"
}


# install apr
function install_apr(){
    if [ ! -d /usr/local/apr ];then
        echo "Start Installing ${aprVersion}"
        cd $cur_dir/untar/$aprVersion
        ./configure --prefix=/usr/local/apr
        make && make install
		cat /etc/ld.so.conf
		echo /usr/local/apr/lib >> /etc/ld.so.conf
        echo "${aprVersion} Install completed!"
    else
        echo "apr had been installed!"
    fi
}

# install apr-util
function install_apr-util(){
    if [ ! -d /usr/local/apr-util ];then
        echo "Start Installing ${aprutilVersion}"
        cd $cur_dir/untar/$aprutilVersion
        ./configure --prefix=/usr/local/apr-util --with-apr=/usr/local/apr/
        make
		make install
		echo /usr/local/apr-util/lib >> /etc/ld.so.conf
		ldconfig
        echo "${aprutilVersion} Install completed!"
    else
        echo "aprutil had been installed!"
    fi
}

# install zlib
function install_zlib(){
    if [ ! -d /usr/local/zlib ];then
        echo "Start Installing ${zlibVersion}"
        cd $cur_dir/untar/$zlibVersion
        CFLAGS="-O3 -fPIC" ./configure --prefix=/usr/local/zlib/
        make && make install
        echo "${zlibVersion} Install completed!"
    else
        echo "zlib had been installed!"
    fi
}


function install_sqlite(){
    if [ ! -d /usr/local/sqlite ];then
        echo "Start Installing ${sqliteVersion}"
        cd $cur_dir/untar/$sqliteVersion
        ./configure --prefix=/usr/local/sqlite
        make && make install
        echo "${sqliteVersion} Install completed!"
    else
        echo "sqlite had been installed!"
    fi
}

#install neno
function install_neno(){
    if [ ! -d /usr/local/neno ];then
        echo "Start Installing ${nenoVersion}"
        cd $cur_dir/$nenoVersion
        ./configure \
		--prefix=/usr/local/neon \
		--with-ssl \
		--enable-shared \
		--enable-static
        make && make install
        echo "${nenoVersion} Install completed!"
    else
        echo "neno had been installed!"
    fi
}



# Install Apache
function install_apache(){
    if [ ! -d /usr/local/apache/bin ];then
        #Install Apache
        echo "Start Installing ${ApacheVersion}"
        cd $cur_dir/untar/$ApacheVersion
        ./configure \
		--prefix=/usr/local/apache \
		--with-mpm=worker \
		--disable-userdir \
		--enable-ssl \
		--enable-headers \
		--enable-deflate \
		--enable-expires \
		--enable-dav \
		--enable-so \
		--disable-status \
		--disable-autoindex \
		--disable-asis \
		--enable-nonportable-atomics=yes \
		--with-apr=/usr/local/apr \
		--with-apr-util=/usr/local/apr-util \
		--with-z=/usr/local/zlib/
        make && make install
        if [ $? -ne 0 ]; then
            echo "Installing Apache failed, Please visit http://www.heibai.info/svn.html and contact."
            exit 1
        fi
        cp -rf $cur_dir/httpd.conf /usr/local/apache/conf/ 
        echo "${ApacheVersion} Install completed!"
    else
        echo "Apache had been installed!"
    fi
}

# Install database
function install_database(){
    if [ $DB_version -eq 1 -o $DB_version -eq 2 ]; then
        install_mysql
    fi
}


# Install mysql database
function install_mysql(){
    if [ ! -d /usr/local/mysql ];then
        # Install MySQL
        cd $cur_dir/
        if [ $DB_version -eq 1 ]; then
            echo "Start Installing ${MySQLVersion}"
            cd $cur_dir/untar/$MySQLVersion
        elif [ $DB_version -eq 2 ]; then
            echo "Start Installing ${MySQLVersion2}"
            cd $cur_dir/untar/$MySQLVersion2
        fi
        /usr/sbin/groupadd mysql
        /usr/sbin/useradd -s /sbin/nologin -M -g mysql mysql
        # Compile MySQL
        cmake \
        -DCMAKE_INSTALL_PREFIX=/usr/local/mysql \
        -DMYSQL_UNIX_ADDR=/tmp/mysql.sock \
        -DDEFAULT_CHARSET=utf8 \
        -DDEFAULT_COLLATION=utf8_general_ci \
        -DWITH_EXTRA_CHARSETS=complex \
        -DWITH_INNOBASE_STORAGE_ENGINE=1 \
        -DWITH_READLINE=1 \
        -DENABLED_LOCAL_INFILE=1 \
        -DWITH_PARTITION_STORAGE_ENGINE=1 \
        -DWITH_FEDERATED_STORAGE_ENGINE=1 \
        -DWITH_BLACKHOLE_STORAGE_ENGINE=1 \
        -DWITH_MYISAM_STORAGE_ENGINE=1 \
        -DWITH_EMBEDDED_SERVER=1
        make && make install
        if [ $? -ne 0 ]; then
            echo "Installing MySQL failed, Please visit http://www.heibai.info/svn.html and contact."
            exit 1
        fi
        chmod +w /usr/local/mysql
        chown -R mysql:mysql /usr/local/mysql
        cd support-files/
        cp -f $cur_dir/my.cnf /etc/my.cnf
        cp -f mysql.server /etc/init.d/mysqld
        sed -i "s:^datadir=.*:datadir=$datalocation:g" /etc/init.d/mysqld
        /usr/local/mysql/scripts/mysql_install_db --defaults-file=/etc/my.cnf --basedir=/usr/local/mysql --datadir=$datalocation --user=mysql
        chmod +x /etc/init.d/mysqld
        chkconfig --add mysqld
        chkconfig  mysqld on
        cat > /etc/ld.so.conf.d/mysql.conf<<EOF
/usr/local/mysql/lib
/usr/local/lib
EOF
        ldconfig
        if is_64bit; then
            ln -s /usr/local/mysql/lib/*.* /usr/lib64/mysql
        else
            ln -s /usr/local/mysql/lib/*.* /usr/lib/mysql
        fi
        for i in `ls /usr/local/mysql/bin`
        do
            if [ ! -L /usr/bin/$i ]; then
                ln -s /usr/local/mysql/bin/$i /usr/bin/$i
            fi
        done
        #Start mysqld service
        /etc/init.d/mysqld start
        /usr/local/mysql/bin/mysqladmin password $dbrootpwd
        /usr/local/mysql/bin/mysql -uroot -p$dbrootpwd <<EOF
drop database if exists test;
delete from mysql.user where user='';
update mysql.user set password=password('$dbrootpwd') where user='root';
delete from mysql.user where not (user='root') ;
create database svnadmin;
use svnadmin;
source $cur_dir/mysql5.sql;
flush privileges;
exit
EOF
		echo "MySQL Install completed!"
    else
        echo "MySQL had been installed!"
    fi
}

#Install pcre dependency
function install_pcre(){
    cd $cur_dir/untar/$pcreVersion
    ./configure --prefix=/usr/local/pcre
    make && make install
    if is_64bit; then
        ln -s /usr/local/pcre/lib /usr/local/pcre/lib64
    fi
    [ -d "/usr/local/pcre/lib" ] && export LD_LIBRARY_PATH=/usr/local/pcre/lib:$LD_LIBRARY_PATH
    [ -d "/usr/local/pcre/bin" ] && export PATH=/usr/local/pcre/bin:$PATH
    echo "${pcreVersion} install completed!"
}

# Install libiconv dependency
function install_libiconv(){
    cd $cur_dir/untar/$libiconvVersion
    ./configure --prefix=/usr/local/libiconv
    make && make install
    echo "${libiconvVersion} install completed!"
}

# Install libmcrypt dependency
function install_mcrypt(){
    /sbin/ldconfig
    cd $cur_dir/untar/$mcryptVersion
    ./configure
    make && make install
    echo "${mcryptVersion} install completed!"
}


# Install libedit dependency
function install_libedit(){
    cd $cur_dir/untar/$libeditVersion
    ./configure --enable-widec
    make && make install
    echo "${libeditVersion} install completed!"
}

# Install imap dependency
function install_imap(){
    if centosversion 7; then
        cd $cur_dir/untar/$imapVersion
        if is_64bit; then
            make lr5 PASSWDTYPE=std SSLTYPE=unix.nopwd EXTRACFLAGS=-fPIC IP=4
        else
            make lr5 PASSWDTYPE=std SSLTYPE=unix.nopwd IP=4
        fi
        rm -rf /usr/local/imap-2007f/
        mkdir /usr/local/imap-2007f/
        mkdir /usr/local/imap-2007f/include/
        mkdir /usr/local/imap-2007f/lib/
        cp c-client/*.h /usr/local/imap-2007f/include/
        cp c-client/*.c /usr/local/imap-2007f/lib/
        cp c-client/c-client.a /usr/local/imap-2007f/lib/libc-client.a
        echo "${imapVersion} install completed!"
    fi
}

#install jdk
function install_jdk(){
    if [ ! -d /usr/local/jdk1.6.0_13 ];then
        echo "Start Installing ${jdkVersion}"
        cd $cur_dir
        mv untar/$jdkVersion /usr/local/  
		echo 'JAVA_HOME=/usr/local/jdk1.7.0_80' >> ~/.profile
		echo 'PATH=$JAVA_HOME/bin:$PATH' >> ~/.profile
		echo 'CLASSPATH=.:$JAVA_HOME/lib/dt.jar:$JAVA_HOME/lib/tools.jar' >> ~/.profile
		echo 'export JAVA_HOME' >> ~/.profile
		echo 'export PATH' >> ~/.profile
		echo 'export CLASSPATH' >> ~/.profile

       source  ~/.profile
        echo "${jdkVersion} Install completed!"
    else
        echo "jdk had been installed!"
    fi
}

#install svn
function install_svn(){
    if [ ! -d /usr/local/svn ];then
        echo "Start Installing ${svnVersion}"
        cd $cur_dir/untar/$svnVersion
        ./configure \
		--prefix=/usr/local/svn/ \
		--with-apr=/usr/local/apr \
		--with-apr-util=/usr/local/apr-util/ \
		--with-apxs=/usr/local/apache/bin/apxs \
		--with-sqlite=/usr/local/sqlite \
		--with-zlib=/usr/local/zlib/ \
		--with-neon=/usr/local/neon/ \
		--enable-maintainer-mode
        make && make install
		cp -rf /usr/local/svn/libexec/*.so /usr/local/apache/modules
		/usr/local/apache/bin/apachectl -k start
        echo "${svnVersion} Install completed!"
    else
        echo "svn had been installed!"
    fi
}

#install tomcat
function install_tomcat(){
    if [ ! -d /usr/local/tomcat_svn ];then
        echo "Start Installing ${tomcatVersion}"
        cd $cur_dir/untar/$tomcatVersion
		mv $cur_dir/untar/$tomcatVersion /usr/local/tomcat_svn
		cp -f $cur_dir/shutdown.sh /usr/local/tomcat_svn/bin/
		chmod -R 755 /usr/local/tomcat_svn/bin/*.sh
		 cat >/usr/local/tomcat_svn/webapps/ROOT/WEB-INF/jdbc.properties<<EOF
db=MySQL
#MySQL
MySQL.jdbc.driver=com.mysql.jdbc.Driver
MySQL.jdbc.url=jdbc:mysql://localhost:3306/svnadmin?characterEncoding=utf-8
MySQL.jdbc.username=root
MySQL.jdbc.password=$dbrootpwd
MySQL.jdbc.validationQuery=select now()
EOF
        /usr/local/tomcat_svn/bin/startup.sh
        echo "${tomcatVersion} Install completed!"
    else
        echo "tomcat had been installed!"
    fi
}

# Initialization setup
action=$1
[  -z $1 ] && action=install
case "$action" in
install)
    install_svnadmin
    ;;
esac
