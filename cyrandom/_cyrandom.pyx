"""
# Cyrandom

A cython random module for python.

# SpeedTests

 - Test 1: Cyrandom vs python standard random
`python
>>> # 4096 bit integer generation
>>> import random
>>> import time
>>> import cyrandom
>>> def makearray_std(sz=100):
...    return [random.randint(-2**511, 2**511-1) for _ in range(sz)]
...
>>> def timer(f, args=[], kw={}):
...    t1 = time.time()
...    r = f(*args, **kw)
...    return time.time()-t1
... 
>>> timer(makearray_std, [100000]), timer(cyrandom.randarray, [512, 100000])
(1.8806941509246826, 0.18745684623718262)
`
`Cyrandom` is faster than standard-library `random` 10.22x
 - Test 2: Cyrandom vs numpy
 `python
>>> import numpy.random as npr
>>> import cyrandom
>>> # 16384 bit number generation
>>> npr.randint(-2**4095, 2**4095-1)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "mtrand.pyx", line 763, in numpy.random.mtrand.RandomState.randint
  File "_bounded_integers.pyx", line 1334, in numpy.random._bounded_integers._rand_int32
ValueError: low is out of bounds for int32
>>> cyrandom.randint(4096)
--- skip ---`
"""

from secrets import token_bytes, choice
from struct import unpack
from collections import namedtuple
from sys import byteorder, set_int_max_str_digits, get_int_max_str_digits
from typing import Type
import os

cdef str BYTEORDER = byteorder

cdef str allow_char = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_-"

CType = namedtuple("CType", ["struct_format", "sizeof"])

CTYPE_UNSIGNED_SHORT = CType("H", 2)
CTYPE_SHORT = CType("h", 2)
CTYPE_INT = CType("i", 4)
CTYPE_UNSIGNED_INT = CType("I", 4)
CTYPE_LONG = CType("l", 4)
CTYPE_UNSIGNED_LONG = CType("L", 4)
CTYPE_LONG_LONG = CType("q", 8)
CTYPE_UNSIGNED_LONG_LONG = CType("Q", 8)
CTYPE_BINARY16 = CType("e", 2)
CTYPE_HALF = CTYPE_BINARY16
CTYPE_FLOAT = CType("f", 4)
CTYPE_DOUBLE = CType("d", 8)
CTYPE_CHAR = CType("c", 1)

cpdef _randbits(unsigned int k):
    return choice([token_bytes, os.urandom])(k)

cpdef rand(datatype = CTYPE_INT, unsigned int counts=1):
    """
    Returns a random c type integer or float.

    # Parameters

    datatype: the type of number to generate.
    `CTYPE_UNSIGNED_SHORT`: from `0` to `65535`\n
    `CTYPE_SHORT`: from `-32768` to `32767`\n
    `CTYPE_INT`: from `-2147483648` to `2147483647`\n
    `CTYPE_UNSIGNED_INT`: from `0` to `4294967295`\n
    `CTYPE_LONG`: such `CTYPE_INT`\n
    `CTYPE_UNSIGNED_LONG`: such `CTYPE_UNSIGNED_INT`\n
    `CTYPE_LONG_LONG`: from `-9223372036854775808` to `9223372036854775807`\n
    `CTYPE_UNSIGNED_LONG_LONG`: from `0` to `18446744073709551615`\n
    `CTYPE_HALF`: from `6.1e-05` to `6.5e+04`\n
    `CTYPE_FLOAT`: from `2.939e-38` to `3.403e+38`\n
    `CTYPE_DOUBLE`: from `5.563e-309` to `1.798e+308`\n

    counts: random number to generate.

    # Examples

    >>> import cyrandom as r
    >>> r.rand(counts=100)
    [-1422764493, -292974253, -1613260745, -1853515593, -627200009, 337258377, 1444864943, -285178884, -1736441810, 484028146, -1582478080, -472555771, -2080741457, 199702369, 1944127374, -1342171656, 2031054742, -1769917088, 57922129, -410360613, 1419766610, 2125926016, 920854291, -127451866, 1667960254, 2004775108, 1570198913, -878241317, 1099444300, 1839247875, -1387937057, 1494303768, 499130979, 928164387, -1453094322, -2069087771, -812968986, 678490466, 1237722042, -277545607, 1591248688, 593886314, -1646323777, 236021545, 1069089376, -961729583, 931114289, 97962523, 1059696768, -912261324, -630446583, 438714189, 291202987, 1451980557, -230814385, 85037954, -132498861, -1219752233, -1573828524, 1738198043, 2135374060, -908704286, -382547525, -207956358, 1135708534, 445437352, 1262155381, 700235836, 448907957, -110710869, -349269606, -1529600476, -1759138364, -1074557137, -1454159993, -1961733228, 1118516616, 1990085653, -723580639, 1080117237, -822553195, -1780830154, 2012013629, -1962417493, -181252030, -945947896, 226217893, -2098858619, -1606355668, -1858234497, -92363353, 763538344, 189244413, -149677518, 1565935017, -1951182252, 281767775, 1583631898, -379637133, -952304982]
    >>> r.rand(r.CTYPE_DOUBLE, counts=5)
    [1.2051755129383592e+117, -1.2903141605910989e+178, -3.8082091375067834e-32, -8.136019523808214e-203, -2.5697887449891776e+246]

    """
    cdef str struct_fmt_string = datatype.struct_format
    cdef unsigned int _sizeof = datatype.sizeof
    cdef list numbers = []
    cdef unsigned int i
    for i in range(counts):
        bits = _randbits(_sizeof)
        numbers.append(unpack(struct_fmt_string, bits)[0])
    if len(numbers) == 1:
        return numbers[0]
    else:
        return numbers
    
cpdef rand_password(unsigned int k=30):
    global allow_char
    cdef str result
    cdef unsigned int _
    for _ in range(k):
        this_char = choice(allow_char)
        result += this_char
    return result

cpdef randint(unsigned int k):
    """
    Return a random number of the range of `k` bytes.

    # Parameters

    k: The integer size.

    # Examples

    >>> from cyrandom import randint
    >>> randint(32) # 128 bit signed integer
    12637847285605240454597997461800103129739631973499518605233884589409011969801
    
    # Warnings

    Don't set the `k` value over the return value of `sys.get_int_max_str_digits`
    
    """
    cdef bytes b = _randbits(k)
    return int.from_bytes(b, BYTEORDER)

cpdef randarray(unsigned int k, unsigned int sz=10):
    cdef list ls
    cdef unsigned int _
    ls = [randint(k) for _ in range(sz)]
    return ls

cdef set_integer_digit_limit(n: int):
    """
    Set the maximum string digits limit for non-binary int <-> str conversions.
    """
    set_int_max_str_digits(n)

def get_integer_digit_limit():
    """
    Return the maximum string digits limit for non-binary int<->str conversions.
    """
    return get_int_max_str_digits()

