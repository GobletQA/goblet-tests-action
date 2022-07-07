# Goblet Tests Action
This action executes Goblet tests for a repository within a Github action

## Inputs

### `goblet-test-context`
* As ENV - `GOBLET_TESTS_PATH`
* Path to the tests to run
* **default** - Runs all tests if not defined

### `git-token`
* As ENV - `GOBLET_GIT_TOKEN` || `GIT_TOKEN`
* Github Auth Token or Personal Access Token (PAT)

### `report`
* As ENV - `GOBLET_REPORT_NAME`
* Name of the report file generated from the test results
* **default** - `<timestamp>-goblet-report` (value of <timestamp> is generated at runtime)

### `alt-repo`
* As ENV - `GIT_ALT_REPO`
* Alternative repository that contains the tests to be run
* Should follow the pattern of `https://<git-token>@domain/owner/repo.git`
  * For example  `github.com/octokitty/app-tests.git`

### `alt-branch`
* As ENV - `GIT_ALT_BRANCH`
* Name of the branch to use for the alternative repository.
* Defaults to the alternative repositories default branch

### `alt-user`
* As ENV - `GIT_ALT_USER`
* Github user name or organization with write access to the alternative repository.
* Defaults to the `current git user`

### `alt-email`
* As ENV - `GIT_ALT_EMAIL`
* Email of user with write access to the alternative repository.
* Defaults to the `current git users email`

### `alt-token`
* As ENV - `GIT_ALT_TOKEN`
* Github Token with write access to the alternative repository.
* Checks the following envs in order `GIT_ALT_TOKEN`, `GOBLET_GIT_TOKEN`, `GIT_TOKEN` 

### `test-retry`
* As ENV - `GOBLET_TEST_RETRY`
* Number of times a failed test should be retried
* Defaults to `undefined` - Tests are **NOT** retried

### `test-tracing`
* As ENV - `GOBLET_TEST_TRACING`
* Enabled test tracing via playwright
* Defaults to `false`

### `test-screenshot`
* As ENV - `GOBLET_TEST_SCREENSHOT`
* Enabled browser image snapshots for failed tests. Ignored if `test-tracing` is `true`
* Defaults to `false`

### `test-record`
* As ENV - `GOBLET_TEST_VIDEO_RECORD`
* Enabled browser video recording via playwright.
* Defaults to `false`

### `test-timeout`
* As ENV - `GOBLET_TEST_TIMEOUT`
* Amount of time for a test to wait until it times out and is then marked as failed
* Defaults to `60000` milliseconds (1 min)

### `test-cache`
* As ENV - `GOBLET_TEST_CACHE`
* Use internal test cache when executing test
* Defaults to `true`

### `test-colors`
* As ENV - `GOBLET_TEST_COLORS`
* Force use of colors even when not a TTY
* Defaults to `true`

### `test-workers`
* As ENV - `GOBLET_TEST_WORKERS`
* Number of workers to use when running tests
* Defaults to `50%`

### `test-verbose`
* As ENV - `GOBLET_TEST_VERBOSE`
* Output verbose test results as the tests run
* Defaults to `false`

### `test-open-handles`
* As ENV - `GOBLET_TEST_OPEN_HANDLES`
* Detect handles left open when tests run, **AND** forces tests to run in sync.
* Defaults to `false`

### `browsers`
* As ENV - `GOBLET_BROWSERS`
* Comma separated list of Browsers to execute tests against
* Defaults to all browsers - `chrome`, `firefox` and `webkit`

### `browser-slow-mo`
* As ENV - `GOBLET_BROWSER_SLOW_MO`
* Slow down the actions executed with-in a browser while executing tests in milliseconds
* Defaults to `100` milliseconds

### `browser-concurrent:`
* As ENV - `GOBLET_BROWSER_CONCURRENT`
* Run the tests in each defined browser at the same time
* Defaults to `false`

### `browser-timeout`
* As ENV - `GOBLET_BROWSER_TIMEOUT`
* Amount of time for the browser to wait until it times out and the corresponding test fails
* Defaults to `45000` milliseconds (45 seconds)


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


