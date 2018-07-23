# kubernetes即k8s集群

## 1. 示例项目

> 功能: 实时发送及显示消息, 消息会延迟两秒显示

![](https://ws4.sinaimg.cn/large/006tKfTcgy1ftggt8bdsog30fn09umxx.gif)

### 1.1 聊天室actioncable 和 sidekiq

Aaron教程: dmxs_websocket 之 actioncable 入门 (七)_聊天室

### 1.2 redis 和 sidetiq



## 2. docker-compose: 验证dockerfile是否跑通

### 2.0 开始前的准备

1) 复制云豹项目的 .env、Dockerfile、.ignore、.dockerignore、docker-compose.yml、yarn.lock 文件用于 docker-compose 改造

2) 复制云豹项目的 kube 文件夹用于 k8s 改造

3) mac上开启 docker-edge 版本后,要把 kubenetes 选项改为 docker-for-desktop 而不是按教程用 minikube。这样会更接近生产环境。

4) mac 关闭 mysql 服务

![](https://ws2.sinaimg.cn/large/006tKfTcgy1ftg4zu28v0j30br0a8dg3.jpg)


参考日本教程第二章: https://chopschips.net/blog/2018/05/30/docker-compose-with-rails/

### 2.1 日本教程修改的文档总共有:

```
Dockerfile
docker-compose.yml
	./bin/setup-db-start-puma
	./bin/start-sidekiq
 	./bin/wait-for
yarn.lock
lib/tasks/db.rake
.dockerenv/railsw
.dockerenv/mysql
config/database.yml
config/cable.yml
config/credentials.yml.enc
```

### 2.2 用到的命令:

1) 生成 master.key
```sh
# 确保重新生成
$ rm config/master.key config/credentials.yml.enc

# 重新生成 config/master.key
$ EDITOR=vim rails credentials:edit

# 加密
$ echo -n "master_key" | base64
```

2) 开启容器
```
# 修改配置后，重新开启容器
docker-compose up -d --build --force-recreate

# 查看容器日志
docker-compose logs -f puma
docker-compose -f docker-compose.yml logs -f

# 获取容器列表
docker-compose ps

# 开启web页面
open http://localhost:3000/
```

### 2.3 报错 error:

1) mysql、sidekiq(redis)、puma 报错logs: rails aborted! ActiveSupport::MessageEncryptor::InvalidMessage: ActiveSupport::MessageEncryptor::InvalidMessage

* 关闭 mac 的 mysql 服务

* name@host.com问题, 删除 /app/tmp/mysql, 然后重新开启容器,否则会一直沿用旧配置,会一致报错。

* Dockerfile 里的 RAILS_MASTER_KEY 不要加密成 base64； /kube/secrets/rails_env_secret.yaml 里的 RAILS_MASTER_KEY 才要加密成 base64；

2) mysql、sidekiq(redis)、puma 环境变量问题: 

* 修改 .env 文件内的环境变量, 然后重新开启容器

3) port is already allocated

* 端口被占用,重启 mac,并关闭 mac 的 mysql 服务

4) ERROR: for amz-erp-puma  Cannot start service amz-erp-puma: OCI runtime create failed: container_linux.go:348: starting container process caused "exec: \"./kube/bin/setup-db-and-start-puma\": stat ./kube/bin/setup-db-and-start-puma: no such file or directory": unknown
   ERROR: for amz-erp-puma  Cannot start service amz-erp-puma: OCI runtime create failed: container_linux.go:348: starting container process caused "exec: \"./kube/bin/setup-db-and-start-puma\": stat ./kube/bin/setup-db-and-start-puma: no such file or directory": unknown
   ERROR: Encountered errors while bringing up the project.

