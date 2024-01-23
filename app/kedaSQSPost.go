package main

import (
	"encoding/json"
	"fmt"
	"os"
	"time"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/sqs"
)

var queueURL string

func init() {
	queueURL = os.Getenv("SQS_QUEUE_URL")
	if queueURL == "" {
		fmt.Println("SQS URL Missing!!!!!")
		os.Exit(1)
	}
	fmt.Printf("SQS URL: %s\n", queueURL)
}

func sendMessage(messageBody map[string]interface{}) {
	fmt.Println("Start fn send message")

	sess, err := session.NewSession(&aws.Config{
		Region: aws.String(os.Getenv("AWS_REGION")),
	})
	if err != nil {
		fmt.Printf("Error creating session: %v\n", err)
		return
	}

	sqsClient := sqs.New(sess)
	messageBodyJSON, _ := json.Marshal(messageBody)
	input := &sqs.SendMessageInput{
		QueueUrl:       &queueURL,
		MessageBody:    aws.String(string(messageBodyJSON)),
		MessageGroupId: aws.String("messageGroup1"),
	}

	result, err := sqsClient.SendMessage(input)
	if err != nil {
		fmt.Printf("Error sending message: %v\n", err)
		return
	}

	fmt.Printf("Messages sent: %+v\n", result)
	fmt.Println("End fn send message")
}

func main() {
	startTime := time.Now()
	i := 0

	for {
		//t := time.Now()
		time.Sleep(time.Second - time.Since(startTime)%time.Second)
		currentTime := time.Now().Format("15:04:05")

		fmt.Printf("Start SQS Call: %s\n", currentTime)
		i++
		currentDateTime := time.Now().UTC().Format("2006-01-02 15:04:05.000")
		messageBody := map[string]interface{}{
			"msg":      fmt.Sprintf("Scale Buddy !!! : COUNT %d", i),
			"srcStamp": currentDateTime,
		}

		messageBodyJSON, _ := json.Marshal(messageBody)
		fmt.Println(string(messageBodyJSON))
		sendMessage(messageBody)

		currentTime = time.Now().Format("15:04:05")
		fmt.Printf("End SQS Call: %s\n", currentTime)
	}
}
