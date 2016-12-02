# installsvn
## 简介
* 1. LAMJST 指的是 Linux + Apache + MySQL + JDK + SVN + Tomcat 运行环境
* 2. LAMJST 一键安装是用 Linux Shell 语言编写的，用于在 Linux 系统(Redhat/CentOS/Fedora)上一键安装 svnadmin 环境的工具脚本。
* 3. 安装完成后配置修改 请访问 [http://www.heibai.info/svn.html) 
## 本脚本的系统需求
* 需要 2GB 及以上磁盘剩余空间
* 需要 256M 及以上内存空间
* 服务器必须配置好软件源和可连接外网
* 必须具有系统 Root 权限
* 建议使用干净系统全新安装
* 日期：2015年04月09日

## 将会安装
*  1、Apache 2.2.22
*  2、MySQL 5.6.23、MySQL 5.5.42（二选一安装）
*  3、jdk1.7.0_80
*  4、neon-0.29.6
*  5、subversion-1.7.5
*  6、tomcat-7.0.73 (已经集成svnadmin3.0.6) 




## 如何安装
### 事前准备（安装screen、unzip，创建 screen 会话）：

    yum -y install wget screen unzip
    screen -S svn

### 第一步，下载、解压、赋予权限：
   下载地址 
    unzip svn.zip
    cd svn/
    chmod +x *.sh

### 第二步，安装LAMJST
终端中输入以下命令：

    ./svn.sh 2>&1 | tee svn.log


##管理后台
SVNadmin后台地址: http://服务器IP:8080/


### 安装完成后参详http://www.heibai.info/post-74.html 第四步开始操作。
	
### 注意事项

1、执行脚本时出现下面的错误提示时该怎么办？


##程序目录：

* MySQL 安装目录: /usr/local/mysql
* MySQL 数据库目录：/usr/local/mysql/data（默认路径，安装时可更改）
* jdk 安装目录: /usr/local/jdk
* Apache 安装目录： /usr/local/apache
* Svn 安装目录: /usr/local/svn
* Tomcat 安装目录 /usr/local/tomcat_svn

##命令一览：
* MySQL  命令: 

        /etc/init.d/mysqld(start|stop|restart|status)

* Apache 命令: 

        /usr/local/apache/bin/apachectl -k  (start|stop|restart|status)

* Tomcat 命令
		/usr/local/tomcat_svn/bin/start.sh (shutdown.sh)



如果你在安装后使用遇到问题，请访问 [http://www.heibai.info/svn.html) 

