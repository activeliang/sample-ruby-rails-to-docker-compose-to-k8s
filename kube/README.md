## 部署前准备工作

生成credentials
```sh
# 确保重新生成
$ rm config/master.key config/credentials.yml.enc

# 重新生成 master.key/credentials
$ EDITOR=vim rails credentials:edit

# 查看master.key
$ cat config/master.key
```

需要配置`*.example`文件

```sh
$ cp .env.example .env
$ cp kube/secrets/mysql_env_secret.yaml.example kube/secrets/mysql_env_secret.yaml
$ cp kube/secrets/rails_env_secret.yaml.example kube/secrets/rails_env_secret.yaml

# 把 master.key 里信息添加到上面文件的 RAILS_MASTER_KEY 里
# PS: secret 文件需要base64加密
```

## Rails on Docker
=========

利用`docker-compose`快速容器化

```sh
# 创建镜像
$ docekr-compose build

# 启动(`-d`表示后台启动)
$ docker-compose up -d

# 查看log
$ docker-compose logs -f amz-selenium-web-puma

# 删除(`-v`表示同时删除挂载的卷)
$ docker-compose down -v
```

## Rails on Kubernetes
=========

使用到的 `API objects`:

* Deployment
* Service
* ConfigMap
* Secret
* Job
* PersistentVolumeClaim
* Ingress

## 部署

利用 [Makefile](Makefile) 可以用短命令操作`kubectl`.

```sh
# 先进入 `kube` 目录
$ cd kube

# 创建命令空间
$ make kubectl-namaspace

# 应用配置好的k8s的yaml部署文件
$ make kubectl-apply

# 查看部署状态
$ make kubectl-rollout-status

# 删除所有部署配置
$ make kubectl-delete
```
```sh
# 本地环境一键部署
$ make test

# 一键部署
$ make all
```

## 更新

```sh
# build新的`image`镜像 
$ make kubectl-docker-build TAG=1.0.2

# 用新镜像更新部署
$ make deploy TAG=1.0.2 
```

```sh
# 一键更新
$ make update TAG=1.0.2
```

## Rails Console

```sh
# 获取运行中的puma的pod
$ kubectl -n yunbao-staging get pods | grep puma
amz-selenium-web-puma-74bdbbddb9-kw84b      1/1       Running   6          1h

# 进入运行中的容器
$ kubectl -n yunbao-staging exec -it  amz-selenium-web-puma-74bdbbddb9-kw84b -- bash

# 进入Rails控制台
$ bin/rails c
```


## 存储卷: HostPath

[HostPath](https://kubernetes.io/cn/docs/tutorials/stateful-application/mysql-wordpress-persistent-volume/#host-path) 是映射到主机上目录的卷。这种类型应该只用于测试目的或者单节点集群。如果 pod 在一个新的节点上重建，数据将不会在节点之间移动。如果 pod 被删除并在一个新的节点上重建，数据将会丢失。

* SELinux
在支持 selinux 的系统上，保持它为 enabled/enforcing 是最佳选择。然而，docker 容器使用 “_svirt_sandbox_filet” 标签类型挂载 host path，这和默认的 /tmp (”_tmpt”) 标签类型不兼容。在 mysql 容器试图对 /var/lib/mysql 执行 chown 时将导致权限错误。 因此，要在一个启用 selinx 的系统上使用 host path，你应该预先创建 host path 路径（/tmp/data/）并将它的 selinux 标签类型改变为 “_svirt_sandbox_filet“，就像下面一样：

```
## on every node:
mkdir -p /tmp/data
chmod a+rwt /tmp/data  # match /tmp permissions
chcon -Rt svirt_sandbox_file_t /tmp/data
```