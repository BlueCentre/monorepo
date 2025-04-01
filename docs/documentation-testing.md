# Documentation Testing Guide

This guide outlines procedures for testing and validating the documentation in this repository to ensure accuracy, completeness, and usability.

## Why Test Documentation?

Documentation testing is crucial for:
- Ensuring technical accuracy of procedures and commands
- Validating that examples work as described
- Finding gaps in documentation coverage
- Improving the overall user experience

## Documentation Quality Checklist

Before publishing any documentation, use this checklist:

| Criteria | Description | Verification Method |
|----------|-------------|---------------------|
| Technical accuracy | Commands and procedures work as described | Manual execution |
| Completeness | All required steps are included | Peer review |
| Clarity | Instructions are clear and unambiguous | User testing |
| Consistency | Terminology and formatting are consistent | Style guide comparison |
| Up-to-date | Information reflects current versions | Version verification |
| Accessibility | Content is accessible to the target audience | Readability tools |
| Examples | All examples are functional | Manual execution |
| Links | All links are valid and point to correct resources | Link checker |

## Testing Infrastructure Documentation

### Testing Component Installation Guides

For each component installation guide (Istio, Cert Manager, etc.):

1. **Start with a clean environment**:
   ```bash
   # Reset your Kubernetes cluster
   colima delete
   colima start --kubernetes --cpu 4 --memory 8
   ```

2. **Follow the documentation step by step**:
   - Execute each command exactly as written
   - Do not use prior knowledge to "fix" steps
   - Take notes on any confusion or errors

3. **Verify the outcome**:
   ```bash
   # Check if components are installed correctly
   kubectl get pods -n <component-namespace>
   
   # Verify functionality with a test case
   # (specific to each component)
   ```

4. **Document any issues**:
   - Missing prerequisites
   - Unclear instructions
   - Failed commands
   - Version incompatibilities

### Testing Infrastructure Configuration

For configuration documentation:

1. **Apply the documented configuration**:
   ```bash
   # For Terraform
   cd terraform_dev_local
   # Create terraform.auto.tfvars with test values
   terraform apply
   
   # For Pulumi
   cd pulumi_dev_local
   # Set config values as documented
   pulumi up
   ```

2. **Verify configuration is applied**:
   ```bash
   # Check specific resources for correct configuration
   kubectl get <resource> -o yaml | grep <configuration-parameter>
   ```

3. **Test edge cases**:
   - Minimum/maximum values
   - Optional parameters
   - Configuration combinations

## Testing Tutorials and Walkthroughs

For end-to-end tutorials:

1. **Follow the tutorial with different user personas**:
   - Beginner: No prior knowledge of the tools
   - Intermediate: Familiar with Kubernetes but not the specific components
   - Expert: Looking for specific advanced features

2. **Time the process**:
   - Note how long each section takes
   - Identify steps that could be optimized

3. **Document completion rate**:
   - Track where users commonly get stuck
   - Note if users need to consult external resources

## Testing Troubleshooting Guides

For troubleshooting documentation:

1. **Create the problem scenario**:
   - Intentionally break the setup as described in the issue
   - Verify the symptoms match the documentation

2. **Follow the troubleshooting steps**:
   - Apply each solution in order
   - Document which step resolved the issue

3. **Verify resolution**:
   - Confirm the system now functions correctly
   - Check for any side effects

## Automated Documentation Testing

### Link Validation

Test all documentation links automatically:

```bash
# Using markdown-link-check
npm install -g markdown-link-check
find ./docs -name "*.md" -exec markdown-link-check {} \;
```

### Command Validation

Use a script to extract and validate commands:

