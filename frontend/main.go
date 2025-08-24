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

func main() {
	http.HandleFunc("/", homeHandler)
	http.HandleFunc("/health", healthHandler)
	http.HandleFunc("/api/message", messageHandler)
	http.HandleFunc("/api/services", servicesHandler)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	fmt.Printf("Server starting on port %s\n", port)
	if err := http.ListenAndServe(":"+port, nil); err != nil {
		log.Fatal("Server failed to start:", err)
	}
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "text/html")

	// Fetch data from downstream services
	timeData := fetchTimeData()
	weatherData := fetchWeatherData()
	messageData := fetchMessageData()

	html := fmt.Sprintf(`
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Quickstart App</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Sora:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { 
            font-family: 'Sora', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; 
            margin: 0;
            padding: 40px;
            background: #242526;
            color: #f0f0f0;
            line-height: 1.6;
        }
        .container { 
            max-width: 800px; 
            margin: 0 auto;
            background: #2f3031;
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 20px 25px -5px rgb(0 0 0 / 0.5), 0 8px 10px -6px rgb(0 0 0 / 0.4);
            border: 1px solid #404040;
        }
        h1 {
            color: #f0f0f0;
            font-weight: 600;
            margin-bottom: 16px;
            display: flex;
            align-items: center;
            gap: 16px;
        }
        p {
            color: #b3b3b3;
            font-weight: 400;
            margin-bottom: 24px;
        }
        .logo {
            width: 48px;
            height: 48px;
            fill: #f0f0f0;
        }
        .services {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-top: 32px;
        }
        .service-card {
            background: #404040;
            border-radius: 8px;
            padding: 20px;
            border: 1px solid #555;
        }
        .service-title {
            color: #16a34a;
            font-weight: 600;
            margin-bottom: 12px;
            font-size: 18px;
        }
        .service-content {
            color: #b3b3b3;
            font-size: 14px;
            line-height: 1.4;
        }
        .error {
            color: #ef4444;
            font-style: italic;
        }
    </style>
    <script>
        function refreshServices() {
            fetch('/api/services')
                .then(response => response.json())
                .then(data => {
                    document.getElementById('time-content').innerHTML = data.time;
                    document.getElementById('weather-content').innerHTML = data.weather;
                    document.getElementById('message-content').innerHTML = data.message;
                })
                .catch(error => {
                    console.error('Error refreshing services:', error);
                });
        }
        
        // Refresh every second
        setInterval(refreshServices, 1000);
    </script>
</head>
<body>
    <div class="container">
        <h1>
            <svg class="logo" viewBox="0 0 271 271" xmlns="http://www.w3.org/2000/svg">
                <path fill-rule="evenodd" clip-rule="evenodd" d="M134.426 155.378L171.909 134.643L134.426 113.908V113.85L134.374 113.879L134.322 113.85V113.908L96.8394 134.643L134.322 155.378V155.436L134.374 155.407L134.426 155.436V155.378Z"/>
                <path fill-rule="evenodd" clip-rule="evenodd" d="M0 135.245L134.186 61.0138V60.8062L134.374 60.91L134.562 60.8062V61.0138L268.748 135.245L134.562 209.476V209.683L134.374 209.58L134.186 209.683V209.476L0 135.245ZM33.0305 134.494L133.483 79.7267V79.5735L133.623 79.6501L133.764 79.5735V79.7267L234.216 134.494L133.764 189.261V189.415L133.623 189.338L133.483 189.415V189.261L33.0305 134.494Z"/>
                <path d="M0 135.313H30.361V202.781L0 182.916V135.313Z"/>
                <path d="M268.751 135.313H238.39V202.781L268.751 182.916V135.313Z"/>
                <rect x="120.32" y="194.16" width="30.361" height="67.4689"/>
            </svg>
            Welcome to Ocuroot
        </h1>
        <p>This is a quickstart application demonstrating Ocuroot's release orchestration capabilities with microservices.</p>
        <p>Environment: %s</p>
        
        <div class="services">
            <div class="service-card">
                <div class="service-title">🕐 Time Service</div>
                <div class="service-content" id="time-content">%s</div>
            </div>
            <div class="service-card">
                <div class="service-title">🌤️ Weather Service</div>
                <div class="service-content" id="weather-content">%s</div>
            </div>
            <div class="service-card">
                <div class="service-title">💬 Message Service</div>
                <div class="service-content" id="message-content">%s</div>
            </div>
        </div>
    </div>
</body>
</html>`, os.Getenv("ENVIRONMENT"), timeData, weatherData, messageData)

	fmt.Fprint(w, html)
}

