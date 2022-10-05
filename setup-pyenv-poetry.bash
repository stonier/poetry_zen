#!/bin/bash

# Script for installing pyenv and poetry.
# Tested and supported for MAC and Ubuntu
# NB: Poetry requires a python3 installed to bootstrap. This uses
# a system python3 to do so.

SRC_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REFRESH_SHELL=0

##############################################################################
# Colours
##############################################################################

BOLD="\e[1m"
CYAN="\e[36m"
GREEN="\e[32m"
RED="\e[31m"
YELLOW="\e[33m"
RESET="\e[0m"

padded_message ()
{
  line="........................................"
  printf "%s %s${2}\n" ${1} "${line:${#1}}"
}

pretty_header () { printf "${BOLD}${1}${RESET}\n" ; }
pretty_print () { printf "${GREEN}${1}${RESET}\n" ; }
pretty_warning () { printf "${YELLOW}${1}${RESET}\n" ; }
pretty_error () { printf "${RED}${1}${RESET}\n" ; }

##############################################################################
# Methods
##############################################################################

install_pyenv ()
{
  PACKAGE_NAME=pyenv
  PYENV_ROOT=~/.pyenv
  if [ ! -d "${PYENV_ROOT}" ]; then
    curl https://pyenv.run | bash
    if [ $? -ne 0 ]; then
      pretty_error "  $(padded_message ${PACKAGE_NAME} "failed")"
      return 1
    else
      pretty_warning "  $(padded_message ${PACKAGE_NAME} "installed")"
      return 0
    fi
  fi
  pretty_print "  $(padded_message ${PACKAGE_NAME} "found")"
  return 0
}

# Installs an implicit lookup strategy for the shims in ~/.pyenv/shims so,
# e.g. python3.10 works regardless of what python version is selected.
install_pyenv_implicit () {
  PLUGINS_DIR=~/.pyenv/plugins
  NAME=pyenv-implict
  if [ ! -d "${PLUGINS_DIR}/${NAME}" ]; then
    pretty_print "Installing ${PLUGINS_DIR}"
    git clone https://github.com/concordusapps/pyenv-implict.git ${PLUGINS_DIR}/${NAME}
    pretty_warning "  $(padded_message ${NAME} "installed")"
  else
    pretty_print "  $(padded_message ${NAME} "found")"
  fi
  return 0
}

install_python_versions()
{
  VERSIONS=$1
  for VERSION in ${VERSIONS[@]}; do
    INSTALLED=`pyenv versions`
    grep -q "${VERSION}" <<< ${INSTALLED}
    if [ $? -ne 0 ]; then
      pyenv install ${VERSION}
      if [ $? -ne 0 ]; then
        pretty_error "  $(padded_message python-${VERSION} "failed")"
        return 1
      else
        pretty_warning "  $(padded_message python-${VERSION} "installed")"
      fi
    else
        pretty_print "  $(padded_message python-${VERSION} "found")"
    fi
  done
}

setup_pyenv()
{
  ACTION=pyenv-setup
  command -v pyenv >/dev/null
  if [ $? -ne 0 ]; then
    echo 'export PATH="${HOME}/.pyenv/bin:${PATH}"' >> ${HOME}/.profile
    echo 'eval "$(pyenv init -)"' >> ${HOME}/.profile
    # echo 'eval "$(pyenv virtualenv-init -)"' >> ${HOME}/.profile  # Not needed if using poetry

    # refresh the current shell at the end of this script
    REFRESH_SHELL=1

    # Setup paths for this script, since it wasn't yet present
    export PATH="~/.pyenv/bin:${PATH}"
    pretty_warning "  $(padded_message ${ACTION} "setup [~/.profile]")"
  else
    pretty_print "  $(padded_message ${ACTION} "found")"
  fi
  eval "$(pyenv init -)"
}

