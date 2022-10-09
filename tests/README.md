# Tests

## Setup

Make sure you run `poetry install` from the root folder of the package.

## Local Usage

```
# No stdout
$ poetry run pytest

# With stdout
$ poetry run pytest -s
```

or in the poetry shell

```
$ poetry shell
(e) $ cd tests && pytest -s
(e) exit
```

## Tox

```
# ensure python 3.10 is installed
$ tox -e py310     # tests + coverage
$ tox -e format    # formats with ufmt
$ tox -e check     # formatting, linting and mypy checkers
```
