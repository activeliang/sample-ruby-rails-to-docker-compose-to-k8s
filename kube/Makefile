SHELL = /bin/bash

export NAMESPACE   := yunbao-staging
export DOMAIN_NAME := yunbao.muker.io

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
	if [ "$$(docker image ls -q amz_selenium/web:$(tag))" == "" ]; then \
		docker build ../ -t amz_selenium/web:$(tag); \
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
	kubectl -n $(NAMESPACE) rollout status deploy amz-selenium-web-puma
	kubectl -n $(NAMESPACE) rollout status deploy amz-selenium-web-sidekiq

kubectl-service:
	kubectl -n $(NAMESPACE) get service amz-selenium-web-puma

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
	kubectl -n $(NAMESPACE) set image deploy/amz-selenium-web-puma puma=amz_selenium/web:$(tag)
	kubectl -n $(NAMESPACE) set image deploy/amz-selenium-web-sidekiq sidekiq=amz_selenium/web:$(tag)
	kubectl -n $(NAMESPACE) rollout status deploy amz-selenium-web-puma
	kubectl -n $(NAMESPACE) rollout status deploy amz-selenium-web-sidekiq

setup-ingress-nginx:
	kubectl -n $(NAMESPACE) apply  -f nginx/ingress-controller.yaml

delete-ingress-nginx:
	kubectl -n $(NAMESPACE) delete -f nginx/ingress-controller.yaml --ignore-not-found

stern:
	stern amz-selenium-web.*
