package main		

import (		
	"fmt"
	"time"
	"github.com/google/go-cmp/cmp"
)		

func main() {
	for true {
		fmt.Println(cmp.Diff("Hello FLYR!", "Hello Platform!"))
		time.Sleep(2 * time.Second)
	}	
}
