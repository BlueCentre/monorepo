package applications

import (
	"time"

	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

// AddDelay adds a delay in the Pulumi execution to ensure dependent resources are ready
func AddDelay(ctx *pulumi.Context, duration time.Duration) (string, error) {
	// Log the delay intention
	ctx.Log.Info("Adding delay of "+duration.String(), nil)

	// The delay happens during the Pulumi execution
	time.Sleep(duration)

	// Return a token to mark completion (not used but needed for function signature)
	return "delay-complete", nil
}
