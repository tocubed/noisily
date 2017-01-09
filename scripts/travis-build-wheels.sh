#!/bin/bash
set -e -x

OPENSSL_VERSION=1.0.2j
CURL_VERSION=7.49.1
RUST_CHANNEL=stable

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
    rm -rf build dist *.egg-info
    find ./ -name "__pycache__" -type d -print0 |xargs rm -rf --
    popd
}

if [[ $1 == "osx" ]]; then
    install_rust $RUST_CHANNEL

    pip install -U pip setuptools wheel Cython numpy
    pip wheel . -w ./wheelhouse
    pip install -v noisily --no-index -f ./wheelhouse

	pushd ./tests
	python ./test.py
else
    install_openssl $OPENSSL_VERSION
    install_curl $CURL_VERSION
    install_rust $RUST_CHANNEL

	# Pre-build libraries to avoid repeatedly building from setup.py
	pushd /io/noise-c/
	cargo build --release
	popd

    # Remove old wheels
    rm -rf /io/wheelhouse/* || echo "No old wheels to delete"

    # Remove unsupported Python versions
    rm -rf /opt/python/cp26*

	# Build wheels
    for PYBIN in /opt/python/*/bin/; do
		clean_project
		${PYBIN}/python -m pip install setuptools wheel Cython numpy
		${PYBIN}/python -m pip wheel /io/ -w /wheelhouse/
    done

    # Bundle external shared libraries into the wheel
    for whl in /wheelhouse/noisily*.whl; do
        auditwheel repair $whl -w /io/wheelhouse/
    done

    # Set permissions on wheels
    chmod -R a+rw /io/wheelhouse

	# Install wheels and test
    for PYBIN in /opt/python/*/bin/; do
        ${PYBIN}/python -m pip install noisily --no-index -f /io/wheelhouse
        ${PYBIN}/python /io/tests/test.py
    done
fi
