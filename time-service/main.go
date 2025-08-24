package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"
)

type TimeResponse struct {
	UTC       string `json:"utc"`
	Local     string `json:"local"`
	Unix      int64  `json:"unix"`
	Timezone  string `json:"timezone"`
	Formatted string `json:"formatted"`
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	http.HandleFunc("/", homeHandler)
	http.HandleFunc("/time", timeHandler)
	http.HandleFunc("/time/utc", utcHandler)
	http.HandleFunc("/time/local", localHandler)

	log.Printf("Time service starting on port %s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal("Time service failed to start:", err)
	}
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	response := map[string]interface{}{
		"service": "time-service",
		"version": "1.0.0",
		"endpoints": []string{
			"/time - Full time information",
			"/time/utc - UTC time only",
			"/time/local - Local time only",
		},
	}
	json.NewEncoder(w).Encode(response)
}

func timeHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	now := time.Now()
	response := TimeResponse{
		UTC:       now.UTC().Format(time.RFC3339),
		Local:     now.Format(time.RFC3339),
		Unix:      now.Unix(),
		Timezone:  now.Location().String(),
		Formatted: now.Format("Monday, January 2, 2006 at 3:04:05 PM MST"),
	}

	json.NewEncoder(w).Encode(response)
}

func utcHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	response := map[string]string{
		"utc": time.Now().UTC().Format(time.RFC3339),
	}

	json.NewEncoder(w).Encode(response)
}

func localHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	now := time.Now()
	response := map[string]string{
		"local":    now.Format(time.RFC3339),
		"timezone": now.Location().String(),
	}

	json.NewEncoder(w).Encode(response)
}
