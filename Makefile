.PHONY: load-test/tool load-test/network

TEST_DURATION ?= 5s

load-test/tool:
	go get -u github.com/tsenart/vegeta

load-test/network/light:
	test -n "$(API_SERVER_ALB)" # Missing API Server ALB hostname
	echo "GET http://$(API_SERVER_ALB)/" | vegeta attack -duration=$(TEST_DURATION) | tee results.bin | vegeta report
