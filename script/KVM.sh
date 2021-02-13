source ./server.conf

#インストール
wget https://fedorapeople.org/groups/virt/virtio-win/virtio-win.repo -O /etc/yum.repos.d/virtio-win.repo
yum -y install libguestfs libvirt libvirt-client python-virtinst qemu-kvm virt-manager virt-top virt-viewer virt-who virt-install bridge-utils virtio-win ;sleep 30
systemctl enable libvirtd

sleep 5

#ブリッジ作成
echo "TYPE=Bridge" >> /etc/sysconfig/network-scripts/ifcfg-br0
echo "BOOTPROTO=static" >> /etc/sysconfig/network-scripts/ifcfg-br0
echo "DEVICE=br0" >> /etc/sysconfig/network-scripts/ifcfg-br0
echo "IPADDR=$LocalIpAddr" >> /etc/sysconfig/network-scripts/ifcfg-br0
echo "NETMASK=255.255.255.0" >> /etc/sysconfig/network-scripts/ifcfg-br0
echo "GATEWAY=$GatewayOrDns" >> /etc/sysconfig/network-scripts/ifcfg-br0
echo "DNS1=$GatewayOrDns" >> /etc/sysconfig/network-scripts/ifcfg-br0
echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-br0

#既存ネットワーク変更
cp -p /etc/sysconfig/network-scripts/ifcfg-${LocalNic} /etc/sysconfig/network-scripts/bk_ifcfg-${LocalNic}
rm -f /etc/sysconfig/network-scripts/ifcfg-${LocalNic}

echo "DEVICE=${LocalNic}" >> /etc/sysconfig/network-scripts/ifcfg-${LocalNic}
echo "ONBOOT=yes" >> /etc/sysconfig/network-scripts/ifcfg-${LocalNic}
echo "BOOTPROTO=none" >> /etc/sysconfig/network-scripts/ifcfg-${LocalNic}
echo "TYPE=ethernet" >> /etc/sysconfig/network-scripts/ifcfg-${LocalNic}
echo "BRIDGE=br0" >> /etc/sysconfig/network-scripts/ifcfg-${LocalNic}

#ブリッジ設定
echo "<network>" >> host-bridge.xml
echo "  <name>host-bridge</name>" >> host-bridge.xml
echo "  <forward mode=\"bridge\"/>" >> host-bridge.xml
echo "  <bridge name=\"br0\"/>" >> host-bridge.xml
echo "</network>" >> host-bridge.xml
virsh net-define --file host-bridge.xml
rm -f host-bridge.xml

#仮想ネットワーク定義
virsh net-autostart host-bridge
virsh net-start host-bridge

sleep 5

#ネットワーク、KVM再起動
systemctl restart network.service
systemctl restart libvirtd

sleep 5

systemctl enable libvirt-guests
systemctl start libvirt-guests

reboot