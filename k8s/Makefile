
region ?= us-east-2
zones ?= us-east-2a

cluster_name_prefix ?= andrey.kops
cluster_name ?= $(cluster_name_prefix).k8s.local
bucket_name ?= $(cluster_name_prefix).k8s.state

nodes ?= 3

master_instance_type ?=

browser:
	open -a "Google Chrome"

KOPS_STATE_STORE=s3://$(bucket_name)

create_cluster_storage:
	aws s3api create-bucket \
		--bucket $(bucket_name) \
		--region $(region) \
		--create-bucket-configuration LocationConstraint=$(region)

delete_cluster_storage:
	aws s3 rb s3://$(bucket_name) --force

create_cluster:  create_cluster_storage
	kops create cluster \
		--name=$(cluster_name) \
		--zones=$(zones) \
		--node-count=$(nodes)
	$(MAKE) update_cluster create_k8s_dashboard

update_cluster: 
	kops update cluster $(cluster_name) --yes

edit_cluster: 
	kops edit cluster $(cluster_name) --state=s3://$(bucket_name)
	$(MAKE) update_cluster

delete_cluster:
	kops delete cluster --name $(cluster_name)
	kops delete cluster --name $(cluster_name) --yes
	$(MAKE) delete_cluster_storage

validate_cluster:
	kops validate cluster --name $(cluster_name)

clusters: 
	kops get clusters

nodes:
	kubectl get nodes

start_k8s_proxy:
	kubectl proxy

create_k8s_dashboard:
	kubectl create -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
	kubectl create -f conf/dashboard-role-binding.yaml

delete_k8s_dashboard:
	kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
	kubectl delete -f conf/dashboard-role-binding.yaml

k8s:
	$(browser) http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/overview?namespace=default

start_flink:
	kubectl create -f conf/jobmanager-deployment.yaml
	kubectl create -f conf/taskmanager-deployment.yaml
	kubectl create -f conf/jobmanager-service.yaml

stop_flink:
	kubectl delete -f conf/jobmanager-deployment.yaml
	kubectl delete -f conf/jobmanager-service.yaml
	kubectl delete -f conf/taskmanager-deployment.yaml

flink:
	$(browser) http://localhost:8001/api/v1/proxy/namespaces/default/services/flink-jobmanager:8081/#/overview
