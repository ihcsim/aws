package main

import (
	"io"
	"log"
	"strings"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sqs"
)

// SQS knows how to communicate with an AWS SQS queue.
type SQS struct {
	client   *sqs.SQS
	queueURL *string
}

// NewSQS returns a new instance of SQS.
func NewSQS(region, queueName string) (*SQS, error) {
	config := &aws.Config{Region: aws.String(region)}
	session := session.Must(session.NewSession(config))
	client := sqs.New(session)

	input := &sqs.GetQueueUrlInput{QueueName: aws.String(queueName)}
	url, err := client.GetQueueUrl(input)
	if err != nil {
		return nil, err
	}

	return &SQS{
		client:   client,
		queueURL: url.QueueUrl,
	}, nil
}

// Send sends the payload message to the SQS queue.
func (s *SQS) Send(payload []byte) (io.Reader, error) {
	log.Printf("Sending payload: %q", payload)
	result, err := s.client.SendMessage(&sqs.SendMessageInput{
		DelaySeconds: aws.Int64(10),
		MessageBody:  aws.String(string(payload)),
		QueueUrl:     s.queueURL,
	})
	if err != nil {
		return nil, err
	}

	log.Printf("Received response:\n%s", result)
	return strings.NewReader(result.String()), nil
}
