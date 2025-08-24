package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"

	_ "embed"
)

type MessageResponse struct {
	Message string `json:"message"`
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	http.HandleFunc("/", messageHandler)

	log.Printf("Message service starting on port %s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal("Message service failed to start:", err)
	}
}

//go:embed message.txt
var message string

func messageHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	response := MessageResponse{
		Message: message,
	}

	json.NewEncoder(w).Encode(response)
}
