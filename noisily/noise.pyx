__all__  = ["source"]
__all__ += ["perlin2", "perlin3", "perlin4"]
__all__ += ["value2", "value3", "value4"]
__all__ += ["open_simplex2", "open_simplex3", "open_simplex4"]
__all__ += ["cell2_range", "cell3_range", "cell4_range"]
__all__ += ["cell2_range_inv", "cell3_range_inv", "cell4_range_inv"]
__all__ += ["cell2_value", "cell3_value", "cell4_value"]
__all__ += ["cell2_manhattan", "cell3_manhattan", "cell4_manhattan"]
__all__ += ["cell2_manhattan_inv", "cell3_manhattan_inv", "cell4_manhattan_inv"]
__all__ += ["cell2_manhattan_value", "cell3_manhattan_value", "cell4_manhattan_value"]

from libc.stdint cimport uint32_t

cdef extern from "noise_c.h":
    ctypedef struct ns_PermutationTable:
        pass

    const ns_PermutationTable* ns_PermutationTable_create(uint32_t seed, uint32_t period)
    void ns_PermutationTable_destroy(ns_PermutationTable* table)

    double ns_perlin2(const ns_PermutationTable* table, double x, double y)
    double ns_perlin3(const ns_PermutationTable* table, double x, double y, double z)
    double ns_perlin4(const ns_PermutationTable* table, double x, double y, double z, double w)

    double ns_value2(const ns_PermutationTable* table, double x, double y)
    double ns_value3(const ns_PermutationTable* table, double x, double y, double z)
    double ns_value4(const ns_PermutationTable* table, double x, double y, double z, double w)
    
    double ns_open_simplex2(const ns_PermutationTable* table, double x, double y)
    double ns_open_simplex3(const ns_PermutationTable* table, double x, double y, double z)
    double ns_open_simplex4(const ns_PermutationTable* table, double x, double y, double z, double w)
    
    double ns_cell2_range(const ns_PermutationTable* table, double x, double y)
    double ns_cell3_range(const ns_PermutationTable* table, double x, double y, double z)
    double ns_cell4_range(const ns_PermutationTable* table, double x, double y, double z, double w)
    
    double ns_cell2_range_inv(const ns_PermutationTable* table, double x, double y)
    double ns_cell3_range_inv(const ns_PermutationTable* table, double x, double y, double z)
    double ns_cell4_range_inv(const ns_PermutationTable* table, double x, double y, double z, double w)
    
    double ns_cell2_value(const ns_PermutationTable* table, double x, double y)
    double ns_cell3_value(const ns_PermutationTable* table, double x, double y, double z)
    double ns_cell4_value(const ns_PermutationTable* table, double x, double y, double z, double w)
    
    double ns_cell2_manhattan(const ns_PermutationTable* table, double x, double y)
    double ns_cell3_manhattan(const ns_PermutationTable* table, double x, double y, double z)
    double ns_cell4_manhattan(const ns_PermutationTable* table, double x, double y, double z, double w)
    
    double ns_cell2_manhattan_inv(const ns_PermutationTable* table, double x, double y)
    double ns_cell3_manhattan_inv(const ns_PermutationTable* table, double x, double y, double z)
    double ns_cell4_manhattan_inv(const ns_PermutationTable* table, double x, double y, double z, double w)
    
    double ns_cell2_manhattan_value(const ns_PermutationTable* table, double x, double y)
    double ns_cell3_manhattan_value(const ns_PermutationTable* table, double x, double y, double z)
    double ns_cell4_manhattan_value(const ns_PermutationTable* table, double x, double y, double z, double w)


cimport cython

import numpy as np
cimport numpy as np


@cython.internal
cdef class PermutationTable:
    cdef const ns_PermutationTable* wrapped

    def __cinit__(self, uint32_t seed, uint32_t period):
        self.wrapped = ns_PermutationTable_create(seed, period)

    def __dealloc__(self):
        ns_PermutationTable_destroy(self.wrapped)

    cdef const ns_PermutationTable* unwrap(self):
        return self.wrapped


