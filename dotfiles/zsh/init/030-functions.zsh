mkcd() {
    mkdir -p "$1"
    [ $? -eq 0 ] && cd "$1"
}

has() {
    type $1
}
