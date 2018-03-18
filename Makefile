.PHONY: images images/api-server images/games-agent load-test/tool load-test/network

TEST_DURATION ?= 5s
AWS_QUEUE_NAME ?= isim-ao-training-games-payload

VERSION_API_SERVER = 0.0.1
VERSION_GAMES_AGENT = 0.0.1

images: images/api-server images/games-agent

images/api-server:
	docker image build --rm -t isim-agileops-training/api-server:$(VERSION_API_SERVER) \
		-f apps/api-server/Dockerfile \
		--build-arg VERSION=$(VERSION_API_SERVER) \
		--build-arg AWS_QUEUE_NAME=$(AWS_QUEUE_NAME) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		.

images/games-agent:
	docker image build --rm -t isim-agileops-training/games-agent:$(VERSION_GAMES_AGENT) \
		-f apps/games-agent/Dockerfile \
		--build-arg VERSION=$(VERSION_GAMES_AGENT) \
		--build-arg AWS_QUEUE_NAME=$(AWS_QUEUE_NAME) \
		--build-arg VCS_REF=`git rev-parse --short HEAD` \
		--build-arg BUILD_DATE=`date -u +"%Y-%m-%dT%H:%M:%SZ"` \
		.

load-test/tool:
	go get -u github.com/tsenart/vegeta

load-test/network/light:
	test -n "$(API_SERVER_ALB)" # Missing API Server ALB hostname
	echo "GET http://$(API_SERVER_ALB)/" | vegeta attack -duration=$(TEST_DURATION) | tee results.bin | vegeta report
