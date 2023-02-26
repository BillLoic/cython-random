# Cyrandom

A cython random module for python.

# SpeedTests

 - Test 1: Cyrandom vs python standard random
```
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
```
`Cyrandom` is faster than standard-library `random` 10.22x
 - Test 2: Cyrandom vs numpy
```
>>> import numpy.random as npr
>>> import cyrandom
>>> npr.randint(-2**4095, 2**4095-1)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
  File "mtrand.pyx", line 763, in numpy.random.mtrand.RandomState.randint
  File "_bounded_integers.pyx", line 1334, in numpy.random._bounded_integers._rand_int32
ValueError: low is out of bounds for int32
>>> cyrandom.randint(4096)
--- skip ---
```

# Requires

<a href="https://visualstudio.microsoft.com/zh-hant/downloads/?q=build+tools">Visual studio build tools</a><br>
<a href="https://pypi.org/project/Cython/">Cython</a>
