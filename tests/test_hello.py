# Copyright: 2022 Woven Planet
# License: Arene-Stub
# URL: https://github.tmc-stargate.com/arene-driving/python-zen/blob/main/LICENSE

##############################################################################
# Documentation
##############################################################################

"""Example test for an console script / entrypoint."""

##############################################################################
# Tests
##############################################################################


def test_hello(script_runner):
    ret = script_runner.run("poetry-zen-hello")
    assert ret.success
