ENV_FILE := .env
include ${ENV_FILE}
export $(shell sed 's/=.*//' ${ENV_FILE})
export PIPENV_DOTENV_LOCATION=${ENV_FILE}

oc_build_head:
	git archive --format=tar.gz HEAD > build/HEAD.tar.gz
        oc start-build systems-clustering --from-archive build/HEAD.tar.gz --follow

test:
     	pipenv run pytest

oc_mlflow_job:
	oc new-app mlflow-experiment-job --param APP_IMAGE_URI=hemas-local-test-2\
                --param LIMIT_CPU=4 \
                --param LIMIT_MEM=16G \
                --env DAY_1=${DAY_1} \
		--env DAY_2=${DAY_2} \
                --env CEPH_KEY=${CEPH_KEY} \
                --env CEPH_SECRET=${CEPH_SECRET} \
                --env CEPH_ENDPOINT=${CEPH_ENDPOINT} \
                --env CEPH_BUCKET=${CEPH_BUCKET} \
		--env PCA_DIMENSIONS=${PCA_COMPONENTS} \
		--env K_CLUSTERS=${K_CLUSTERS} \
		--env MLFLOW_EXPERIMENT_NAME=${MLFLOW_EXPERIMENT_NAME} \
		--env MLFLOW_TRACKING_URI=${MLFLOW_TRACKING_URI}
