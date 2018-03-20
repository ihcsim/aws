package main

import (
	"errors"
	"io"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/signal"
)

const (
	defaultServerPort = "8080"

	awsDefaultRegion = "us-west-2"

	envVarServerPort   = "SERVER_PORT"
	envVarAWSRegion    = "AWS_REGION"
	envVarAWSQueueName = "AWS_QUEUE_NAME"
)

var client *SQS

func main() {
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, os.Interrupt)

	var err error
	client, err = initSQSClient()
	if err != nil {
		log.Fatal("Fail to connect to AWS SQS queue. Reason: ", err)
	}
	log.Printf("Connected to AWS SQS queue at %s...", *client.queueURL)

	serverPort, exist := os.LookupEnv(envVarServerPort)
	if !exist {
		serverPort = defaultServerPort
	}

	log.Printf("Starting server. Listening at port %s...", serverPort)
	http.HandleFunc("/", handler)
	go func() {
		if err := http.ListenAndServe(":"+serverPort, nil); err != nil {
			log.Fatalf("Fail to server at port %s. Reason: %s", serverPort, err)
		}
	}()

	s := <-sigChan
	log.Printf("Shutting down server. Reason: received %s signal.", s)
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

	return NewSQS(region, queueName)
}

func handler(w http.ResponseWriter, req *http.Request) {
	switch req.Method {
	case "POST":
		response, err := enqueue(req)
		if err != nil {
			handleError(err, http.StatusInternalServerError, w)
			return
		}

		result, err := ioutil.ReadAll(response)
		if err != nil {
			handleError(err, http.StatusInternalServerError, w)
			return
		}

		w.WriteHeader(http.StatusOK)
		w.Write(result)
	case "GET":
		w.WriteHeader(http.StatusOK)
	default:
		err := errors.New("Unsupported HTTP method")
		handleError(err, http.StatusMethodNotAllowed, w)
	}
}

func enqueue(req *http.Request) (io.Reader, error) {
	payload, err := ioutil.ReadAll(req.Body)
	if err != nil {
		return nil, errors.New("Failed to read request payload. Reason: " + err.Error())
	}

	return client.Send(payload)
}

func handleError(err error, status int, w http.ResponseWriter) {
	log.Println(err)
	w.WriteHeader(status)
	w.Write([]byte(err.Error()))
}
