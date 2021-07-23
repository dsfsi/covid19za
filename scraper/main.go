package main

import (
	"os"
)

var UNIQUE_LINKS = map[string]bool{}

func main() {
	// get command line args
	args := os.Args[1:]
	Init(args)
}
