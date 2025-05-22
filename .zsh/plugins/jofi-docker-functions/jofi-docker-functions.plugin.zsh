# SSH mount functions
function ssh-mount {
    host=${1}
    dir=${2}
    ldir="${HOME}/mnt/ssh/${host}"
    mkdir -p ${ldir}
    rdir=${dir:-""}
    sshfs -o follow_symlinks ${host}:${rdir} ${ldir}
    cd ${ldir}
}

function ssh-umount {
    host=${1}
    dir=${2}
    ldir="${HOME}/mnt/ssh/${host}"
    cd ~
    sudo umount ${ldir}
}

alias dev=ubuntu-dev

function ubuntu-dev {
    id=$(uuidgen | cut -c 1-4)
    name=dev-$USER-$id
    docker run -ti --rm \
        --name $name --hostname $name \
        -v "$HOME/:$HOME/" \
        -v "$HOME/:/home/dev/" \
        -v "/var/run/docker.sock:/var/run/docker.sock" \
        -w $PWD -u dev \
        dev/ubuntu "$@"
}

function rocky-dev {
    id=$(uuidgen | cut -c 1-4)
    name=dev-$USER-$id
    docker run -ti --rm \
        --name $name --hostname $name \
        -v "$HOME/:$HOME/" \
        -v "$HOME/:/home/dev/" \
        -v "/var/run/docker.sock:/var/run/docker.sock" \
        -w $PWD -u dev \
        dev/rocky "$@"
}

function debian-dev {
    id=$(uuidgen | cut -c 1-4)
    name=dev-$USER-$id
    docker run -ti --rm \
        --name $name --hostname $name \
        -v "$HOME/:$HOME/" \
        -v "$HOME/:/home/dev/" \
        -v "/var/run/docker.sock:/var/run/docker.sock" \
        -w $PWD -u dev \
        dev/debian "$@"
}

function mkdocs {
    id=$(uuidgen | cut -c 1-4)
    name=mkdocs-$USER-$id
    docker run -ti --rm \
        --name $name --hostname $name \
        -v "$HOME/:$HOME/" \
        -v "$HOME/:/home/dev/" \
        -v "/var/run/docker.sock:/var/run/docker.sock" \
        -p 8000:8000 \
        -w $PWD -u dev \
        dev/mkdocs "$@"
} 