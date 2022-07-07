# Goblet Tests Action
This action executes Goblet tests for a repository within a Github action

## Inputs

### `goblet-test-context`
* Path to the tests to run
* **default** - Runs all tests if not defined


### `git-token`
* Github Auth Token or Personal Access Token (PAT)

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
* Alternative repository that contains the tests to be run.
* Should follow the pattern of `https://<git-token>@domain/owner/repo.git`
  * For example  `github.com/octokitty/app-tests.git`

### `alt-branch`
* Name of the branch to use for the alternative repository.
* Defaults to the alternative repositories default branch

### `alt-user`
* Github user name or organization with write access to the alternative repository.
* Defaults to the current user

### `alt-email`
* Email of user with write access to the alternative repository.
* Defaults to the current users email

### `alt-token`
* Github Token with write access to the alternative repository.
* Checks the following envs in order `GIT_ALT_TOKEN`, `GOBLET_GIT_TOKEN`, `GIT_TOKEN` 


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

### Basic
```yaml
uses: actions/goblet-tests-action@v1
with:
  report: ${{ github.sha }}
```


### Alt repo
```yaml
uses: actions/goblet-tests-action@v1
with:
  alt-branch: develop # defaults to the repos default branch branch. I.E. main / master
  alt-repo: github.com/octokitty/app-tests # URI to the repo, EXCLUDING the protocol I.E. github.com/owner/repo.git
  alt-token: secrets.ALT_TEST_REPO_TOKEN # Must be a OAuth or PAT that has access to the alternative repository
  alt-user: secrets.ALT_TEST_USER # User related to the git token used for the `alt-token` input
  alt-email: secrets.ALT_TEST_EMAIL # Email related to the git token used for the `alt-token` input and user
``` 


