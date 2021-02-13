source ./server.conf

#ディレクトリ作成
mkdir /var/lib/libvirt/images/iso
mkdir /var/lib/libvirt/images/master
mkdir /var/lib/libvirt/images/data

#SElinux無効
sed -i "s/\(^SELINUX=\).*/\1disabled/" /etc/selinux/config

#ファイルディスクリプタ変更
echo "* soft nofile 65536" >> /etc/security/limits.conf
echo "* hard nofile 65536" >> /etc/security/limits.conf

#カーネルパラメータ変更
echo "vm.swappiness = 10" >> /etc/sysctl.conf
echo "net.core.somaxconn = 1024" >> /etc/sysctl.conf

#hostname変更
echo "$Host" > /etc/hostname

#ローカルネットワーク設定
nmcli connection modify $LocalNic ipv4.addresses "$LocalIpAddr/24" ipv4.method manual
nmcli connection modify $LocalNic ipv4.gateway "$GatewayOrDns"
nmcli connection modify $LocalNic ipv4.dns "$GatewayOrDns"
nmcli connection modify $LocalNic connection.autoconnect yes

systemctl restart network.service

sleep 5

#history設定変更
sed -i -e "s/HISTSIZE=1000/#HISTSIZE=1000/g" /etc/profile
sed -i -e "/#HISTSIZE=1000/a HISTSIZE=10000" /etc/profile
echo "HISTTIMEFORMAT='%F %T '" >> /etc/profile
echo "unset HISTCONTROL" >> /etc/profile
echo "export HISTSIZE HISTTIMEFORMAT" >> /etc/profile

#NTP
sed -i -e "s/server 0.centos.pool.ntp.org iburst/#server 0.centos.pool.ntp.org iburst/g" /etc/chrony.conf
sed -i -e "s/server 1.centos.pool.ntp.org iburst/#server 1.centos.pool.ntp.org iburst/g" /etc/chrony.conf
sed -i -e "s/server 2.centos.pool.ntp.org iburst/#server 2.centos.pool.ntp.org iburst/g" /etc/chrony.conf
sed -i -e "s/server 3.centos.pool.ntp.org iburst/#server 3.centos.pool.ntp.org iburst/g" /etc/chrony.conf
sed -i -e "/#server 3.centos.pool.ntp.org iburst/a server ntp.nict.jp iburst" /etc/chrony.conf
sed -i -e "/server ntp.nict.jp iburst/a server time.google.com iburst" /etc/chrony.conf

#不要サービスの無効化
systemctl disable abrt-ccpp.service
systemctl disable abrtd.service
systemctl disable abrt-oops.service
systemctl disable abrt-vmcore.service
systemctl disable abrt-xorg.service
systemctl disable avahi-daemon.service 
systemctl disable cups.service
systemctl disable postfix.service
systemctl disable bluetooth.service

#yumアップデート
yum update -y

sleep 5

#再起動
reboot