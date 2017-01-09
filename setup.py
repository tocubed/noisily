from setuptools import setup, Extension

from Cython.Build import cythonize
from Cython.Distutils import build_ext

import numpy


ext = Extension('noisily.noise',
        sources=['noisily/noise.pyx'],
        include_dirs=['noise-c/include', numpy.get_include()],
        extra_objects=['noise-c/target/release/libnoise_c.a'],
)

extensions = [ext,]

setup(
    name='noisily',
    version='0.0.1',
    author='Priyank Patel',
    author_email='tocubed@gmail.com',
    license='MIT',
    url='https://github.com/tocubed/noisily',
    install_requires=['numpy>=1.11.0'],
    ext_modules=cythonize(extensions),
    cmdclass={'build_ext': build_ext},
    packages=['noisily'],
)
