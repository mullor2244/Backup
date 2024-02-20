#!/bin/sh
user=tcsdata
group=tcsdata
dirname=/TaxControlService
work_path=$(dirname $(readlink -f $0))
echo ${work_path}
java=$JAVA_HOME
jre=$JRE_HOME
#判断环境变量JAVA_HOME和JRE_HOME是不配置好了
if [ ! -n "$java" ]; then
    echo "The JAVA_HOME environment variable is incorrectly configured"
    exit
fi
if [ ! -n "$jre" ]; then
    echo "The JRE_HOME environment variable is incorrectly configured"
    exit
fi
#查看mysql是否安装，如果安装了删除
pidlist=`ps -ef |grep tcs_mysql |grep -v "grep"|awk '{print $2}'` 
sudo kill -9 $pidlist
pidlist1=`ps -ef |grep tcs_data |grep -v "grep"|awk '{print $2}'` 
sudo kill -9 $pidlist1
tcstomcatlist=`ps -ef |grep tcs_tomcat |grep -v "grep"|awk '{print $2}'` 
sudo kill -9 $tcstomcatlist
tcsupdatelist=`ps -ef |grep tcs_update_tomcat |grep -v "grep"|awk '{print $2}'` 
sudo kill -9 $tcsupdatelist

#删除mysql相关文件
sudo find / -name tcs_mysql | sudo xargs rm -rf 
sudo find / -name tcs_data | sudo xargs rm -rf 
sudo rm -rf /tmp/mysql*
sudo update-rc.d -f tcs_mysql remove
sudo update-rc.d -f tcs_data remove
sudo update-rc.d -f tcs_tomcat remove
sudo update-rc.d -f tcs_update_tomcat remove
#判断用户和分组
egrep "^$group" /etc/group >& /dev/null
if [ $? -ne 0 ]
then
	echo "Add group"
    groupadd $group
fi
#判断用户是否存在，不存在创建
egrep "^$user" /etc/passwd >& /dev/null
if [ $? -ne 0 ]
then
	echo "Add user to group"
    useradd -r -g $group $user
fi
echo "Determine the path: $dirname exists"
if [ ! -d $dirname  ];then
  mkdir $dirname
else
  echo dir exist