func fetchTimeData() string {
	timeServiceURL := os.Getenv("TIME_SERVICE_URL")
	if timeServiceURL == "" {
		timeServiceURL = "http://localhost:8081"
	}

	client := &http.Client{Timeout: 5 * time.Second}
	resp, err := client.Get(timeServiceURL + "/time")
	if err != nil {
		return fmt.Sprintf(`<span class="error">Time service unavailable: %v</span>`, err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Sprintf(`<span class="error">Failed to read time response: %v</span>`, err)
	}

	var timeData struct {
		Formatted string `json:"formatted"`
		Timezone  string `json:"timezone"`
	}

	if err := json.Unmarshal(body, &timeData); err != nil {
		return fmt.Sprintf(`<span class="error">Failed to parse time data: %v</span>`, err)
	}

	return fmt.Sprintf("<strong>%s</strong><br><small>%s</small>", timeData.Formatted, timeData.Timezone)
}

func fetchWeatherData() string {
	weatherServiceURL := os.Getenv("WEATHER_SERVICE_URL")
	if weatherServiceURL == "" {
		weatherServiceURL = "http://localhost:8082"
	}

	client := &http.Client{Timeout: 5 * time.Second}
	resp, err := client.Get(weatherServiceURL + "/weather")
	if err != nil {
		return fmt.Sprintf(`<span class="error">Weather service unavailable: %v</span>`, err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Sprintf(`<span class="error">Failed to read weather response: %v</span>`, err)
	}

	var weatherData struct {
		Location    string  `json:"location"`
		Temperature float64 `json:"temperature"`
		Description string  `json:"description"`
		Humidity    int     `json:"humidity"`
	}

	if err := json.Unmarshal(body, &weatherData); err != nil {
		return fmt.Sprintf(`<span class="error">Failed to parse weather data: %v</span>`, err)
	}

	return fmt.Sprintf("<strong>%s</strong><br>%.1f°C, %s<br><small>Humidity: %d%%</small>",
		weatherData.Location, weatherData.Temperature, weatherData.Description, weatherData.Humidity)
}

func fetchMessageData() string {
	messageServiceURL := os.Getenv("MESSAGE_SERVICE_URL")
	if messageServiceURL == "" {
		messageServiceURL = "http://localhost:8083"
	}

	client := &http.Client{Timeout: 5 * time.Second}
	resp, err := client.Get(messageServiceURL)
	if err != nil {
		return fmt.Sprintf(`<span class="error">Message service unavailable: %v</span>`, err)
	}
	defer resp.Body.Close()

	body, err := io.ReadAll(resp.Body)
	if err != nil {
		return fmt.Sprintf(`<span class="error">Failed to read message response: %v</span>`, err)
	}

	var messageData struct {
		Message string `json:"message"`
	}

	if err := json.Unmarshal(body, &messageData); err != nil {
		return fmt.Sprintf(`<span class="error">Failed to parse message data: %v</span>`, err)
	}

	return messageData.Message
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	fmt.Fprint(w, `{"status": "healthy"}`)
}

func messageHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	message := fetchMessageData()
	fmt.Fprintf(w, `{"message": "%s"}`, message)
}

func servicesHandler(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")

	timeData := fetchTimeData()
	weatherData := fetchWeatherData()
	messageData := fetchMessageData()

	response := map[string]string{
		"time":    timeData,
		"weather": weatherData,
		"message": messageData,
	}

	json.NewEncoder(w).Encode(response)
}
