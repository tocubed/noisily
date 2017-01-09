from setuptools import setup, Extension, find_packages

from Cython.Build import cythonize
from Cython.Distutils import build_ext

ext = Extension("noisily.noise",
        sources=["noisily/noise.pyx",],
        libraries=["noise_c",],
        library_dirs=["noise-c/target/release",],
        include_dirs=["noise-c/include",],
        runtime_library_dirs=["noise-c/target/release",],
)

extensions = [ext,]

setup(
    name="noisily",
    ext_modules=cythonize(extensions),
    cmdclass={'build_ext': build_ext},
)