* 解决办法：把 .dockerignore 里的 /kube/* 去掉，否则开启容器是找不到这个文件夹的

5） docker-compose logs -f amz-erp-sidekiq：Error connecting to Redis on 127.0.0.1:6379 (Errno::ECONNREFUSED)

* .env 的配置没问题，但 config/initializers/sidekiq.rb 的 redis_url 没有引用 ENV['REDIS_URL']



## 3. k8s 两种api对象入手(deployment 和 service): 用已验证的 docker-compose 改写

参考日本教程第三章: https://chopschips.net/blog/2018/05/30/kubernetes-tutorial/

### 3.1 日本教程修改的文档总共有:

```
k8s/manifests-step0/mysql-deploy.yaml
k8s/manifests-step0/mysql-svc.yaml
```

### 3.2 用到的命令:

1) kubectl的使用

```
# 安装操作k8s集群的CLI工具
brew install kubernetes-cli

# 创建和更新一个api
kubectl apply -f kube/deployments/mysql_deploy.yaml
kubectl apply -f kube/services/mysql_svc.yaml

# 检查对象的状态
kubectl get deployments,replicaset,pods,services

# 检查容器日志
kubectl logs deployments/mysql
kubectl logs pods/k8s-ansible-mysql-69b46f9cdc-sv2b4
```

2) kubernetes web ui 安装

```
# 创建仪表板UI
kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml

# 运行仪表板server
kubectl proxy

# 访问仪表板UI,打开左侧Overview(看到 Deployment、Pods、Relica Sets、Services 都新增了刚刚配置的api对象)
http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/
```

3) 效果如下图: 每个模块各新增了两个api对象

![](https://ws4.sinaimg.cn/large/006tNc79gy1ftfgia9aa5j31g40qo771.jpg)



## 4.k8s 四种api对象(deployment、service、configmap、secret)

参考日本教程第四章: https://chopschips.net/blog/2018/05/30/kubernetes-with-rails/#mysql-env-secret-yaml-mysql%E3%81%AE%E7%92%B0%E5%A2%83%E5%A4%89%E6%95%B0%E7%94%A8Secret

### 4.1 日本教程修改的文档总共有:

```
k8s/manifests-step1/mysql-deploy.yaml
k8s/manifests-step1/redis-deploy.yaml
k8s/manifests-step1/puma-deploy.yaml
k8s/manifests-step1/sidekiq-deploy.yaml

k8s/manifests-step1/mysql-svc.yaml
k8s/manifests-step1/redis-svc.yaml
k8s/manifests-step1/puma-svc.yaml

k8s/manifests-step1/mysql-env-cm.yaml
k8s/manifests-step1/rails-env-cm.yaml

k8s/manifests-step1/mysql-env-secret.yaml
k8s/manifests-step1/rails-env-secret.yaml

k8s/manifests-step1/Makefile
lib/tasks/sidekiq.rake
```

### 4.2 用到的命令:

1) 逐个命令测试

```
# 创建 api
cd kube
cat configmaps/*.yaml | kubectl apply -f -
cat secrets/*.yaml | kubectl apply -f -
cat deployments/*.yaml | kubectl apply -f -
cat services/*.yaml | kubectl apply -f -

# 按3.2的步骤，查看k8s web ui，打开左侧 Overview 看到 Deployment、Pods、Relica Sets、Services 各新增了四个api对象

# 查看状态
kubectl rollout status deploy demoapp-puma
```

2) 制作 Makefile

```
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

# 本地环境一键部署
$ make test

# 一键清除
$ make clean

# 删除命名空间
$ kubectl delete namespaces xxxx --ignore-not-found
```

3) 效果如下图: 每个模块各新增四个api对象

![](https://ws3.sinaimg.cn/large/006tNc79gy1ftfgerpbjnj31kw0t5abh.jpg)

## 5.k8s 四种进阶 api 对象(job、pv、pvc、ingress)

参考日本教程第五章: https://chopschips.net/blog/2018/05/30/practical-kubernetes-with-rails/

### 5.1 日本教程修改的文档总共有:

```
lib/tasks/db.rake
./bin/start-puma
./bin/setup-db

# 新增job的api，用Makefile滚动更新
k8s/manifests-step2/Makefile
k8s/manifests-step2/setup-db-job.yaml

# pvc对象
k8s/manifests-step2/Makefile
k8s/manifests-step3/mysql-pvc.yaml
k8s/manifests-step3/redis-pvc.yaml
k8s/manifests-step3/mysql-deploy.yaml
k8s/manifests-step3/redis-deploy.yaml

# ingress对象
k8s/manifests-step2/Makefile
k8s/manifests-step4/openssl.conf
k8s/manifests-step4/puma-ing.yml
```

### 5.2 用到的命令:

1) job对象、滚动更新

```
# 创建 api
cat services/*.yaml | kubectl apply -f -

# 滚动更新
make update TAG=1.0.1
```

2) pv、pvc、ingress 对象

# 查看 pv 和 pvc
kubectl -n xincheng get pvc
kubectl -n xincheng get pv


### 5.3 报错 error:

1) web页面 persistentvolumeclaim "k8s-ansible-mysql" not found

![](https://ws3.sinaimg.cn/large/006tNc79gy1ftfkij03rsj31g40qo76h.jpg)

解决办法：要把 storages 和 volumes 文件夹里的 storageClassName 改成统一，比如 hostpath。

2) web页面 Back-off restarting failed container

原因：一是 docker hub 上找不到镜像，二是 secret 配置不正确。

解决办法：页面查看log，分别定位到 master_key 和 redis_host 的问题。

查看 kube/secrets/rails_env_secret.yaml，修改 master_key。

查看 kube/secrets/rails_env_secret.yaml，复制 REDIS_URL，在 app/config 搜索，看是否被使用，能搜索到 cable.yml，所以要修改配置。配置 redis 名字、密码要跟 configmap 里的一致。

> 注意:
>
> 本地测试不用配置 docker hub， 如果是线上版本，可以参考并配置 secrets 文件 https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
>
> 即使删除了 namespace, pv 持久卷仍然存在,不知道要怎么删除。


3) 完成,打开 k8s 仪表页面

![](https://ws1.sinaimg.cn/large/006tKfTcgy1ftgguvwesaj31g40qoq51.jpg)

打开项目

![](https://ws4.sinaimg.cn/large/006tKfTcgy1ftggt8bdsog30fn09umxx.gif)

## 6. ansible 一键部署