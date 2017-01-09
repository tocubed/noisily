setup = """
import noisily as ns
import numpy as np

source = ns.source(ns.cell2_range_inv)
points = np.ascontiguousarray(np.indices((1024, 1024)).T, dtype=np.float64)
"""

statement = """
source(points)
"""

import timeit
def run(n):
    print(timeit.timeit(statement, setup=setup, number=n))

if __name__ == "__main__":
    run(5)
