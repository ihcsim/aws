.PHONY: images/build images/api-server/build images/games-agent/build images/push images/api-server/push images/games-agent/push load-test/tool load-test/network

TEST_DURATION ?= 5s
AWS_QUEUE_NAME ?= isim-ao-training-games-payload

VERSION_API_SERVER = 0.0.1
VERSION_GAMES_AGENT = 0.0.1

images/build: images/api-server/build images/games-agent/build
images/push: images/api-server/push images/games-agent/push

images/api-server/build:
	docker image build --rm -t isim-ao-training/api-server:$(VERSION_API_SERVER) \
		-f apps/api-server/Dockerfile \
		--build-arg VERSION=$(VERSION_API_SERVER) \
		--build-arg AWS_QUEUE_NAME=$(AWS_QUEUE_NAME) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		.

images/games-agent/build:
	docker image build --rm -t isim-ao-training/games-agent:$(VERSION_GAMES_AGENT) \
		-f apps/games-agent/Dockerfile \
		--build-arg VERSION=$(VERSION_GAMES_AGENT) \
		--build-arg AWS_QUEUE_NAME=$(AWS_QUEUE_NAME) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		.

images/api-server/push:
	test -n "$(AWS_ECR_URL)" # Missing AWS ECR URL
	docker tag isim-ao-training/api-server:$(VERSION_API_SERVER) $(AWS_ECR_URL)/isim-ao-training/api-server:$(VERSION_API_SERVER)
	docker push $(AWS_ECR_URL)/isim-ao-training/api-server:$(VERSION_API_SERVER)

images/games-agent/push:
	test -n "$(AWS_ECR_URL)" # Missing AWS ECR URL
	docker tag isim-ao-training/games-agent:$(VERSION_API_SERVER) $(AWS_ECR_URL)/isim-ao-training/games-agent:$(VERSION_API_SERVER)
	docker push $(AWS_ECR_URL)/isim-ao-training/games-agent:$(VERSION_API_SERVER)

load-test/tool:
	go get -u github.com/tsenart/vegeta

load-test/network/light:
	test -n "$(API_SERVER_ALB)" # Missing API Server ALB hostname
	echo "GET http://$(API_SERVER_ALB)/" | vegeta attack -duration=$(TEST_DURATION) | tee results.bin | vegeta report
