package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestAwsAsg(t *testing.T) {
	t.Parallel()

	// create a random asg name so that we can differentiate test resources from real ones
	expectedName := fmt.Sprintf("terratest-asg-%s", random.UniqueId())

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",

		Vars: map[string]interface{}{
			"asg_name": expectedName,
		},
	})

	// run destroy to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// run init and apply and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// get the value of an output variable
	instanceID := terraform.Output(t, terraformOptions, "elb_dns_name")

	// use tf output to validate that resources were created successfully
	assert.NotEmpty(t, instanceID)

}
