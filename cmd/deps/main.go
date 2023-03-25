package main

import (
	"fmt"
)

func main() {
	err := mainImpl()
	if err != nil {
		fmt.Println("error:", err)

		return
	}
	fmt.Println("scm-go-usb-deps: PASS")
}
