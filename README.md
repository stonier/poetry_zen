# PyEnv + Poetry

## Resources

* [Pyenv Docs](https://github.com/pyenv/pyenv)
* [Poetry Docs](https://python-poetry.org/docs/)

## Overview

* **PyEnv** - Manages python installations. Alternatively, you could use system python versions.
* **Poetry** - Virtual environments, Package Configuration, Dependency Solver, Packaging Tool

For comparison, Poetry consolidates the responsibilities of venv, requirements.txt, setuptools, pip, twine in one tool.
It also simplifies many of these processes.

## Usage

**Setup**

The rest of this assumes you have both pyenv and poetry installed. They do not come with ubuntu debs.
If you haven't got them already, use the `setup-pyenv-poetry.bash` script provided here.
NB: This will also install [pyenv-implct](https://github.com/concordusapps/pyenv-implict), a plugin
that allows poetry to use, in parallel, pyenv installed versions without having to explicitly switch.
It will also have pyenv install `3.6.15`, `3.8.13`, `3.10.6` versions of python.

**Python Switching - Implicit**

NB: This requires the `pyenv-implct` plugin installed in setup above!

So long as you don't have multiple patch versions of python installed (e.g. `python 3.8.10` and
`python 3.8.13`) then you can switch between environments using pyenvs shims (in `~/.pyenv/shims`)
and poetry itself. There is no need to explicitly select a version in pyenv.

```
# py3.6 and py3.10 on this machine are implicitly switchable
$ pyenv versions
* system (set by /home/danielstonier/.pyenv/version - 3.8.10)
  3.6.15
  3.8.13
  3.10.6
```

```
$ poetry env use 3.10
$ poetry install
$ poetry shell
$ (e) poetry-zen-hello
Hello Foo
Version: sys.version_info(major=3, minor=10, micro=6, releaselevel='final', serial=0)
$ (e) exit

$ poetry env use 3.6
$ poetry install
$ poetry shell
$ (e) poetry-zen-hello
Hello Foo
Version: sys.version_info(major=3, minor=6, micro=15, releaselevel='final', serial=0)
# (e) exit
```

**Python Switching - Explicit**

```
# Example - System 3.8.10 and Pyenv 3.8.13 exist, you will need to explicitly force a version

# 'local' or 'global' works too
$ pyenv shell 3.8.13
$ pyenv versions
  system (3.8.10)
  3.6.15
* 3.8.13 (set by PYENV_VERSION environment variable)
  3.10.6

$ poetry env use 3.8.13
$ poetry install
$ poetry shell
$ poetry-zen-hello
Hello Foo
Version: sys.version_info(major=3, minor=8, micro=13, releaselevel='final', serial=0)
$ exit
```
## Reference - PyEnv

**Installation**

* Installs via script to `~/.pyenv`
* Manual configuration required for your local shell or in `~/.profile`

**Uninstall**

* `rm -rf ~/.pyenv`
* Remove additions to ~/.profile`

**Versions**

* Defaults to your system version if that is installed
* `pyenv versions` to see what is available to switch to
* `pyenv install --list` to see installable options
* Using `3.8-dev` will install the latest, but -dev versions do not work with poetry

## Reference - Poetry

**Installation**

Can be installed via script or pipx (20.04 or later).

* Requires a pre-installed version of `python3`
* Via script, it installs to `~/.local`, see `devenv.bash` in this folder
* Poetry deps are isolated in `~/.local/share/pypoetry`

**Update**

* `poetry self update`

**Uninstall**

* `curl -sSL https://install.python-poetry.org | python3 - --uninstall`

**Virtual Environment**

* Saved in `~/.cache/pypoetry/virtualenvs/<name>-<id>-<pyversion>/`.
* List venvs with `poetry env list`.
* Switch with `poetry env use <...>`.
* Enter with `poetry shell`.


## Reference - Poetry vs SetupTools

**Dependency Checks Across Python Versions**

Dependency checks work across the range of python versions specified in `pyproject.toml`, not just the actively referenced python version. This is really nice - you can catch dependency problems proactively, even without installing the various python versions.

```
Using version ^1.12.2 for streamlit

Updating dependencies
Resolving dependencies... (0.0s)

  SolverProblemError

  The current project's Python requirement (>=3.8,<4.0) is not compatible with some of the required packages Python requirement:
    - streamlit requires Python >=3.7, !=3.9.7, so it will not be satisfied for Python 3.9.7

  Because streamlit (1.12.2) requires Python >=3.7, !=3.9.7
   and no versions of streamlit match >1.12.2,<2.0.0, streamlit is forbidden.
  So, because poetry_zen depends on streamlit (^1.12.2), version solving failed.
```

**Entry Points**

Use the following config and run it with `poetry run poetry-zen-hello`.

```
[tool.poetry.scripts]
poetry-zen-hello = "poetry_zen.hello:main"
```

**Dependencies**

Despite being declarative, there are built-in mechansims for declaring dependencies that in turn, depend on
a python, or platform:

```
[tool.poetry.dependencies]
pathlib2 = { version = "^2.2", markers = "python_version ~= '2.7' or sys_platform == 'win32'"
```

## Final Thoughts

* No system packaging for pyenv or poetry - it's all magic scripts, ugh
* Poetry uses a declarative format for project configuration (`pyproject.toml`).
  There are times when you might need the flexibility of `setup.py` to programmatically setup your package.