cdef internally = object()

ctypedef double (*noise2Dfp)(const ns_PermutationTable* table, double x, double y)
ctypedef double (*noise3Dfp)(const ns_PermutationTable* table, double x, double y, double z)
ctypedef double (*noise4Dfp)(const ns_PermutationTable* table, double x, double y, double z, double w)

@cython.internal
cdef class noise2D:
    cdef noise2Dfp wrapped

    def __cinit__(self, *args, **kwargs):
        if not 'init' in kwargs or kwargs['init'] != internally:
            raise TypeError("You must not instantiate internal types")

    cdef noise2Dfp unwrap(self):
        return self.wrapped

@cython.internal
cdef class noise3D:
    cdef noise3Dfp wrapped

    def __cinit__(self, *args, **kwargs):
        if not 'init' in kwargs or kwargs['init'] != internally:
            raise TypeError("You must not instantiate internal types")

    cdef noise3Dfp unwrap(self):
        return self.wrapped

@cython.internal
cdef class noise4D:
    cdef noise4Dfp wrapped

    def __cinit__(self, *args, **kwargs):
        if not 'init' in kwargs or kwargs['init'] != internally:
            raise TypeError("You must not instantiate internal types")

    cdef noise4Dfp unwrap(self):
        return self.wrapped

cdef wrap_noise2D(noise2Dfp function):
    result = noise2D(init=internally)
    result.wrapped = function
    return result

cdef wrap_noise3D(noise3Dfp function):
    result = noise3D(init=internally)
    result.wrapped = function
    return result

cdef wrap_noise4D(noise4Dfp function):
    result = noise4D(init=internally)
    result.wrapped = function
    return result


perlin2 = wrap_noise2D(ns_perlin2)
perlin3 = wrap_noise3D(ns_perlin3)
perlin4 = wrap_noise4D(ns_perlin4)

value2 = wrap_noise2D(ns_value2)
value3 = wrap_noise3D(ns_value3)
value4 = wrap_noise4D(ns_value4)

open_simplex2 = wrap_noise2D(ns_open_simplex2)
open_simplex3 = wrap_noise3D(ns_open_simplex3)
open_simplex4 = wrap_noise4D(ns_open_simplex4)

cell2_range = wrap_noise2D(ns_cell2_range)
cell3_range = wrap_noise3D(ns_cell3_range)
cell4_range = wrap_noise4D(ns_cell4_range)

cell2_range_inv = wrap_noise2D(ns_cell2_range_inv)
cell3_range_inv = wrap_noise3D(ns_cell3_range_inv)
cell4_range_inv = wrap_noise4D(ns_cell4_range_inv)

cell2_value = wrap_noise2D(ns_cell2_value)
cell3_value = wrap_noise3D(ns_cell3_value)
cell4_value = wrap_noise4D(ns_cell4_value)

cell2_manhattan = wrap_noise2D(ns_cell2_manhattan)
cell3_manhattan = wrap_noise3D(ns_cell3_manhattan)
cell4_manhattan = wrap_noise4D(ns_cell4_manhattan)

cell2_manhattan_inv = wrap_noise2D(ns_cell2_manhattan_inv)
cell3_manhattan_inv = wrap_noise3D(ns_cell3_manhattan_inv)
cell4_manhattan_inv = wrap_noise4D(ns_cell4_manhattan_inv)

cell2_manhattan_value = wrap_noise2D(ns_cell2_manhattan_value)
cell3_manhattan_value = wrap_noise3D(ns_cell3_manhattan_value)
cell4_manhattan_value = wrap_noise4D(ns_cell4_manhattan_value)


