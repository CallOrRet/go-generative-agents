package main

import "fmt"

var (
    Version  = "0.0.0"
    Revision = ""
)

func main() {
    fmt.Printf("Version: %s, Revision: %s\n", Version, Revision)
}
