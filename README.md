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
* **default** - `undefined`

### `alt-repo`
* As ENV - `GIT_ALT_REPO`
* Alternative repository that contains the tests to be run
* Should follow the pattern of `https://<git-token>@domain/owner/repo.git`
  * For example  `github.com/octokitty/app-tests.git`
* **default** - `undefined`

### `alt-branch`
* As ENV - `GIT_ALT_BRANCH`
* Name of the branch to use for the alternative repository.
* **default** - The alternative repositories default branch

### `alt-user`
* As ENV - `GIT_ALT_USER`
* Github user name or organization with write access to the alternative repository.
* **default** - current `git user`

### `alt-email`
* As ENV - `GIT_ALT_EMAIL`
* Email of user with write access to the alternative repository.
* **default** - current `git users email`

### `alt-token`
* As ENV - `GIT_ALT_TOKEN`
* Github Token with write access to the alternative repository.
* Checks the following envs in order `GIT_ALT_TOKEN`, `GOBLET_GIT_TOKEN`, `GIT_TOKEN` 
* **default** - Value of the `git-token` input

### `test-type`
* Type of tests to be run that are supported by the Goblet Platform
* Can be one of `bdd`, `waypoint`, or `unit`
* **default** - `bdd`

### `test-retry`
* As ENV - `GOBLET_TEST_RETRY`
* Number of times a failed test should be retried
* **default** - `undefined` - Tests are **NOT** retried

### `test-report`
* As ENV - `GOBLET_TEST_REPORT`
* Generate an html formatted test report for all executed tests 
* Value must be one of `true` | `1` | `failed` | `always` | `never` | `0` | `false`
  * `failed` - Enable only for test runs that failed
    * **IMPORTANT** - Both `true` | `1` are synonyms of `failed`
  * `alway` - Enable regardless of `pass` or `fail` test status
  * `never` - Disabled regardless of `pass` or `fail` test status
    * **IMPORTANT** - Both `false` | `0` are synonyms of `never`
* **default** - `false`

