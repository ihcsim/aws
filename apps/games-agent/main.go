package main

import (
	"errors"
	"io/ioutil"
	"log"
	"os"
	"os/signal"
)

const (
	awsDefaultRegion               = "us-west-2"
	awsQueueDefaultWaitTimeSeconds = 20

	envVarAWSRegion    = "AWS_REGION"
	envVarAWSQueueName = "AWS_QUEUE_NAME"
)

func main() {
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt)

	client, err := initSQSClient()
	if err != nil {
		log.Fatal("Fail to connect to AWS SQS queue. Reason: ", err)
	}
	log.Printf("Connected to AWS SQS queue at %s...", *client.queueURL)

	var (
		payloadChan = make(chan []byte)
		errChan     = make(chan error)
	)
	go dequeue(client, payloadChan, errChan)

	for {
		select {
		case payload := <-payloadChan:
			log.Printf("Receive payload: %s", payload)
		case s := <-sigChan:
			log.Printf("Shutting down server. Reason: Received %s signal.", s)
			os.Exit(0)
		case err := <-errChan:
			log.Println("Encounter error: ", err)
		}
	}
}

func initSQSClient() (*SQS, error) {
	region, exist := os.LookupEnv(envVarAWSRegion)
	if !exist {
		region = awsDefaultRegion
	}

	queueName, exist := os.LookupEnv(envVarAWSQueueName)
	if !exist {
		err := errors.New("missing AWS SQS queue name. Use the AWS_QUEUE_NAME to provide the queue name")
		return nil, err
	}

	return NewSQS(region, queueName, awsQueueDefaultWaitTimeSeconds)
}

func dequeue(sqs *SQS, payloadChan chan<- []byte, errChan chan<- error) {
	for {
		result, err := sqs.Receive()
		if err != nil {
			errChan <- err
		}

		content, err := ioutil.ReadAll(result)
		if err != nil {
			errChan <- err
		}

		payloadChan <- content
	}
}
