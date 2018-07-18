# kubernetes即k8s集群

## 1. 示例项目

> 功能: 实时发送及显示消息, 消息会延迟两秒显示

### 1.1 聊天室actioncable 和 sidekiq

Aaron教程: dmxs_websocket 之 actioncable 入门 (七)_聊天室

### 1.2 redis 和 sidetiq

## 2. docker-compose: 验证dockerfile是否跑通

参考日本教程第二章: https://chopschips.net/blog/2018/05/30/docker-compose-with-rails/

### 2.1 修改的文档总共有:

```
Dockerfile
docker-compose.yml
	./bin/setup-db-start-puma
	./bin/start-sidekiq
 	./bin/wait-for
yarn.lock
lib/tasks/db.rake
.dockerenv/rails
.dockerenv/mysql
config/database.yml
config/cable.yml
config/credentials.yml.enc
```

### 2.2 用到的命令:

```
# 修改配置后，重新开启容器
docker-compose up -d --build --force-recreate

# 查看容器日志
docker-compose logs -f puma
docker-compose -f docker-compose-preview.yml logs -f

# 获取容器列表
docker-compose ps

# 开启web页面
open http://localhost:3000/
```

## 3. k8s 配置文件: 用已验证的 dockerfile 改写

## 4. ansible 一键部署