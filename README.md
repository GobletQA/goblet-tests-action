# Goblet Tests Action
* This action executes Goblet tests for a repository within a Github action

## Inputs

### `test-context`
* As ENV - `GOBLET_TESTS_PATH`
* Path to the tests to run
* **default** - Runs all tests if not defined

### `git-token`
* As ENV - `GOBLET_GIT_TOKEN` || `GIT_TOKEN`
* Github Auth Token or Personal Access Token (PAT)

### `report`
* As ENV - `GOBLET_TEST_REPORT_NAME`
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

### `test-type`
* Type of tests to be run that are supported by the Goblet Platform
* Can be one of `bdd`, `waypoint`, or `unit`
* Default to `bdd`

### `test-retry`
* As ENV - `GOBLET_TEST_RETRY`
* Number of times a failed test should be retried
* Defaults to `undefined` - Tests are **NOT** retried

### `test-tracing`
* As ENV - `GOBLET_TEST_TRACING`
* Enabled test tracing via playwright. See more [here](https://playwright.dev/docs/api/class-tracing)
* Defaults to `false`

### `test-screenshot`
* **IMPORTANT** - Not currently implemented. Use `test-tracing` instead
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
* Defaults to `30000` milliseconds (30 seconds)

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

### `browser-debug`
* As ENV - `GOBLET_BROWSER_DEBUG`
* Log the debug output of the playwright browser
* Defaults to `false`

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
* Defaults to `15000` milliseconds (15 seconds)


## Outputs
* **IMPORTANT** - Because multiple paths can be exported, the outputs are first escaped prior to being set
* This ensures all paths are included in the ouput.
* See [here](https://github.community/t/set-output-truncates-multiline-strings/16852) and [here](https://github.community/t/what-is-the-correct-character-escaping-for-workflow-command-values-e-g-echo-xxxx/118465/4) for more information

### `result`
* Result of the Goblet test execution. One of `pass` or `fail`

### `report-paths`
* Paths to the generated html test reports for each browser that ran
* A single report is created for **ALL** test files that are run
* Examples
  * Output with all browsers
    * Escaped Output
    ```sh
      /home/runner/work/goblet/repo/goblet/reports/feature/test/test-chromium-1657592644482.html%0A/home/runner/work/goblet/repo/goblet/reports/feature/test/test-webkit-1657592644482.html%0A/home/runner/work/goblet/repo/goblet/reports/feature/test/test-firefox-1657592644482.html
    ```
    * Unescaped Output
    ```sh
      /home/runner/work/goblet/repo/goblet/reports/feature/test/test-chromium-1657592644482.html
      /home/runner/work/goblet/repo/goblet/reports/feature/test/test-webkit-1657592644482.html
      /home/runner/work/goblet/repo/goblet/reports/feature/test/test-firefox-1657592644482.html
    ```
  * Output with only Webkit browser
    * Unescaped and Escaped Output is the same
    ```sh
      /home/runner/work/goblet/repo/goblet/reports/feature/test/test-webkit-1657584807895.html
    ```

### `trace-paths`
* Paths of the generated playwright traces when trace is enabled
* Separate traces are created for **EVERY** test file that is run
* Examples
  * Output with all browsers
    * Escaped Output
    ```sh
      /home/runner/work/goblet/repo/goblet/artifacts/traces/bdd/test/test-chromium-1657592733262.zip%0A/home/runner/work/goblet/repo/goblet/artifacts/traces/bdd/test/test-webkit-1657592734085.zip%0A/home/runner/work/goblet/repo/goblet/reports/traces/bdd/test/test-firefox-1657590811091.zip
    ```
    * Unescaped Output
    ```sh
      /home/runner/work/goblet/repo/goblet/artifacts/traces/bdd/test/test-chromium-1657592733262.zip
      /home/runner/work/goblet/repo/goblet/artifacts/traces/bdd/test/test-webkit-1657592734085.zip
      /home/runner/work/goblet/repo/goblet/artifacts/traces/bdd/test/test-firefox-1657590811091.zip
    ```
  * Output with only Webkit browser
    * Unescaped and Escaped Output is the same
    ```sh
      /home/runner/work/goblet/repo/goblet/artifacts/traces/bdd/test/test-webkit-1657592734085.zip
    ```


### `video-paths`
* Paths to the video recordings of executed tests when video record is enabled
* Separate videos are recorded for **EVERY** test file that is run
* Examples
  * Output with all browsers
    * Escaped Output
    ```sh
      /home/runner/work/goblet/repo/goblet/artifacts/videos/bdd/test/test-webkit-1657592734085.webm%0A/home/runner/work/goblet/repo/goblet/artifacts/videos/bdd/test/test-chromium-1657592733262.webm%0A/home/runner/work/goblet/repo/goblet/artifacts/videos/bdd/test/test-firefox-1657591132585.webm
    ```
    * Unescaped Output
    ```sh
      /home/runner/work/goblet/repo/goblet/artifacts/videos/bdd/test/test-chromium-1657592733262.webm
      /home/runner/work/goblet/repo/goblet/artifacts/videos/bdd/test/test-webkit-1657592734085.webm
      /home/runner/work/goblet/repo/goblet/artifacts/videos/bdd/test/test-firefox-1657591132585.webm
    ```
  * Output with only Webkit browser
    * Unescaped and Escaped Output is the same
    ```sh
      /home/runner/work/goblet/repo/goblet/artifacts/videos/bdd/test/test-webkit-1657592734085.webm
    ```



## Example usage

### Basic
```yaml
- name: Run Goblet Tests
  uses: gobletqa/goblet-tests-action@0.0.1
  with:
    report: ${{ github.sha }}
```

### With Tracing and Video Recording
```yaml
- name: Run Goblet Tests
  uses: gobletqa/goblet-tests-action@0.0.1
  with:
    git-token: ${{ github.token }}
    test-tracing: true
    test-record: true
```

### Alt repo
```yaml
- name: Run Goblet Tests
  uses: gobletqa/goblet-tests-action@0.0.1
  with:
    alt-branch: develop # defaults to the repos default branch branch. I.E. main / master
    alt-repo: github.com/octokitty/app-tests # URI to the repo, EXCLUDING the protocol I.E. github.com/owner/repo.git
    alt-token: secrets.ALT_TEST_REPO_TOKEN # Must be a OAuth or PAT that has access to the alternative repository
    alt-user: secrets.ALT_TEST_USER # User related to the git token used for the `alt-token` input
    alt-email: secrets.ALT_TEST_EMAIL # Email related to the git token used for the `alt-token` input and user
``` 

## Local Development
### Requirements
* The `keg-cli`, `docker`, and `yarn` must be installed locally
  * You must also login to the container registry with a user that has access to the GobletQA repo and container registry 
* A local copy of the core GobletQA repo 

### Setup
* The `/scripts` folder contains a number of helper scripts to manage the Docker image
* These scripts should be executed via yarn, as shown below
  * `yarn docker:run` || `yarn dr` - Runs the built docker image and automatically executes the goblet tests 
  * `yarn docker:dev` || `yarn dd` - Runs the built docker image and attaches to a `bash` shell
    * `/goblet-action/entrypoint.sh` - To manually run tests, when connected to the container
      * Example: `GOBLET_BROWSERS=chrome /goblet-action/entrypoint.sh test.feature`
