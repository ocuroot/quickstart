package main

import (
	"os"

	"github.com/skip2/go-qrcode"
)

func main() {
	file := os.Args[1]
	message := os.Args[2]

	err := qrcode.WriteFile(message, qrcode.Medium, 256, file)
	if err != nil {
		panic(err)
	}
}
