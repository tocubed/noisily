import os
import sys
import warnings


def build_noise_c_crate():
    import subprocess

    wd = os.path.abspath(os.path.join(os.path.dirname(__file__), "noise-c"))
    print("Running cargo build on noise-c")
    p = subprocess.call(
            ["cargo", "build", "--release"],
            cwd=wd)
    if p != 0:
        raise RuntimeError("Running cargo build failed!")


def get_noise_ext_libraries():
    if sys.platform == 'win32':
        shared_libraries = ['advapi32', 'ws2_32', 'userenv', 'shell32', 'advapi32', 'msvcrt']
    elif sys.platform == 'darwin':
        shared_libraries = ['System', 'c', 'm']
    else:
        shared_libraries = ['util', 'dl', 'pthread', 'gcc_s', 'c', 'm', 'rt', 'util']

    static_libraries = ['noise-c/target/release/' + ('libnoise_c.a' if sys.platform != 'win32' else 'noise_c.lib')]

    return shared_libraries, static_libraries


def get_cythonized_extensions():
    from setuptools import Extension

    from Cython.Distutils import build_ext
    from Cython.Build import cythonize

    import numpy

    shared_libraries, static_libraries = get_noise_ext_libraries()

    noise = Extension('noisily.noise',
            sources=['noisily/noise.pyx'],
            include_dirs=['noise-c/include', numpy.get_include()],
            libraries=shared_libraries,
            extra_objects=static_libraries,
    )

    extensions = [noise,]

    return cythonize(extensions), build_ext


def parse_setuppy_commands():
    build_commands = ('develop', 'install', 'build', 'build_ext', 'bdist_wheel', 'bdist_rpm')

    for command in build_commands:
        if command in sys.argv[1:]:
            return True

    non_build_commands = ('sdist', 'egg_info')

    for command in non_build_commands:
        if command in sys.argv[1:]:
            return False

    warnings.warn("Command is not a recognized or supported build command. Not building.")

    return False


def setup_package():
    build_requires = ['setuptools>=18.0', 'Cython>=0.25.0', 'numpy>=1.11.0']

    metadata = dict(
        name='noisily',
        version='0.0.2',
        author='Priyank Patel',
        author_email='tocubed@gmail.com',
        url='https://github.com/tocubed/noisily',
        license='MIT',
        setup_requires=build_requires,
        install_requires=build_requires,
        cmdclass={},
        packages=['noisily'],
    )

    run_build = parse_setuppy_commands()

    from setuptools import setup

    if run_build:
        build_noise_c_crate()

        ext_modules, build_ext = get_cythonized_extensions()
        metadata['ext_modules'] = ext_modules
        metadata['cmdclass']['build_ext'] = build_ext

    setup(**metadata)


if __name__ == '__main__':
    setup_package()
