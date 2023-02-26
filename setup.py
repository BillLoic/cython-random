import os
import warnings as warn
import subprocess

try:
    from setuptools import setup, Extension, find_packages
    
except ImportError:
    warn.warn("Can't import setup function from setuptools, "
              "trying using the provius installer distutils."
              "The distutils will be delete at Python 3.12 and newer version (PEP 632)."
              "If you want to use safe-installzation, install the setuptools first.\n"
              "See also: https://github.com/python/cpython/issues/92584", DeprecationWarning)
    try:
        from distutils.core import setup, Extension
    except Exception as error:
        raise RuntimeError(
            "The installzation was aborted, caused by %s. Please install the setuptools to continue the installzation." 
        % error)
        
try:
    from Cython.Build import cythonize
except:
    raise RuntimeError("Cython not found, run pip install cython instead.")
        
import sys as _sys
import errno as errno
from pathlib import Path
from _get_version import __version__

PY_VERSION = f"{_sys.version_info.major}.{_sys.version_info.minor}.{_sys.version_info.micro}"
if _sys.version_info.major == 2:
    warn.warn("The module was used Python 3 syntax, install the Python 3 to continue installzation.")
    _sys.exit(errno.EPERM)
    
CWD = Path(os.path.dirname(os.path.abspath(__file__)))
MOD_DIR = CWD / "cyrandom"

extfile_fextension = tuple([".pyx", ".pxd"])

CLASSIFIERS = """

Development Status :: 5 - Production/Stable
Intended Audience :: Science/Research
Intended Audience :: Developers
License :: OSI Approved :: BSD License
Programming Language :: C
Programming Language :: Python
Programming Language :: Python :: 3
Programming Language :: Python :: 3.8
Programming Language :: Python :: 3.9
Programming Language :: Python :: 3.10
Programming Language :: Python :: 3.11
Programming Language :: Python :: 3 :: Only
Programming Language :: Python :: Implementation :: CPython
Topic :: Software Development
Topic :: Scientific/Engineering
Typing :: Typed
Operating System :: Microsoft :: Windows
Operating System :: POSIX
Operating System :: Unix
Operating System :: MacOS
"""

def find_extensions():
    """
    Find cython extension file.
    """
    for (root, dirs, files) in os.walk("."):
        for file in files:
            if file.endswith(extfile_fextension):
                yield os.path.abspath(os.path.join(root, file))
    
def main():
    extension_files = list(find_extensions())
    setup(
        name="cyrandom", 
        classifiers=CLASSIFIERS.split("\n"), 
        ext_modules=cythonize(extension_files),
        packages=find_packages(), 
        version=__version__
    )    
    
if __name__ == "__main__":
    main()