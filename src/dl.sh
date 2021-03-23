#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function dl_cli () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFPATH="$(readlink -m -- "$BASH_SOURCE"/..)"
  cd -- "$SELFPATH"/.. || return $?

  case "$1" in
    --sym ) dl_missing_sympages; return $?;;
  esac
  dl_multi "$@" || return $?
}


function dl_multi () {
  local PG=
  for PG in "$@"; do
    dl_one_post "$PG" || return $?
  done
}


function dl_one_post () {
  local POST_NAME="$1"
  local POST_ID=
  [ -n "$POST_NAME" ] || return 4$(echo "E: Missing post name" >&2)
  local URL='https://www.kuketz-blog.de/'
  POST_NAME="${POST_NAME#$URL}"
  if [ "${POST_NAME//[^0-9]/}" == "$POST_NAME" ]; then
    POST_ID="$POST_NAME"
    URL+="?p=$POST_NAME"
  else
    POST_NAME="${POST_NAME%/}"
    URL+="$POST_NAME/"
  fi
  local SAVE="local/posts/$POST_ID.orig.html"
  dl_one_post_orig || return $?
}


function dl_one_post_orig () {
  echo -n "D: download #$POST_ID from $URL : "
  if [ -s "$SAVE" ]; then
    echo 'have.'
    return 0
  fi

  local DL_TMP="local/tmp/tmp.$$.html"
  mkdir --parents -- "$(dirname -- "$DL_TMP")"
  wget -O "$DL_TMP" -- "$URL" || return $?
  [ -n "$POST_ID" ] || POST_ID="$(find_postid "$DL_TMP")"
  printf -v POST_ID '%08d' "$POST_ID"
  mkdir --parents -- "$(dirname -- "$SAVE")"
  mv --no-target-directory -- "$DL_TMP" "$SAVE" || return $?
}


function find_postid () {
  grep -m 1 -oPe '<body [^<>]+>' -- "$@" | grep -m 1 -oPe 'class="[^"]+' \
    | tr '" ' '\n' | grep -xPe 'postid-\d+' | cut -d - -sf 2
}


function dl_missing_sympages () {
  local LIST=(
    find
    [a-z]*/
    -mount
    -type l     # limit to symlinks
    # -xtype l    # limit to broken symlinks
    -lname '*/local/posts/*.html'
    -printf '%l\n'
    )
  readarray -t LIST < <("${LIST[@]}" | sed -nrf <(echo '
    s~^.*/([0-9]+)(\.[a-z]+)+$~\1~p
    '))
  echo "D: found dead symlinks to ${#LIST[@]} posts: ${LIST[*]}"
  [ -z "${LIST[0]}" ] || dl_multi "${LIST[@]}" || return $?
}












dl_cli "$@"; exit $?
