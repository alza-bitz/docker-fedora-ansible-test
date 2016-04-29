#!/bin/bash

set -e

readonly username=${USERNAME:-root}
readonly password=$(pwgen -s 12 1)
readonly authorized_keys=${AUTHORIZED_KEYS}

__create_rundir() {
  mkdir -p /var/run/sshd
}

__create_user() {
  [[ $username != "root" ]] && useradd $username
  printf '%s:%s' $username $password | chpasswd
  printf '=> Set password for user '\''%s'\'': %s\n' $username $password
  if [[ $username != "root" && -d /etc/sudoers.d ]]; then
    printf '%s ALL=(ALL) NOPASSWD: ALL\n' $username > /etc/sudoers.d/$username
  fi
}

__create_host_keys() {
  ssh-keygen -A > /dev/null
  printf '=> Added host keys in /etc/ssh:'
  local key_files=(/etc/ssh/*key)
  for key_file in ${key_files[@]}; do
    printf ' %s' ${key_file##*/};
  done
  printf '\n'
}

__create_authorized_keys() {
  local _key _keys _userhome
  if [[ ! -z $authorized_keys ]]; then
    _userhome=$(getent passwd $username | cut -d: -f6)
    mkdir -p $_userhome/.ssh && chmod 700 $_userhome/.ssh
    touch $_userhome/.ssh/authorized_keys && chmod 600 $_userhome/.ssh/authorized_keys
    chown -R $username:$username $_userhome/.ssh
    IFS=',' _keys=($authorized_keys)
    for _key in ${_keys[@]}; do
      _key=$(sed -e 's/^ *//' -e 's/ *$//' <<< "$_key")
      printf '%s\n' "$_key" >> $_userhome/.ssh/authorized_keys
      printf '=> Added public key to %s/.ssh/authorized_keys: %s\n' $_userhome $_key
    done
  fi
}

__create_rundir
__create_host_keys
__create_user
__create_authorized_keys

exec "$@"
