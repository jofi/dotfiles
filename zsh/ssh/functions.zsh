function authme() {
        ssh $1 'cat >>.ssh/authorized_keys' < ~/.ssh/id_rsa.pub
}
