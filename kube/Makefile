SHELL = /bin/bash

export NAMESPACE   := xincheng
export DOMAIN_NAME := xincheng.today

ifeq ($(TAG),)
	tag := 1.0.0
else
	tag := $(TAG)
endif

test:
	$(MAKE) kubectl-namaspace
	$(MAKE) kubectl-docker-build
	$(MAKE) kubectl-apply-test
	$(MAKE) kubectl-rollout-status

all:
	$(MAKE) kubectl-namaspace
	$(MAKE) kubectl-docker-build
	$(MAKE) kubectl-apply
	$(MAKE) kubectl-rollout-status

clean: kubectl-delete
	rm -f server.pem server.key

update:
	$(MAKE) TAG=$(tag) kubectl-docker-build
	$(MAKE) TAG=$(tag) deploy

kubectl-docker-build:
	if [ "$$(docker image ls -q k8s_ansible/web:$(tag))" == "" ]; then \
		docker build ../ -t k8s_ansible/web:$(tag); \
	fi

kubectl-namaspace:
	if [ "$$(kubectl get namespaces | grep $(NAMESPACE))" == "" ]; then \
		kubectl create namespace $(NAMESPACE); \
	fi

kubectl-apply-test:
	cat configmaps/*.yaml  | kubectl -n $(NAMESPACE) apply -f -
	cat secrets/*.yaml     | kubectl -n $(NAMESPACE) apply -f -
	cat jobs/*.yaml        | kubectl -n $(NAMESPACE) apply -f -
	cat deploy.test/*.yaml | kubectl -n $(NAMESPACE) apply -f -
	cat services/*.yaml    | kubectl -n $(NAMESPACE) apply -f -
	cat storages/*.yaml    | kubectl -n $(NAMESPACE) apply -f - --validate=false
	cat volumes/*.yaml     | kubectl -n $(NAMESPACE) apply -f -
	cat ingresses/*.yaml   | kubectl -n $(NAMESPACE) apply -f -

kubectl-apply:
	cat configmaps/*.yaml  | kubectl -n $(NAMESPACE) apply -f -
	cat secrets/*.yaml     | kubectl -n $(NAMESPACE) apply -f -
	cat jobs/*.yaml        | kubectl -n $(NAMESPACE) apply -f -
	cat deployments/*.yaml | kubectl -n $(NAMESPACE) apply -f -
	cat services/*.yaml    | kubectl -n $(NAMESPACE) apply -f -
	cat storages/*.yaml    | kubectl -n $(NAMESPACE) apply -f - --validate=false
	cat volumes/*.yaml     | kubectl -n $(NAMESPACE) apply -f -
	cat ingresses/*.yaml   | kubectl -n $(NAMESPACE) apply -f -

kubectl-rollout-status:
	kubectl -n $(NAMESPACE) rollout status deploy k8s-ansible-puma
	kubectl -n $(NAMESPACE) rollout status deploy k8s-ansible-sidekiq

kubectl-service:
	kubectl -n $(NAMESPACE) get service k8s-ansible-puma

kubectl-delete:
	cat secrets/*.yaml     | kubectl -n $(NAMESPACE) delete -f - --ignore-not-found
	cat configmaps/*.yaml  | kubectl -n $(NAMESPACE) delete -f - --ignore-not-found
	cat jobs/*.yaml        | kubectl -n $(NAMESPACE) delete -f - --ignore-not-found
	cat deployments/*.yaml | kubectl -n $(NAMESPACE) delete -f - --ignore-not-found
	cat deploy.test/*.yaml | kubectl -n $(NAMESPACE) delete -f - --ignore-not-found
	cat services/*.yaml    | kubectl -n $(NAMESPACE) delete -f - --ignore-not-found
	cat storages/*.yaml    | kubectl -n $(NAMESPACE) delete -f - --ignore-not-found
	cat volumes/*.yaml     | kubectl -n $(NAMESPACE) delete -f - --ignore-not-found
	cat ingresses/*.yaml   | kubectl -n $(NAMESPACE) delete -f - --ignore-not-found
	# kubectl delete namespaces $(NAMESPACE) --ignore-not-found

deploy:
	kubectl -n $(NAMESPACE) set image deploy/k8s-ansible-puma puma=k8s_ansible/web:$(tag)
	kubectl -n $(NAMESPACE) set image deploy/k8s-ansible-sidekiq sidekiq=k8s_ansible/web:$(tag)
	kubectl -n $(NAMESPACE) rollout status deploy k8s-ansible-puma
	kubectl -n $(NAMESPACE) rollout status deploy k8s-ansible-sidekiq

setup-ingress-nginx:
	kubectl -n $(NAMESPACE) apply  -f nginx/ingress-controller.yaml

delete-ingress-nginx:
	kubectl -n $(NAMESPACE) delete -f nginx/ingress-controller.yaml --ignore-not-found

stern:
	stern k8s-ansible.*