@cython.internal
cdef class source2D:
    cdef noise2D noise
    cdef PermutationTable table

    def __cinit__(self, *args, **kwargs):
        if not 'init' in kwargs or kwargs['init'] != internally:
            raise TypeError("You must not instantiate internal types")

    def __call__(self, points not None): 
        return self.evaluate_points(points)

    @cython.boundscheck(False)
    @cython.wraparound(False)
    cdef np.ndarray evaluate_points(self, np.ndarray[double, mode="c"] points):
        cdef noise2Dfp function = self.noise.unwrap()
        cdef const ns_PermutationTable* table = self.table.unwrap()

        cdef int num_points = points.size // 2
        cdef np.ndarray[double, mode="c"] values = np.empty([num_points], dtype=np.float64)

        cdef int x
        for x in range(num_points):
            values[x] = function(table, points[2*x], points[2*x+1])

        return values

@cython.internal
cdef class source3D:
    cdef noise3D noise
    cdef PermutationTable table

    def __cinit__(self, *args, **kwargs):
        if not 'init' in kwargs or kwargs['init'] != internally:
            raise TypeError("You must not instantiate internal types")

    def __call__(self, points not None): 
        return self.evaluate_points(points)

    @cython.boundscheck(False)
    @cython.wraparound(False)
    cdef np.ndarray evaluate_points(self, np.ndarray[double, mode="c"] points):
        cdef noise3Dfp function = self.noise.unwrap()
        cdef const ns_PermutationTable* table = self.table.unwrap()

        cdef int num_points = points.size // 3
        cdef np.ndarray[double, mode="c"] values = np.empty([num_points], dtype=np.float64)

        cdef int x
        for x in range(num_points):
            values[x] = function(table, points[3*x], points[3*x+1], points[3*x+2])

        return values

@cython.internal
cdef class source4D:
    cdef noise4D noise
    cdef PermutationTable table

    def __cinit__(self, *args, **kwargs):
        if not 'init' in kwargs or kwargs['init'] != internally:
            raise TypeError("You must not instantiate internal types")

    def __call__(self, points not None): 
        return self.evaluate_points(points)

    @cython.boundscheck(False)
    @cython.wraparound(False)
    cdef np.ndarray evaluate_points(self, np.ndarray[double, mode="c"] points):
        cdef noise4Dfp function = self.noise.unwrap()
        cdef const ns_PermutationTable* table = self.table.unwrap()

        cdef int num_points = points.size // 4
        cdef np.ndarray[double, mode="c"] values = np.empty([num_points], dtype=np.float64)

        cdef int x
        for x in range(num_points):
            values[x] = function(table, points[4*x], points[4*x+1], points[4*x+2], points[4*x+3])

        return values


cdef class source:
    cdef object source
    cdef int dimension

    @cython.embedsignature(True)
    def __cinit__(self, noise, seed = 0, period = 256):
        if not period in [1, 2, 4, 8, 16, 32, 64, 128, 256]:
            raise ValueError("Period must be a power-of-two integer in the range [1, 256]")

        cdef source2D source2
        cdef source3D source3
        cdef source4D source4
        if isinstance(noise, noise2D):
            source2 = source2D(init=internally)
            source2.noise = noise
            source2.table = PermutationTable(seed, period)

            self.source = source2
            self.dimension = 2
        elif isinstance(noise, noise3D):
            source3 = source3D(init=internally)
            source3.noise = noise
            source3.table = PermutationTable(seed, period)

            self.source = source3
            self.dimension = 3
        elif isinstance(noise, noise4D):
            source4 = source4D(init=internally)
            source4.noise = noise
            source4.table = PermutationTable(seed, period)

            self.source = source4
            self.dimension = 4
        else:
            raise TypeError("Noise must be one of the available noise types")

    @cython.embedsignature(True)
    def __call__(self, points not None): 
        points = np.ascontiguousarray(points, dtype=np.float64)

        if points.shape[-1] != self.dimension:
            raise ValueError("For %iD points, the last axis must have shape %i" % (self.dimension, self.dimension))

        values_shape = points.shape[:-1]

        return self.source(np.ravel(points)).reshape(values_shape)
