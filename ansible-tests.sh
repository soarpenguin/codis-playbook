#!/usr/bin/env bash
set -o errexit
set -o nounset
#set -o xtrace
set -o pipefail

__DIR__="$(cd "$(dirname "${0}")"; echo $(pwd))"
__BASE__="$(basename "${0}")"
__FILE__="${__DIR__}/${__BASE__}"
__NAME__="${0##*/}"

##################### function #########################
_report_err() { echo "${__NAME__}: Error: $*" >&2 ; }

if [ -t 1 ]
then
    RED="$( echo -e "\e[31m" )"
    HL_RED="$( echo -e "\e[31;1m" )"
    HL_BLUE="$( echo -e "\e[34;1m" )"

    NORMAL="$( echo -e "\e[0m" )"
fi

_hl_red()    { echo "$HL_RED""$@""$NORMAL";}
_hl_blue()   { echo "$HL_BLUE""$@""$NORMAL";}

_trace() {
    echo $(_hl_blue ' ->') "$@" >&2
}

_print_fatal() {
    echo $(_hl_red '==>') "$@" >&2
}

if ! command -v ansible-playbook >/dev/null; then
    _print_fatal "Please install ansible-playbook first."
    exit 1
fi

function lsb_release() {
python << END
import platform;

version = ""
system = platform.system();
release = platform.release();
if system == "Darwin":
    ver = platform.mac_ver();
    version = "%s %s %s" % (system, ver[0], ver[2])
else:
    ver = platform.linux_distribution()
    version = ' '.join(ver)

print version
END
}

echo "################################"
echo "Build Information"
echo "Directory: ${__DIR__}"
echo "Filename: ${__FILE__}"
echo "Version Information:"
echo "Ansible Version: $(ansible --version)"
echo "Ansible Playbook Version: $(ansible-playbook --version)"
echo "Operating System: $(lsb_release)"
echo "Kernel: $(uname -a)"
echo "################################"

_trace "### Starting tests"

find ${__DIR__} -maxdepth 1 \( -iname "*.yml" ! -iname ".*" \) | xargs -n1  ansible-playbook --syntax-check --list-tasks -i hosts

#find ${__DIR__} -maxdepth 1 \( -iname "*.yml" ! -iname ".*" \) | xargs -n1  ansible-playbook --check -i hosts
