package main		

import (		
	"fmt"
	"time"
	"github.com/google/go-cmp/cmp"
)		

func main() {
	for {
		fmt.Println("Hello Application!")
		fmt.Println(cmp.Diff("Hello Application!", "Hello Platform!"))
		time.Sleep(time.Second * 2)
	}	
}