### `test-tracing`
* As ENV - `GOBLET_TEST_TRACING`
* Enabled test tracing via playwright. See more [here](https://playwright.dev/docs/api/class-tracing)
* Value must be one of `true` | `1` | `failed` | `always` | `never` | `0` | `false`
  * `failed` - Enable only for tests that failed
    * **IMPORTANT** - Both `true` | `1` are synonyms of `failed`
  * `alway` - Enable regardless of `pass` or `fail` test status
  * `never` - Disabled regardless of `pass` or `fail` test status
    * **IMPORTANT** - Both `false` | `0` are synonyms of `never`
* **default** - `false`

### `test-screenshot`
* **IMPORTANT** - Not currently implemented. Use `test-tracing` instead
* As ENV - `GOBLET_TEST_SCREENSHOT`
* Enabled browser image snapshots for failed tests. Ignored if `test-tracing` is `true`
* Value must be one of `true` | `1` | `failed` | `always` | `never` | `0` | `false`
  * `failed` - Enable only for tests that failed
    * **IMPORTANT** - Both `true` | `1` are synonyms of `failed`
  * `alway` - Enable regardless of `pass` or `fail` test status
  * `never` - Disabled regardless of `pass` or `fail` test status
    * **IMPORTANT** - Both `false` | `0` are synonyms of `never`
* **default** - `false`

### `test-record`
* As ENV - `GOBLET_TEST_VIDEO_RECORD`
* Enabled browser video recording via playwright
* Value must be one of `true` | `1` | `failed` | `always` | `never` | `0` | `false`
  * `failed` - Enable only for tests that failed
    * **IMPORTANT** - Both `true` | `1` are synonyms of `failed`
  * `alway` - Enable regardless of `pass` or `fail` test status
  * `never` - Disabled regardless of `pass` or `fail` test status
    * **IMPORTANT** - Both `false` | `0` are synonyms of `never`
* **default** - `false`

### `test-timeout`
* As ENV - `GOBLET_TEST_TIMEOUT`
* Amount of time for a test to wait until it times out and is then marked as failed
* **default** - `30000` milliseconds (30 seconds)

### `test-cache`
* As ENV - `GOBLET_TEST_CACHE`
* Use internal test cache when executing test
* **default** - `true`

### `test-colors`
* As ENV - `GOBLET_TEST_COLORS`
* Force use of colors even when not a TTY
* **default** - `true`

### `test-workers`
* As ENV - `GOBLET_TEST_WORKERS`
* Number of workers to use when running tests
* **default** - `50%`

### `test-verbose`
* As ENV - `GOBLET_TEST_VERBOSE`
* Output verbose test results as the tests run
* **default** - `false`

### `test-open-handles`
* As ENV - `GOBLET_TEST_OPEN_HANDLES`
* Detect handles left open when tests run, **AND** forces tests to run in sync.
* **default** - `false`

### `browsers`
* As ENV - `GOBLET_BROWSERS`
* Comma separated list of Browsers to execute tests against
* **default** - all browsers - `chrome`, `firefox` and `webkit`

### `browser-debug`
* As ENV - `GOBLET_BROWSER_DEBUG`
* Log the debug output of the playwright browser
* **default** - `false`

### `browser-slow-mo`
* As ENV - `GOBLET_BROWSER_SLOW_MO`
* Slow down the actions executed with-in a browser while executing tests in milliseconds
* **default** - `100` milliseconds

### `browser-concurrent:`
* As ENV - `GOBLET_BROWSER_CONCURRENT`
* Run the tests in each defined browser at the same time
* **default** - `false`

### `browser-timeout`
* As ENV - `GOBLET_BROWSER_TIMEOUT`
* Amount of time for the browser to wait until it times out and the corresponding test fails
* **default** - `15000` milliseconds (15 seconds)

### `artifacts-debug`
* As ENV - `GOBLET_ARTIFACTS_DEBUG`
* Enable debug logging for all generated artifacts
* **default** - `false`

## Outputs
* **IMPORTANT** - Because multiple paths can be exported, the outputs are first escaped prior to being set
  * This ensures all paths are included in the output
  * See [here](https://github.community/t/set-output-truncates-multiline-strings/16852) and [here](https://github.community/t/what-is-the-correct-character-escaping-for-workflow-command-values-e-g-echo-xxxx/118465/4) for more information
* **Important** - The output paths are relative to the active workspace
  * In docker the path output is relative to `/github/workspace`
  * In an action path output  is relative to `/home/runner/work/<repo-name>/<repo-name>`
    * The `<repo-name>` should be replace with the name of the repository running the action
### `result`
* Result of the Goblet test execution. One of `pass` or `fail`

### `artifacts-path`
* Relative path to the generated **artifacts** directory

### `report-paths`
* **Important** - The `test-report` input must be set to `true`
* Paths to the generated html test reports for each browser relative to the active workspace directory
* A single report is created for **ALL** test files that are run
* Examples
  * Output with all browsers
    * Escaped Output
    ```sh
      goblet/reports/feature/test/test-chromium-1657592644482.html%0Agoblet/reports/feature/test/test-webkit-1657592644482.html%0Agoblet/reports/feature/test/test-firefox-1657592644482.html
    ```
    * Unescaped Output
    ```sh
      goblet/reports/feature/test/test-chromium-1657592644482.html
      goblet/reports/feature/test/test-webkit-1657592644482.html
      goblet/reports/feature/test/test-firefox-1657592644482.html
    ```
  * Output with only Webkit browser
    * Unescaped and Escaped Output is the same
    ```sh
      goblet/reports/feature/test/test-webkit-1657584807895.html
    ```

### `trace-paths`
* **Important** - The `test-tracing` input must be set to `true`
* Paths of the generated playwright traces of executed tests relative to the active workspace directory
* Separate traces are created for **EVERY** test file that is run
* Examples
  * Output with all browsers
    * Escaped Output
    ```sh
      goblet/artifacts/traces/bdd/test/test-chromium-1657592733262.zip%0Agoblet/artifacts/traces/bdd/test/test-webkit-1657592734085.zip%0Agoblet/reports/traces/bdd/test/test-firefox-1657590811091.zip
    ```
    * Unescaped Output
    ```sh
      goblet/artifacts/traces/bdd/test/test-chromium-1657592733262.zip
      goblet/artifacts/traces/bdd/test/test-webkit-1657592734085.zip
      goblet/artifacts/traces/bdd/test/test-firefox-1657590811091.zip
    ```
  * Output with only Webkit browser
    * Unescaped and Escaped Output is the same
    ```sh
      goblet/artifacts/traces/bdd/test/test-webkit-1657592734085.zip
    ```


### `video-paths`
* **Important** - The `test-record` input must be set to `true`
* Paths to the video recordings of executed tests relative to the active workspace directory
* Separate videos are recorded for **EVERY** test file that is run
* Examples
  * Output with all browsers
    * Escaped Output
    ```sh
      goblet/artifacts/videos/bdd/test/test-webkit-1657592734085.webm%0Agoblet/artifacts/videos/bdd/test/test-chromium-1657592733262.webm%0Agoblet/artifacts/videos/bdd/test/test-firefox-1657591132585.webm
    ```
    * Unescaped Output
    ```sh
      goblet/artifacts/videos/bdd/test/test-chromium-1657592733262.webm
      goblet/artifacts/videos/bdd/test/test-webkit-1657592734085.webm
      goblet/artifacts/videos/bdd/test/test-firefox-1657591132585.webm
    ```
  * Output with only Webkit browser
    * Unescaped and Escaped Output is the same
    ```sh
      goblet/artifacts/videos/bdd/test/test-webkit-1657592734085.webm
    ```

## Alt-Repo Outputs
* This Action runs within a docker container
* It get's access the the underlying repository via a volume mount to `/github/workspace`
  * I.E. given our repo name is `test-repo` located at `/home/runner/work/test-repo/test-repo`
  * The repo is by default mounted **(via github)** to `/github/workspace` within the docker container
  * This unfortunately is not configurable
  * This can be seen in the docker command that is run, and looks similar to
    * `-v "/home/runner/work/test-repo/test-repo":"/github/workspace"`
* When **NOT** using an **Alt-Repo**, generated **artifacts** are saved to `/github/workspace/goblet/artifacts`
  * Because of how docker volumes work this makes them available to future steps of a workflow
* When using an **Alt-Repo**, generated **artifacts** are placed at `/github/alt/goblet/artifacts`
  * They are then copied into the **same** save location at `/github/workspace/goblet/artifacts`
  * Which allows them to be accessible to future steps of a workflow
  * **IMPORTANT** - The copy process is a `forced` / `overwrite`
    * Any existing files with the same name **will** be overwritten

## Example usage

### Basic
```yaml
- name: Run Goblet Tests
  uses: gobletqa/goblet-tests-action@0.0.1
  with:
    test-context: goblet # All tests with the word `goblet` in their path will be run
    test-report: failed
- if: ${{ steps.dashboard-tests.outputs.result }} === 'failed'
  name: Do something with outputs
  with:
    run: |
      echo ${{ steps.dashboard-tests.outputs.report-paths }}
```

### With Tracing and Video Recording
```yaml
- name: Run Goblet Tests
  uses: gobletqa/goblet-tests-action@0.0.1
  with:
    git-token: ${{ github.token }}
    test-tracing: always
    test-record: always
- if: always()
  name: Do something with output
  with:
    run: |
      echo ${{ steps.dashboard-tests.outputs.trace-paths }}
      echo ${{ steps.dashboard-tests.outputs.video-paths }}
```

### Alt-Repo
```yaml
    steps:

    - name: Run Dashboard Tests
      id: dashboard-tests
      uses: gobletqa/goblet-tests-action@0.0.6
      with:
        alt-branch: new-feat-branch # Branch that contains the tests to be run
        alt-repo: github.com/gobletqa/repo-tests
        alt-branch: develop # Defaults to the repos default branch branch. I.E. main / master
        alt-repo: github.com/octokitty/app-tests # URI to the repo, EXCLUDING the protocol I.E. github.com/owner/repo.git
        alt-token: ${{ secrets.ALT_GH_AUTH_PAT }} # Must be a OAuth or PAT that has access to the alternative repository
        git-token: ${{ secrets.GH_AUTH_PAT }} # Must be a OAuth or PAT for the current repository
        test-report: failed
        test-tracing: failed
        test-record: failed

    - name: Commit SHA
      if: always()
      id: commit-sha
      run: echo "::set-output name=sha::$(git rev-parse --short HEAD)"

    - uses: actions/upload-artifact@v3
      if: always()
      name: Upload Failed Tests
      with:
        name: repo-tests-${{ steps.commit-sha.outputs.sha }}
        path: |
          ${{ steps.dashboard-tests.outputs.report-paths }}
          ${{ steps.dashboard-tests.outputs.trace-paths }}
          ${{ steps.dashboard-tests.outputs.video-paths }}
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
