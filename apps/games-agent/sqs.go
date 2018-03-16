package main

import (
	"fmt"
	"io"
	"log"
	"strings"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sqs"
)

// SQS knows how to communicate with an AWS SQS queue.
type SQS struct {
	client          *sqs.SQS
	queueURL        *string
	waitTimeSeconds int64
}

// NewSQS returns a new instance of SQS.
func NewSQS(region, queueName string, waitTimeSeconds int64) (*SQS, error) {
	config := &aws.Config{Region: aws.String(region)}
	session := session.Must(session.NewSession(config))
	client := sqs.New(session)

	input := &sqs.GetQueueUrlInput{QueueName: aws.String(queueName)}
	url, err := client.GetQueueUrl(input)
	if err != nil {
		return nil, err
	}

	return &SQS{
		client:          client,
		queueURL:        url.QueueUrl,
		waitTimeSeconds: waitTimeSeconds,
	}, nil
}

// Receive receives payload messages from the SQS queue.
func (s *SQS) Receive() (io.Reader, error) {
	result, err := s.client.ReceiveMessage(&sqs.ReceiveMessageInput{
		AttributeNames: []*string{
			aws.String(sqs.MessageSystemAttributeNameSentTimestamp),
		},
		MessageAttributeNames: []*string{
			aws.String(sqs.QueueAttributeNameAll),
		},
		QueueUrl:            s.queueURL,
		MaxNumberOfMessages: aws.Int64(1),
		VisibilityTimeout:   aws.Int64(36000),
		WaitTimeSeconds:     aws.Int64(s.waitTimeSeconds),
	})
	if err != nil {
		return nil, err
	}

	var (
		content        string
		receiptHandles = []string{}
	)
	for _, msg := range result.Messages {
		content += "\n" + msg.String()
		receiptHandles = append(receiptHandles, *msg.ReceiptHandle)
	}

	defer func() {
		if err := s.Delete(receiptHandles); err != nil {
			log.Print("Encounter errors while deleting messages. Reason: ", err)
		}
	}()

	if len(content) > 0 {
		content = content[1:]
	}
	return strings.NewReader(content), nil
}

// Delete deletes a message from the SQS queue using the provided receipt handle.
func (s *SQS) Delete(receiptHandles []string) error {
	var errors error
	for _, receiptHandle := range receiptHandles {
		_, err := s.client.DeleteMessage(&sqs.DeleteMessageInput{
			QueueUrl:      s.queueURL,
			ReceiptHandle: aws.String(receiptHandle),
		})
		if err != nil {
			errors = fmt.Errorf("%s\n%s", errors, err)
		}
	}

	return errors
}
