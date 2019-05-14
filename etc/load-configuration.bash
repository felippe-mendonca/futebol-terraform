#!/bin/bash

current_dir="$( pwd )"
this_script_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

cd ${this_script_dir}

. admin-openrc.sh

export TF_VAR_openstack_password=$OS_PASSWORD
export TF_VAR_openstack_hostname=$(echo $OS_AUTH_URL | grep -oE '[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')

cd ${current_dir}
