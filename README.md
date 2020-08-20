# HomeWork_4_NFS_FUSE
ДЗ_NFS_FUSE

**Из репозитория к Домашнему заданию берем Vagrantfile и дорабатываем его под свои нужды**
```
# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "centos/7"

#  config.vm.provision "ansible" do |ansible|
#    ansible.verbose = "vvv"
#    ansible.playbook = "playbook.yml"
#    ansible.become = "true"
#  end

  config.vm.provider "virtualbox" do |v|
    v.memory = 256
    v.cpus = 1
  end

  config.vm.define "nfss" do |nfss|
    nfss.vm.network "private_network", ip: "192.168.180.10", virtualbox__intnet: "net1"
    nfss.vm.hostname = "server"
    nfss.vm.provision "shell", path: "Server.sh"
  end

  config.vm.define "nfsc" do |nfsc|
    nfsc.vm.network "private_network", ip: "192.168.180.11", virtualbox__intnet: "net1"
    nfsc.vm.hostname = "client"
    nfsc.vm.provision "shell", path: "Client.sh"
  end

end
```
**Создаем скрипты, которые будут устанавливать нужные пакеты и выполнять команды**

**"Server.sh"- для серверной машины**

*Обновим систему*
```
sudo yum -y update
```

*Установим текстовый редактор NANO*
```
sudo yum -y install nano
```

*Создадим директорию nfs_Share в директории home
и дадим на неё полные права*
```
sudo mkdir -p /home/nfs_Share
sudo chmod -R 777 /home/nfs_Share
```

*В файловом редакторе NANO создадим файл Proverka.txt*
```
sudo touch /home/nfs_Share/Proverka.txt
```

*Остановим Security-Enhanced Linux (SELinux) - это метод контроля доступа в Linux на основе модуля ядра Linux Security (LSM)*
```
sudo setenforce 0
```

*Установим NFS*
```
sudo yum -y install nfs-utils nfs-utils-lib
```

*Включим службы*
```
sudo systemctl enable rpcbind
sudo systemctl enable nfs-server
sudo  systemctl enable nfs-lock
sudo systemctl enable nfs-idmap
sudo systemctl start rpcbind
sudo systemctl start nfs-server
sudo systemctl start nfs-lock
sudo systemctl start nfs-idmap
```

*Добавляем в файл «/etc/exports’ информацию о предоставляемой шаре через NFS и перечитаем его и перезапустим NFS*
```
echo "/home/nfs_Share 192.168.180.0/24(rw,sync,no_root_squash,no_all_squash)" >> /etc/exports
sudo exportfs -a
sudo systemctl restart nfs-server
```

*Стартуем файервол и добавляем (открываем) порты NFS сервера в брандмауэре (firewalld) для корректной работы в сети*
```
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

```
*Стартуем Security-Enhanced Linux (SELinux) - это метод контроля доступа в Linux на основе модуля ядра Linux Security (LSM)*
```
sudo selinuxenabled 1
```

*Включим поддержку вывода Escape последовательностей*
```
echo -e
```


**"Client.sh"- для клиентской машины**

*Обновим систему*
```
sudo yum -y update
```

*Установим текстовый редактор NANO*
```
sudo yum -y install nano
```

*Создаем каталог, куда будем монтировать шару*
```
sudo mkdir -p /media/nfs_Open_share
```

*Установим NFS*
```
sudo yum -y install nfs-utils nfs-utils-lib
```

*Включим службы*
```
sudo systemctl enable rpcbind
sudo systemctl enable nfs-server
sudo  systemctl enable nfs-lock
sudo systemctl enable nfs-idmap
sudo systemctl start rpcbind
sudo systemctl start nfs-server
sudo systemctl start nfs-lock
sudo systemctl start nfs-idmap
```

*Смонтируем шару*
```
sudo mount -t nfs 192.168.180.10:/home/nfs_Share/ /media/nfs_Open_share/
echo "192.168.180.11:/home/nfs_Share/ /media/nfs_Open_share/ nfs rw,sync,hard,intr 0 0"
```
**После этого запускаем Vagrant**
```
C:\Vagrant\DZ_4>vagrant up
```

*Дожидаемся установки виртуальных машин и отработки скриптов*

*Подключаемся к серверной машине и проверяем начилие файла Proverka.txt*
```
C:\Vagrant\DZ_4>vagrant ssh nfss
[vagrant@server ~]$ cd /home
[vagrant@server home]$ ls -al
total 0
drwxr-xr-x.  4 root    root     38 Aug 20 07:28 .
dr-xr-xr-x. 18 root    root    255 Aug 20 07:26 ..
drwxrwxrwx.  2 root    root     26 Aug 20 07:28 nfs_Share
drwx------.  3 vagrant vagrant  74 Apr 30 22:09 vagrant
[vagrant@server home]$ cd nfs_Share
[vagrant@server nfs_Share]$ ls -al
total 4
drwxrwxrwx. 2 root root 26 Aug 20 07:28 .
drwxr-xr-x. 4 root root 38 Aug 20 07:28 ..
-rw-r--r--. 1 root root 15 Aug 20 07:33 Proverka.txt
```

*Подключаемся к клиентской машине и также проверяем начилие файла Proverka.txt*
```
C:\Vagrant\DZ_4>vagrant ssh nfsc
[vagrant@client ~]$ cd /media
[vagrant@client media]$ ls -al
total 0
drwxr-xr-x.  3 root root  28 Aug 20 07:30 .
dr-xr-xr-x. 18 root root 255 Aug 20 07:28 ..
drwxrwxrwx.  2 root root  26 Aug 20 07:28 nfs_Open_share
[vagrant@client media]$ cd nfs_Open_share
[vagrant@client nfs_Open_share]$ ls -al
total 0
drwxrwxrwx. 2 root root 26 Aug 20 07:28 .
drwxr-xr-x. 3 root root 28 Aug 20 07:30 ..
-rw-r--r--. 1 root root  0 Aug 20 07:28 Proverka.txt
```
*Меняем содержание файла Proverka.txt с помощью редактора NANO*
```
[vagrant@client nfs_Open_share]$ sudo nano Proverka.txt
```
*На серверной машине убеждаемся, что изменения в файле прошли*
```
[vagrant@server nfs_Share]$ sudo nano Proverka.txt
```

**В данной работе, я использовал следующие ресурсы:**

https://tokmakov.msk.ru/blog/item/435
https://tokmakov.msk.ru/blog/item/479
https://oddstyle.ru/wordpress-2/stati-wordpress/polnocennoe-rukovodstvo-po-ispolzovaniyu-vagrant-dlya-ustanovki-testovoj-sredy-wordpress.html
https://ovchinnikov.cc/writing/vagrant-multi-vm/
https://losst.ru/nastrojka-firewall-centos-7
https://www.gotoadm.ru/centos-nfs-server-install/
https://losst.ru
https://kubuntu.ru/node/3046