```bash
#!/bin/bash
# Simple script to extract bash commands from markdown and validate syntax

for file in docs/*.md; do
  echo "Checking commands in $file"
  
  # Extract code blocks marked as bash
  grep -n -A 1000 '```bash' "$file" | 
  grep -B 1000 -m 1 '```' | 
  grep -v '```' | 
  
  # Check each command for syntax errors
  while read -r cmd; do
    if [[ -n "$cmd" && ! "$cmd" =~ ^# ]]; then
      bash -n <<< "$cmd" || echo "Syntax error in command: $cmd"
    fi
  done
done
```

### Schema Validation for YAML Examples

Validate YAML examples against their schemas:

```bash
# Using yamllint
pip install yamllint
yamllint docs/examples/*.yaml
```

## Documentation User Testing

For comprehensive documentation testing, involve real users:

1. **Setup test sessions**:
   - Recruit 3-5 users with varying experience levels
   - Provide them with documentation but minimal guidance
   - Observe them attempting to follow the documentation

2. **Data collection**:
   - Record time to complete tasks
   - Note questions that arise
   - Identify points of confusion
   - Collect suggestions for improvement

3. **Analysis and improvements**:
   - Identify common issues across users
   - Prioritize documentation improvements
   - Make changes based on user feedback

## Documentation Version Testing

When testing documentation across different versions:

1. **Maintain test environments for each supported version**:
   ```bash
   # For Terraform
   git checkout tags/v1.2.3
   cd terraform_dev_local
   terraform init
   terraform apply
   
   # For Pulumi
   git checkout tags/v1.2.3
   cd pulumi_dev_local
   pulumi stack select dev
   pulumi up
   ```

2. **Verify version-specific instructions**:
   - Test commands and procedures for each version
   - Note backward compatibility issues

3. **Document version differences**:
   - Update version-specific notes
   - Clearly mark version-specific instructions

## Documentation Review Process

Implement a review process for documentation changes:

1. **Self-review**:
   - Run through the checklist before submitting
   - Test on a clean environment when possible

2. **Peer review**:
   - Have another team member follow the documentation
   - Reviewer should verify accuracy and clarity

3. **Technical expert review**:
   - Component owner verifies technical accuracy
   - Checks for completeness of advanced features

4. **Final validation**:
   - Test the documentation after all revisions
   - Verify all issues have been addressed

## Reporting Documentation Issues

When documentation issues are found:

1. **Create a detailed issue report**:
   - Specific file and section
   - Exact nature of the problem
   - Steps to reproduce (for procedural issues)
   - Suggested correction if available

2. **Use labels for categorization**:
   - `docs-error`: Factual or technical error
   - `docs-incomplete`: Missing information
   - `docs-unclear`: Confusing explanation
   - `docs-outdated`: No longer accurate

3. **Include environment details**:
   - Tool versions
   - Operating system
   - Any relevant configuration

## Measuring Documentation Quality

Track documentation quality metrics:

1. **Issue tracking**:
   - Number of documentation issues reported
   - Time to resolve documentation issues
   - Recurring issue patterns

2. **User surveys**:
   - Satisfaction ratings
   - Completion rates for procedures
   - Ease of finding information

3. **Usage analytics**:
   - Most/least referenced pages
   - Search terms used within documentation
   - Time spent on documentation pages

## Documentation Testing Tools

| Tool | Purpose | Installation |
|------|---------|--------------|
| [markdown-link-check](https://github.com/tcort/markdown-link-check) | Validate links | `npm install -g markdown-link-check` |
| [markdownlint](https://github.com/DavidAnson/markdownlint) | Check markdown format | `npm install -g markdownlint-cli` |
| [vale](https://github.com/errata-ai/vale) | Style consistency | `brew install vale` |
| [yamllint](https://github.com/adrienverge/yamllint) | YAML validation | `pip install yamllint` |
| [shellcheck](https://github.com/koalaman/shellcheck) | Shell script validation | `brew install shellcheck` |
| [mermaid-cli](https://github.com/mermaid-js/mermaid-cli) | Diagram validation | `npm install -g @mermaid-js/mermaid-cli` |

## Creating Documentation Test Scripts

Example script for comprehensive documentation testing:

```bash
#!/bin/bash
# Run a full documentation test suite

echo "Running documentation tests..."

echo "1. Checking for broken links..."
find ./docs -name "*.md" -exec markdown-link-check {} \; > link-check-results.txt

echo "2. Validating markdown style..."
markdownlint docs/ > markdown-lint-results.txt

echo "3. Checking shell commands..."
shellcheck docs/examples/scripts/*.sh > shellcheck-results.txt

echo "4. Validating YAML examples..."
yamllint docs/examples/*.yaml > yaml-lint-results.txt

echo "5. Testing Mermaid diagrams..."
find docs/ -name "*.md" | xargs grep -l "```mermaid" | while read -r file; do
  # Extract and validate mermaid diagrams
  grep -n -A 1000 '```mermaid' "$file" | 
  grep -B 1000 -m 1 '```' | 
  grep -v '```' > temp-diagram.mmd
  
  mmdc -i temp-diagram.mmd -o /dev/null
  if [ $? -ne 0 ]; then
    echo "Error in diagram in $file"
  fi
  rm temp-diagram.mmd
done

echo "6. Running acceptance tests..."
# Add your acceptance test script here

echo "Tests completed. Review results in *-results.txt files."
```

## Documentation Test CI/CD Integration

Integrate documentation testing into your CI/CD pipeline:

```yaml
# Example GitHub Actions workflow
name: Documentation Tests

on:
  push:
    paths:
      - 'docs/**'
  pull_request:
    paths:
      - 'docs/**'

jobs:
  test-docs:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Set up Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '16'
          
      - name: Install dependencies
        run: |
          npm install -g markdown-link-check markdownlint-cli
          pip install yamllint
          
      - name: Check links
        run: find ./docs -name "*.md" -exec markdown-link-check {} \;
        
      - name: Lint markdown
        run: markdownlint docs/
        
      - name: Validate YAML
        run: yamllint docs/examples/*.yaml
```

## Best Practices for Documentation Testing

1. **Test in clean environments**:
   - Use containers or VMs for isolated testing
   - Start from the stated prerequisites only

2. **Test as different user personas**:
   - Consider different knowledge levels
   - Consider different use cases

3. **Apply progressive testing**:
   - Test documentation during development
   - Test again after any technical changes
   - Perform final validation before release

4. **Create test datasets**:
   - Provide sample data for examples
   - Include verification data for expected results

5. **Document testing results**:
   - Keep records of test outcomes
   - Track improvements over time

6. **Automate where possible**:
   - Use tools for routine checks
   - Focus manual testing on user experience 