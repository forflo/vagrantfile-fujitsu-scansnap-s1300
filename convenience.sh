# source this in your ~/.profile

function sl-con-scanner() {
    local scanner_vagrant="$HOME/vagrants/scanner_ubuntu_18.04"
    [ "$#" -gt 0 ] && {
        ( cd $scanner_vagrant; vagrant ssh -c "$1" )
    } || {
        ( cd $scanner_vagrant; vagrant ssh )
    }
}

function sl-scan() {
    sl-con-scanner "/vagrant/scan.sh $*"
}
