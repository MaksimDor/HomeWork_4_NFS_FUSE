sudo yum -y update
sudo yum -y install nano
sudo mkdir -p /home/nfs_Share
sudo chmod -R 777 /home/nfs_Share
sudo touch /home/nfs_Share/Proverka.txt
sudo setenforce 0
sudo yum -y install nfs-utils nfs-utils-lib
sudo systemctl enable rpcbind
sudo systemctl enable nfs-server
sudo  systemctl enable nfs-lock
sudo systemctl enable nfs-idmap
sudo systemctl start rpcbind
sudo systemctl start nfs-server
sudo systemctl start nfs-lock
sudo systemctl start nfs-idmap
echo "/home/nfs_Share 192.168.180.0/24(rw,sync,no_root_squash,no_all_squash)" >> /etc/exports
sudo exportfs -a
sudo systemctl restart nfs-server
sudo systemctl start firewalld.service
sudo firewall-cmd --permanent --add-port=111/tcp
sudo firewall-cmd --permanent --add-port=54302/tcp
sudo firewall-cmd --permanent --add-port=20048/tcp
sudo firewall-cmd --permanent --add-port=2049/tcp
sudo firewall-cmd --permanent --add-port=46666/tcp
sudo firewall-cmd --permanent --add-port=42955/tcp
sudo firewall-cmd --permanent --add-port=875/tcp
sudo firewall-cmd --permanent --zone=public --add-service=nfs
sudo firewall-cmd --permanent --zone=public --add-service=mountd
sudo firewall-cmd --permanent --zone=public --add-service=rpc-bind
sudo firewall-cmd --reload
sudo selinuxenabled 1
echo -e
