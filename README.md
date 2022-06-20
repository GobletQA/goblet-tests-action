# Goblet Tests Action
This action executes Goblet tests for a repository within a Github action


## Inputs

### `report`
* Name of the report file generated from the test results
* **default** - `<timestamp>-goblet-report` (value of <timestamp> is generated at runtime)

### `goblet-path`
* Relative path the goblet tests folder within the repo
* **default** - `<repo-root-directory>/goblet` (value of <repo-root-directory> determined at runtime)

### `pre-goblet`
* List of bash commands to run prior to running the Goblet tests
* Allows for ensure the environment is setup for test execution

### `post-goblet`
* List of bash commands to run after the Goblet tests have finished executing
* Allows for handling reports or artifacts generated from tests execution

## Outputs

### `result`
Result of the Goblet test execution. One of `pass` or `fail`


## Example usage

```yaml
uses: actions/goblet-tests-action@v1
with:
  report: ${{ github.sha }}
  goblet-path: './goblet'
  pre-goblet: 'yarn install'
  post-goblet: 'cp curl -d ./goblet/reports/${{ github.sha }}.json https://my.custom.api/tests/reports/json'
```