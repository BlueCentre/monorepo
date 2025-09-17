package storage

import (
	"github.com/pulumi/pulumi-gcp/sdk/v7/go/gcp/storage"
	"github.com/pulumi/pulumi-random/sdk/v4/go/random"
	"github.com/pulumi/pulumi/sdk/v3/go/pulumi"
)

// CreateBucketArgs defines the arguments for creating a storage bucket.
type CreateBucketArgs struct {
	ProjectID string
	NamePrefix string
	Location  string
}

// CreateBucket creates a new Google Cloud Storage bucket.
func CreateBucket(ctx *pulumi.Context, name string, args *CreateBucketArgs) (*storage.Bucket, error) {
	// Generate a random suffix for the bucket name to ensure global uniqueness.
	bktSuffix, err := random.NewRandomString(ctx, name+"-suffix", &random.RandomStringArgs{
		Length:  pulumi.Int(4),
		Special: pulumi.Bool(false),
		Upper:   pulumi.Bool(false),
		Numeric: pulumi.Bool(true),
		Lower:   pulumi.Bool(true),
		OverrideSpecial: pulumi.String(""), // No special characters for bucket names
	})
	if err != nil {
		return nil, err
	}

	bucketName := pulumi.Sprintf("%s-%s", args.NamePrefix, bktSuffix.Result)

	bucket, err := storage.NewBucket(ctx, name, &storage.BucketArgs{
		Project:  pulumi.String(args.ProjectID),
		Name:     bucketName,
		Location: pulumi.String(args.Location),
	})
	if err != nil {
		return nil, err
	}

	ctx.Export(name+"Name", bucket.Name)

	return bucket, nil
}
