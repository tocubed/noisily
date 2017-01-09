setup = """
import noisily
import numpy as np

points = np.ascontiguousarray(np.indices((1024, 1024)).T, dtype=np.float64)
source = noisily.source(noisily.cell2_range_inv)
"""

statement = """
source(points)
"""

import timeit
def run(n):
    print(timeit.timeit(statement, setup=setup, number=n))

if __name__ == "__main__":
    run(100)
