package main		

import (		
	"fmt"
	"time"
	"github.com/google/go-cmp/cmp"
)		

func main() {
	for {
		fmt.Println("Hello FLYR!")
		fmt.Println(cmp.Diff("Hello FLYR!", "Hello Platform!"))
		time.Sleep(time.Second * 2)
	}	
}
