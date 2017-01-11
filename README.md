# noisily
Procedural noise generation for Python. 

Uses noise functions from the Rust noise library at https://github.com/brendanzab/noise-rs. 
Currently, noisily links with a forked version of the library which adds periodicity (for 
tileable noise).

## Usage
```python
import noisily as ns
import numpy as np

# Create an array of points. Noisily accepts any array of points so long 
# as the shape of the last axis matches the dimension.
points = np.indices((1024, 1024)).T
# Scale for a closer range
points *= 1 / 64
# Create a generator for 2D cell noise using the default seed and period
generator = ns.generator(ns.cell2D_range_inv)

# Call the generator to get the values at each point. This has the same shape
# as the array, sans the last axis. E.g. (1024, 1024, 2) -> (1024, 1024)
values = generator(points)
```
