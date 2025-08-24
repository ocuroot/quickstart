package main

import (
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"time"
)

type WeatherResponse struct {
	Location    string  `json:"location"`
	Temperature float64 `json:"temperature"`
	Description string  `json:"description"`
	Humidity    int     `json:"humidity"`
	LastUpdated string  `json:"last_updated"`
	Source      string  `json:"source"`
}

type GitHubStarsResponse struct {
	Repository string `json:"repository"`
	Stars      int    `json:"stars"`
	Language   string `json:"language"`
	LastUpdate string `json:"last_update"`
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	http.HandleFunc("/", homeHandler)
	http.HandleFunc("/weather", weatherHandler)
	http.HandleFunc("/github-stars", githubStarsHandler)
	http.HandleFunc("/demo-data", demoDataHandler)

	log.Printf("Weather service starting on port %s", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal("Weather service failed to start:", err)
	}
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	response := map[string]interface{}{
		"service": "weather-service",
		"version": "1.0.0",
		"endpoints": []string{
			"/weather - Mock weather data",
			"/github-stars - GitHub repository stars",
			"/demo-data - Demo metrics data",
		},
	}
	json.NewEncoder(w).Encode(response)
}

func weatherHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	// Mock weather data since we don't want to require API keys for demo
	response := WeatherResponse{
		Location:    "San Francisco, CA",
		Temperature: 22.5,
		Description: "Partly cloudy",
		Humidity:    65,
		LastUpdated: time.Now().Format(time.RFC3339),
		Source:      "mock-data",
	}

	json.NewEncoder(w).Encode(response)
}

func githubStarsHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	// Try to fetch real GitHub data for a popular repo
	resp, err := http.Get("https://api.github.com/repos/golang/go")
	if err != nil {
		// Fallback to mock data if GitHub API fails
		response := GitHubStarsResponse{
			Repository: "golang/go",
			Stars:      120000,
			Language:   "Go",
			LastUpdate: time.Now().Format(time.RFC3339),
		}
		json.NewEncoder(w).Encode(response)
		return
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		http.Error(w, "Failed to read GitHub response", http.StatusInternalServerError)
		return
	}

	var githubData struct {
		Name            string `json:"name"`
		FullName        string `json:"full_name"`
		StargazersCount int    `json:"stargazers_count"`
		Language        string `json:"language"`
		UpdatedAt       string `json:"updated_at"`
	}

	if err := json.Unmarshal(body, &githubData); err != nil {
		http.Error(w, "Failed to parse GitHub response", http.StatusInternalServerError)
		return
	}

	response := GitHubStarsResponse{
		Repository: githubData.FullName,
		Stars:      githubData.StargazersCount,
		Language:   githubData.Language,
		LastUpdate: githubData.UpdatedAt,
	}

	json.NewEncoder(w).Encode(response)
}

func demoDataHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	// Generate some demo metrics
	now := time.Now()
	response := map[string]interface{}{
		"cpu_usage":    fmt.Sprintf("%.1f%%", 15.5+float64(now.Second()%20)),
		"memory_usage": fmt.Sprintf("%.1f%%", 45.2+float64(now.Second()%30)),
		"requests":     1000 + now.Second()*10,
		"uptime":       "2d 14h 32m",
		"timestamp":    now.Format(time.RFC3339),
	}

	json.NewEncoder(w).Encode(response)
}
