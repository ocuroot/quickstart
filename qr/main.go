package main

import (
	"os"
	"path/filepath"

	"github.com/skip2/go-qrcode"
)

func main() {
	file := os.Args[1]
	message := os.Args[2]

	// Create the directory for the file and all necessary subdirectories
	dir := filepath.Dir(file)
	err := os.MkdirAll(dir, os.ModePerm)
	if err != nil {
		panic(err)
	}

	err = qrcode.WriteFile(message, qrcode.Medium, 256, file)
	if err != nil {
		panic(err)
	}
}
