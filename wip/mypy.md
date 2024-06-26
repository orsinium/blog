
```yaml
mypy-suggest:
  extends: .lint_template
  image: ${LINT_IMAGE}
  allow_failure: true
  variables:
    GIT_STRATEGY: fetch
    GIT_DEPTH: "50"
  before_script:
    - python -m pip install mypy-baseline==0.4.5
  script:
    - git config --global --add safe.directory $PWD
    - git fetch origin $CI_DEFAULT_BRANCH
    - >
      mypy-baseline suggest
      --exit-zero
      --default-branch=origin/$CI_DEFAULT_BRANCH
      --comment
  rules:
    - if: "$CI_COMMIT_REF_NAME =~ /^revert-.+/"
      when: never
    - if: "$CI_MERGE_REQUEST_ID"
      changes:
        - "**/*.py"

```
