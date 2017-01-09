#!/bin/bash
set -e -x

function install_openssl {
    # Compile and parallel-install a newer OpenSSL version so that curl can
    # download from the rust servers
    pushd /usr/src
    wget -q ftp://ftp.openssl.org/source/openssl-${1}.tar.gz
    tar xf openssl-${1}.tar.gz
    cd openssl-${1}
    ./config --prefix=/opt/openssl shared > /dev/null
    make > /dev/null
    make install > /dev/null
    export LD_LIBRARY_PATH=/opt/openssl/lib:$LD_LIBRARY_PATH
    popd
}

function install_curl {
    pushd /usr/src
    # Compile an up-to-date curl version that links to our own OpenSSL installation
    wget -q --no-check-certificate http://curl.haxx.se/download/curl-${1}.tar.gz
    tar xf curl-${1}.tar.gz
    cd curl-${1}
    ./configure --with-ssl=/opt/openssl --prefix=/opt/curl > /dev/null
    make > /dev/null
    make install > /dev/null
    export PATH=/opt/curl/bin:$PATH
    popd
}

function install_rust {
    curl https://static.rust-lang.org/rustup.sh > /tmp/rustup.sh
    chmod +x /tmp/rustup.sh
    /tmp/rustup.sh -y --disable-sudo --channel=$1
}

function update_certificates {
    # Update the Root CA bundle
    wget -q --no-check-certificate \
        -O /etc/pki/tls/certs/ca-bundle.crt \
        http://curl.haxx.se/ca/cacert.pem
}

function clean_project {
    # Remove compiled files that might cause conflicts
    pushd /io/
    rm -rf build *.egg-info
    find ./ -name "__pycache__" -type d -print0 |xargs rm -rf --
    popd
}

OPENSSL_VERSION=1.0.2j
CURL_VERSION=7.49.1
RUST_CHANNEL=stable

# It doesn't matter with which Python version we build the wheel, so we
# use the oldest supported one
if [[ $1 == "osx" ]]; then
    brew update
    brew install mmv
    pip install -U pip setuptools Cython wheel
    install_rust $RUST_CHANNEL

	# Build noise-c
	pushd ./noise-c/
	cargo build --release
	popd

    pip wheel . -w ./wheelhouse
    mmv "./wheelhouse/noisily-*-cp*-cp*-macosx*.whl" \
        "./wheelhouse/noisily-#1-py2.py3-none-macosx#4.whl"
    pip install -v noisily --no-index -f ./wheelhouse
	python ./test.py
else
    PYBIN=/opt/python/cp27-cp27m/bin
    # Clean build files
    clean_project

    install_openssl $OPENSSL_VERSION
    install_curl $CURL_VERSION
    install_rust $RUST_CHANNEL

	# Build noise-c
	pushd /io/noise-c/
	cargo build --release
	popd

    # Remove old wheels
    rm -rf /io/wheelhouse/* || echo "No old wheels to delete"

    # We don't support Python 2.6
    rm -rf /opt/python/cp26*

	# Install Cython requirement
	${PYBIN}/python -m pip install Cython

    # Compile wheel
    ${PYBIN}/python -m pip wheel /io/ -w /wheelhouse/

    # Move pure wheels to target directory
    mkdir -p /io/wheelhouse
    mv /wheelhouse/*any.whl /io/wheelhouse || echo "No pure wheels to move"

    # Bundle external shared libraries into the wheel
    for whl in /wheelhouse/*.whl; do
        auditwheel repair $whl -w /io/wheelhouse/
    done

    # Rename wheels to match all Python versions
    mmv "/io/wheelhouse/rust_fst-*-cp*-cp*-manylinux1_*.whl" \
        "/io/wheelhouse/rust_fst-#1-py2.py3-none-manylinux1_#4.whl"

    # Set permissions on wheels
    chmod -R a+rw /io/wheelhouse

    # Install packages and test with all Python versions
    for PYBIN in /opt/python/*/bin/; do
        ${PYBIN}/python -m pip install noisily --no-index -f /io/wheelhouse
        ${PYBIN}/python /io/test.py
        clean_project
    done
fi