fi
echo "Start installing tcs_data"
echo "Start to unzip"
cd ${work_path}
sudo tar -zxf tcs_data.tar.gz
echo "Start moving tcs_data to TaxControlService/"
sudo cp -r tcs_data /TaxControlService/
echo "tcs_data move complete"
echo "Authorize"
sudo chown -R tcsdata:tcsdata /TaxControlService/tcs_data
chmod -R 777 /TaxControlService/tcs_data/
chmod 644 /TaxControlService/tcs_data/my.cnf
sudo cp -a /TaxControlService/tcs_data/support-files/mysql.server /etc/init.d/tcs_data
chmod 777 /etc/init.d/tcs_data
echo "Delete the default /etc/my.cnf"
sudo rm -rf /etc/my.cnf
echo "Initialize and start tcs_data"
sudo mkdir -p /var/run/mysqld
sudo chown tcsdata:tcsdata /var/run/mysqld
#sudo /TaxControlService/tcs_data/bin/mysqld_safe --user=tcsdata --skip-grant-tables --basedir=/TaxControlService/tcs_data/ --datadir=/TaxControlService/tcs_data/data/ &
chmod -R 777 /TaxControlService/tcs_data/
chmod 644 /TaxControlService/tcs_data/my.cnf
sudo /etc/init.d/tcs_data start
echo "Set tcs_data boot"
#sudo chkconfig --level 35 tcs_data on
#sudo update-rc.d tcs_data defaults
sudo cp /etc/init.d/tcs_data /etc/rc0.d/K01tcs_data
sudo cp /etc/init.d/tcs_data /etc/rc1.d/K01tcs_data
sudo cp /etc/init.d/tcs_data /etc/rc2.d/S01tcs_data
sudo cp /etc/init.d/tcs_data /etc/rc3.d/S01tcs_data
sudo cp /etc/init.d/tcs_data /etc/rc4.d/S01tcs_data
sudo cp /etc/init.d/tcs_data /etc/rc5.d/S01tcs_data
sudo cp /etc/init.d/tcs_data /etc/rc6.d/K01tcs_data
cd ${work_path}
echo "Start to unzip tcs_tomcat.tar.gz"
sudo tar -zxvf tcs_tomcat.tar.gz
echo "Start moving tcs_tomcat to /TaxControlService/"
sudo cp -r tcs_tomcat /TaxControlService/
echo "The tcs_tomcat startup script is copied to /etc/init.d/tcs_tomcat"
sudo cp -a tcs_tomcat.sh /etc/init.d/tcs_tomcat
echo "/etc/init.d/tcs_tomcat authorization"
sudo chmod 777 /etc/init.d/tcs_tomcat 
sed -i "s|tcs_java|$java|" /TaxControlService/tcs_tomcat/bin/setclasspath.sh
sed -i "s|tcs_jre|$jre|" /TaxControlService/tcs_tomcat/bin/setclasspath.sh
#sed -i "s|tcs_java|"$java"|" /TaxControlService/tcs_tomcat/bin/setclasspath.sh
#sed -i "s|tcs_jre|"$jre"|" /TaxControlService/tcs_tomcat/bin/setclasspath.sh
echo "Start tcs_tomcat"
sudo chmod 777 /TaxControlService/tcs_tomcat/bin/*.sh
sudo /TaxControlService/tcs_tomcat/bin/startup.sh
echo "Tcs_tomcat is set to start automatically at boot"
#sudo chkconfig --add tcs_tomcat
#sudo update-rc.d tcs_tomcat defaults
sudo cp /etc/init.d/tcs_tomcat /etc/rc0.d/K01tcs_tomcat
sudo cp /etc/init.d/tcs_tomcat /etc/rc1.d/K01tcs_tomcat
sudo cp /etc/init.d/tcs_tomcat /etc/rc2.d/S01tcs_tomcat
sudo cp /etc/init.d/tcs_tomcat /etc/rc3.d/S01tcs_tomcat
sudo cp /etc/init.d/tcs_tomcat /etc/rc4.d/S01tcs_tomcat
sudo cp /etc/init.d/tcs_tomcat /etc/rc5.d/S01tcs_tomcat
sudo cp /etc/init.d/tcs_tomcat /etc/rc6.d/K01tcs_tomcat
echo "Start to unzip tcs_update_tomcat.tar.gz"
sudo tar -zxvf tcs_update_tomcat.tar.gz
echo "Start moving tcs_update_tomcat to /TaxControlService/"
sudo cp -r tcs_update_tomcat /TaxControlService/
echo "The tcs_update_tomcat startup script is copied to /etc/init.d/tcs_update_tomcat"
sudo cp -a tcs_update_tomcat.sh /etc/init.d/tcs_update_tomcat
sudo chmod +x /etc/init.d/tcs_update_tomcat 
#sed -i "s|tcs_java|"$java"|" /TaxControlService/tcs_update_tomcat/bin/setclasspath.sh
#sed -i "s|tcs_jre|"$jre"|" /TaxControlService/tcs_update_tomcat/bin/setclasspath.sh
sed -i "s|tcs_java|$java|" /TaxControlService/tcs_tomcat/bin/setclasspath.sh
sed -i "s|tcs_jre|$jre|" /TaxControlService/tcs_tomcat/bin/setclasspath.sh

#sed -i "s!tcs_java!"$java"!g" /TaxControlService/tcs_update_tomcat/bin/setclasspath.sh
#sed -i "s!tcs_jre!"$jre"!g" /TaxControlService/tcs_update_tomcat/bin/setclasspath.sh
echo "Start tcs_update_tomcat"
sudo chmod 777 /TaxControlService/tcs_update_tomcat/bin/*.sh
sudo /TaxControlService/tcs_update_tomcat/bin/startup.sh 
echo "tcs_update_tomcat is set to start automatically at boot"
#sudo chkconfig --add tcs_update_tomcat
#sudo update-rc.d tcs_update_tomcat defaults
sudo cp /etc/init.d/tcs_update_tomcat /etc/rc0.d/K01tcs_update_tomcat
sudo cp /etc/init.d/tcs_update_tomcat /etc/rc1.d/K01tcs_update_tomcat
sudo cp /etc/init.d/tcs_update_tomcat /etc/rc2.d/S01tcs_update_tomcat
sudo cp /etc/init.d/tcs_update_tomcat /etc/rc3.d/S01tcs_update_tomcat
sudo cp /etc/init.d/tcs_update_tomcat /etc/rc4.d/S01tcs_update_tomcat
sudo cp /etc/init.d/tcs_update_tomcat /etc/rc5.d/S01tcs_update_tomcat
sudo cp /etc/init.d/tcs_update_tomcat /etc/rc6.d/K01tcs_update_tomcat
echo "Start moving tcs_uninstall.sh to /TaxControlService/"
sudo cp -a tcs_uninstall.sh /TaxControlService/tcs_uninstall.sh
sudo chmod 777 /TaxControlService/tcs_uninstall.sh
echo "Remove the installation package" 
sudo rm -rf ${work_path}
#sudo find / -name TaxControlService.tar.gz | sudo xargs rm -rf