update_pyenv()
{
  ACTION=pyenv-update
  RESULT=`pyenv update`
  if [ $? -ne 0 ]; then
    pretty_error "  $(padded_message ${ACTION} "failed")"
    return 0
  fi
  # not checking to see if it was updated or not
  pretty_warning "  $(padded_message ${ACTION} "updated")"
  return 0
}

install_poetry ()
{
  # use pipx once 18.04 is left behind?
  PACKAGE_NAME="poetry"
  POETRY=`which ${PACKAGE_NAME}`
  if [ $? -ne 0 ]; then
    # Use POETRY_HOME to redirect the installation
    # curl -sSL https://install.python-poetry.org | POETRY_HOME=${SRC_DIR}/.poetry python3 -
    curl -sSL https://install.python-poetry.org | python3 -
    if [ $? -ne 0 ]; then
      pretty_error "  $(padded_message ${PACKAGE_NAME} "failed")"
      return 1
    fi
  else
    pretty_print "  $(padded_message ${PACKAGE_NAME} "found [${POETRY}]")"
    return 0
  fi
  POETRY=`which ${PACKAGE_NAME}`
  if [ $? -ne 0 ]; then
    export PATH="${HOME}/.local/bin:${PATH}"  # for use in this script
    echo 'export PATH="${HOME}/.local/bin:${PATH}"' >> ~/.profile
  fi
  POETRY=`which ${PACKAGE_NAME}`
  pretty_warning "  $(padded_message ${PACKAGE_NAME} "installed [${POETRY}]")"
  return 0
}

update_poetry ()
{
  ACTION="poetry-update"
  VERSION=`poetry --version`
  RESULT=`poetry self update`
  if [ $? -ne 0 ]; then
    pretty_error "  $(padded_message ${ACTION} "failed")"
    return 1
  else
    grep -q "No dependencies" <<< ${RESULT}
    if [ $? -ne 0 ]; then
      VERSION=`poetry --version`
      pretty_warning "  $(padded_message ${ACTION} "updated [${VERSION}]")"
      return 0
    else
      pretty_print "  $(padded_message ${ACTION} "up-to-date [${VERSION}]")"
      return 0
    fi   
  fi
  return 0
}

check_system_dependency ()
{
  PACKAGE_NAME=$1
  $PACKAGE_NAME --help > /dev/null 2>&1
  if [ $? -ne 0 ]; then
    pretty_error "  $(padded_message ${PACKAGE_NAME} "missing (please install)")"
    return 1
  else
    pretty_print "  $(padded_message ${PACKAGE_NAME} "found")"
    return 0
  fi
}


##############################################################################

pretty_header "System Dependencies"

check_system_dependency curl || exit 1
check_system_dependency git || exit 1

# No system python needed, we'll use pyenv to bootstrap poetry

pretty_header "User Dependencies"

install_pyenv
install_pyenv_implicit
setup_pyenv
# Don't use -dev versions, they install with a + suffixed to the version number.
# Poetry throws a PEP440 tanty fit at, for example, a python version of 3.10.6+.
declare -a VERSIONS=("3.8.13" "3.10.6")
install_python_versions ${VERSIONS}
# update_pyenv  # this is slow

pyenv shell 3.8.13  # bootstrap poetry off pyenv instead of a system python
install_poetry
update_poetry

pretty_header "Finalising"

if [ "$((1 + $RANDOM % 5))" -eq "1" ]; then
  pretty_error "  $(padded_message "pastafarian_presence_detected" "no [uh-oh, quick, don yourself a colander!]")"
else
  pretty_print "  $(padded_message "pastafarian_presence_detected" "yes")"
fi
# Refresh the current shell if .profile was updated
if [ ${REFRESH_SHELL} -ne 0 ]; then
  pretty_warning "  $(padded_message "refresh_shell" "yes [re-login to catch ~/.profile in future]")"
  exec /bin/bash --login
else
  pretty_print "  $(padded_message "refresh_shell" "no [not needed]")"
fi
