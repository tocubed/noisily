import pytest

import numpy as np
import noisily as ns

# FIXME This has got to be an abuse of fixtures, right?

@pytest.fixture(scope='module', params=[(1, 1), (37, 57), (128, 128)])
def indices2D(request):
    shape = request.param
    return np.transpose(np.indices(shape))

@pytest.fixture(scope='module', params=[(1, 1, 1), (29, 13, 31), (64, 64, 64)])
def indices3D(request):
    shape = request.param
    return np.transpose(np.indices(shape))

@pytest.fixture(scope='module', params=[(1, 1, 1, 1), (7, 11, 17, 13), (32, 32, 32, 32)])
def indices4D(request):
    shape = request.param
    return np.transpose(np.indices(shape))

@pytest.fixture(scope='module', params=[ns.perlin2D, ns.value2D, ns.open_simplex2D, ns.cell2D_range, ns.cell2D_range_inv, ns.cell2D_value, ns.cell2D_manhattan, ns.cell2D_manhattan_inv, ns.cell2D_manhattan_value])
def noise2D(request):
    return request.param

@pytest.fixture(scope='module', params=[ns.perlin3D, ns.value3D, ns.open_simplex3D, ns.cell3D_range, ns.cell3D_range_inv, ns.cell3D_value, ns.cell3D_manhattan, ns.cell3D_manhattan_inv, ns.cell3D_manhattan_value])
def noise3D(request):
    return request.param

@pytest.fixture(scope='module', params=[ns.perlin4D, ns.value4D, ns.open_simplex4D, ns.cell4D_range, ns.cell4D_range_inv, ns.cell4D_value, ns.cell4D_manhattan, ns.cell4D_manhattan_inv, ns.cell4D_manhattan_value])
def noise4D(request):
    return request.param

@pytest.fixture(scope='module', params=[{'seed': 123}, {'period': 64}, {'seed': 12345, 'period': 16}])
def generator2D(request, noise2D):
    return ns.generator(noise2D, **request.param)

@pytest.fixture(scope='module', params=[{'seed': 123}, {'period': 64}, {'seed': 12345, 'period': 16}])
def generator3D(request, noise3D):
    return ns.generator(noise3D, **request.param)

@pytest.fixture(scope='module', params=[{'seed': 123}, {'period': 64}, {'seed': 12345, 'period': 16}])
def generator4D(request, noise4D):
    return ns.generator(noise4D, **request.param)

def test_output2D(generator2D, indices2D):
    output = generator2D(indices2D)

    assert output.shape == indices2D.shape[:-1]
    assert output.size == indices2D.size // 2
    assert np.array_equal(output, generator2D(indices2D))

def test_output3D(generator3D, indices3D):
    output = generator3D(indices3D)

    assert output.shape == indices3D.shape[:-1]
    assert output.size == indices3D.size // 3
    assert np.array_equal(output, generator3D(indices3D))

def test_output4D(generator4D, indices4D):
    output = generator4D(indices4D)

    assert output.shape == indices4D.shape[:-1]
    assert output.size == indices4D.size // 4
    assert np.array_equal(output, generator4D(indices4D))
