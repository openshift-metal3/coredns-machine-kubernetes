#!/bin/bash -x

if [[ "$1" == "" ]]; then
    BUILD_DIR="${HOME}/.local/share/coredns-machine-kubernetes-build"
    if [[ ! -d "${PWD}/build" ]]; then
        mkdir -p "$BUILD_DIR"
    fi
    rm -fr "${BUILD_DIR}/src/github.com/openshift-metal3/coredns-machine-kubernetes"
    mkdir -p "${BUILD_DIR}/src/github.com/openshift-metal3/coredns-machine-kubernetes"
    cp -r . "${BUILD_DIR}/src/github.com/openshift-metal3/coredns-machine-kubernetes"
    chcon -Rv -t container_file_t "$BUILD_DIR"
    sudo podman run --rm \
        -v "${BUILD_DIR}:/go" \
        registry.svc.ci.openshift.org/openshift/release:golang-1.11 \
        /go/src/github.com/openshift-metal3/coredns-machine-kubernetes/build.sh $(id -u)
    if [[ -f "${BUILD_DIR}/src/github.com/openshift-metal3/coredns-machine-kubernetes/coredns" ]]; then
        cp "${BUILD_DIR}/src/github.com/openshift-metal3/coredns-machine-kubernetes/coredns" .
    fi
else
    echo "Building CoreDNS with machinekubernetes..."

    go get -v github.com/coredns/coredns

    pushd /go/src/github.com/coredns/coredns
    git reset --hard HEAD
    git clean -f
    git checkout master
    git pull

    sed -i -e "/^kubernetes:kubernetes$/i machinekubernetes:github.com/openshift-metal3/coredns-machine-kubernetes" plugin.cfg

    if [ "$?" -ne 0 ]; then
        echo "Failed"
        exit 1
    fi

    echo "replace github.com/openshift-metal3/coredns-machine-kubernetes => /go/src/github.com/openshift-metal3/coredns-machine-kubernetes" >> go.mod

    if [ "$?" -ne 0 ]; then
        echo "Failed"
        exit 1
    fi

    make

    cp coredns /go/src/github.com/openshift-metal3/coredns-machine-kubernetes/
    chown "${1}:${1}" /go/src/github.com/openshift-metal3/coredns-machine-kubernetes/coredns
fi
