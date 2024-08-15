// Binary go-server logs messages received from clients via grpc and serves them to web client via http
package main

import (
	"context"
	"fmt"
	"io/ioutil"
	"log"
	"net"
	"net/http"
	"sync"
	"time"

	pb "github.com/aspect-build/bazel-examples/logger"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
	"google.golang.org/protobuf/encoding/protojson"
)

var (
	mu  sync.Mutex
	lms = []pb.LogMessage{}
)

// GRPC Server
func startGrpc() error {
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	s := grpc.NewServer()
	pb.RegisterLoggerServer(s, &server{})
	reflection.Register(s)
	return s.Serve(lis)
}

type server struct{}

// SendLogMessage implements logger.LoggerServer by recieving a message and storing it with a timestamp
func (s *server) SendLogMessage(ctx context.Context, in *pb.LogMessage) (*pb.Empty, error) {
	t := int64(time.Now().Unix())
	fmt.Printf("Log received: {%s, %d}\n", in.Message, t)
	lm := pb.LogMessage{Message: in.Message, Time: t}
	saveLogMessage(lm)
	// for integration testing purposes
	writeToFile(lm)
	return new(pb.Empty), nil
}

func saveLogMessage(lm pb.LogMessage) {
	mu.Lock()
	defer mu.Unlock()
	lms = append(lms, lm)
}

func writeToFile(lm pb.LogMessage) {
	js, _ := protojson.Marshal(&lm)
	err := ioutil.WriteFile("/tmp/bootcamp_server_last_message.txt", js, 0o644)
	if err != nil {
		panic(err)
	}
}

// HTTP Server
func startHTTP() error {
	fmt.Println("Listening on port 8081...")
	http.HandleFunc("/", handleStrings)
	return http.ListenAndServe(":8081", nil)
}

func handleStrings(w http.ResponseWriter, req *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	w.Header().Set("Access-Control-Allow-Origin", "*")

	s := createJSONResponse()

	fmt.Println("Sending logs to frontend")
	fmt.Fprintln(w, s)
}

func createJSONResponse() string {
	mu.Lock()
	defer mu.Unlock()

	s := ""
	if len(lms) > 0 {
		s = "["
		for _, lm := range lms {
			// TODO(dannark): Use m.Marshal(w, pb) to Marshall into json object
			// then put those objects in a list and then send the list??

			// marshal current element to json string
			js, _ := protojson.Marshal(&lm)
			s += string(js)
			s += ", "
		}
		// remove trailing comma
		s = s[:len(s)-2]
		s += "]"
	} else {
		s = "\"No log messages received yet.\""
	}
	return s
}

func main() {
	fmt.Println("Starting grpc and http servers")
	errs := make(chan error)
	go func() { errs <- startGrpc() }()
	go func() { errs <- startHTTP() }()
	err := <-errs
	log.Fatal(err)
}
