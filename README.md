# Goblet Tests Action
This action executes Goblet tests for a repository within a Github action

## Inputs

### `goblet-token`
* **required** CI token to access the goblet platform

### `goblet-path`
* Relative path the goblet tests folder within the repo
* **default** - `<repo-root-directory>/goblet` (value of <repo-root-directory> determined at runtime)

### `goblet-test-path:`
* Path to the tests to run
* **default** - Runs all tests if not defined

### `report`
* Name of the report file generated from the test results
* **default** - `<timestamp>-goblet-report` (value of <timestamp> is generated at runtime)

### `pre-goblet`
* List of bash commands to run prior to running the Goblet tests
* Allows for ensure the environment is setup for test execution

### `post-goblet`
* List of bash commands to run after the Goblet tests have finished executing
* Allows for handling reports or artifacts generated from tests execution

### `alt-repo`
* Alternative github repository that contains the tests to be run.

### `alt-branch`
* Name of the branch to use for the alt repository.

### `alt-user`
* Github user name or organization with write access to the alt repository.

### `alt-email`
* Email of user with write access to the alt repository.

### `alt-token`
* Github Token with write access to the alt repository.



## Outputs

### `result`
* Result of the Goblet test execution. One of `pass` or `fail`

### `report-path`
* Path to the generated test report from the executed tests

### `artifacts-path`
* Path to any generated artifacts from the executed tests

### `error`
* Error message output when the action fails for a reason other than test execution

## Example usage

```yaml
uses: actions/goblet-tests-action@v1
with:
  goblet-token: {{ secrets.GOBLET_TOKEN }}
  goblet-path: './goblet'
  report: ${{ github.sha }}
  pre-goblet: 'yarn install'
  post-goblet: 'curl -d ./goblet/reports/${{ github.sha }}.json https://my.custom.api/tests/reports/json'
```