#!/usr/bin/env python3
#
# Copyright © 2013–2017 Frederik “Freso” S. Olesen <https://freso.dk/>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to
# deal in the Software without restriction, including without limitation the
# rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
# sell copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
# FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
# DEALINGS IN THE SOFTWARE.
"""Unit tests for the rip-disc.py ripping helper script."""

import unittest

class BasicTest(unittest.TestCase):
    """Basic functionality and sanity testing of rip-disc.py."""

    def test_import(self):
        """Test whether rip-disc.py is a proper Python module."""
        from importlib import import_module
        import_module("rip-disc")


class MainTest(unittest.TestCase):
    """Test the rip-disc.main() function."""

    def test_main(self):
        """Test rip-disc's main() function."""
        from importlib import import_module
        ripdisc = import_module("rip-disc")

        ripdisc.main()


if __name__ == '__main__':
    unittest.main()
