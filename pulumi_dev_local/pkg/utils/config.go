package utils

import (
	"strconv"

	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi/config"
)

// PulumiConfig wraps the Pulumi configuration for easier access
type PulumiConfig struct {
	conf *config.Config
}

// NewConfig creates a new configuration wrapper
func NewConfig(ctx *pulumi.Context) *PulumiConfig {
	return &PulumiConfig{
		conf: config.New(ctx, ""),
	}
}

// GetNamespace gets a namespace from configuration or returns the default
func (c *PulumiConfig) GetNamespace(key string, defaultValue string) string {
	ns := c.conf.Get(key + ":namespace")
	if ns == "" {
		return defaultValue
	}
	return ns
}

// GetString gets a string value from configuration or returns the default
func (c *PulumiConfig) GetString(key string, defaultValue string) string {
	val := c.conf.Get(key)
	if val == "" {
		return defaultValue
	}
	return val
}

// GetBool gets a boolean value from configuration or returns the default
func (c *PulumiConfig) GetBool(key string, defaultValue bool) bool {
	val := c.conf.Get(key)
	if val == "" {
		return defaultValue
	}
	b, err := strconv.ParseBool(val)
	if err != nil {
		return defaultValue
	}
	return b
}

// GetInt gets an integer value from configuration or returns the default
func (c *PulumiConfig) GetInt(key string, defaultValue int) int {
	val := c.conf.Get(key)
	if val == "" {
		return defaultValue
	}
	i, err := strconv.Atoi(val)
	if err != nil {
		return defaultValue
	}
	return i
}

// RequireSecret gets a secret string value from configuration
// It panics if the key is not found
func (c *PulumiConfig) RequireSecret(ctx *pulumi.Context, key string) pulumi.StringOutput {
	// Use RequireSecret to get the secret value. This will panic if not found.
	// The underlying config.RequireSecret does not need the context.
	return c.conf.RequireSecret(key).ToStringOutput()
}
