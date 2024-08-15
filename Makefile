.EXPORT_ALL_VARIABLES:

DOCKER ?= docker.io/eberkley

TOP := .

RELEASE := $(TOP)/release
SRC := $(TOP)/src
BENCH := $(TOP)/benchmark

BASE := $(RELEASE)/base
GENERATED := $(RELEASE)/generated

IMGS := $(BENCH)/imgs
STATS := $(BENCH)/stats

BASE_YAMLS := $(wildcard $(BASE)/*.yaml)
BASE_YAMLS_FNAMES := $(foreach var, $(BASE_YAMLS), $(shell basename $(var) .yaml))
GEN_YAMLS := $(foreach var, $(BASE_YAMLS_FNAMES), $(GENERATED)/$(var).yaml)

.PHONY: all minikube_start minikube_restart bench deploy stop 

all: 
	@echo valid arguments:
	@echo
	@echo	"minikube_[re]start   - [re]start minikube"
	@echo "deploy               - Starts minikube / builds new version of app if necessary, then deploys."
	@echo "bench                - Functionally equivilent to benchmark/benchmark.sh"
	@echo "stop                 - remove deployments"

minikube_start:
	@ lines=$(shell minikube status | wc -l);	\
	if [ $$lines -le 5 ]; then 								\
		echo Starting minikube;									\
		./scripts/minikube_start.sh;						\
	else 																			\
		echo Minikube already running. ;				\
	fi 

minikube_restart:
	minikube delete
	./scripts/minikube_start.sh

deploy: minikube_start $(GEN_YAMLS)
	@# ./scripts/start.sh
	kubectl apply -f $(GENERATED)/loadgenerator.yaml
	sleep 30
	for yaml in $(filter-out $(GENERATED)/loadgenerator.yaml, $(GEN_YAMLS)); do\
		kubectl apply -f $$yaml;\	
	done
	./scripts/make_scale.sh
	

bench: deploy
	./scripts/pull_stats.sh
	./scripts/stop.sh

stop:
	./scripts/stop.sh
	minikube delete

# Will work if yaml file is newer, but will needlessly push to docker.
# 	I'm not sure why, but this doesn't work with $(wildcard $(SRC)/%/*)
$(GENERATED)/%.yaml: $(SRC)/%/* $(BASE)/%.yaml
	cp $(BASE)/$*.yaml $@
	./scripts/push.sh $* $@

$(GENERATED)/redis.yaml: $(BASE)/redis.yaml
	cp $^ $@