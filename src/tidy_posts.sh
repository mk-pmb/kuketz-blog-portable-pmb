#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function tidy_posts () {
  export LANG{,UAGE}=en_US.UTF-8  # make error messages search engine-friendly
  local SELFPATH="$(readlink -m -- "$BASH_SOURCE"/..)"
  case "$1" in
    --redo ) tidy_all_local_posts; return $?;;
  esac
  tidy_multiple_posts "$@" || return $?
}


function tidy_multiple_posts () {
  local ORIG=
  for ORIG in "$@"; do
    tidy_one_post "$ORIG" || return $?
  done
}


function tidy_all_local_posts () {
  cd -- "$SELFPATH"/../local/posts || return $?
  tidy_multiple_posts [0-9]*.orig.html || return $?
}


function tidy_one_post () {
  local ORIG="$1"
  local CLEAN="${ORIG/.orig./.clean.}"
  [ "$CLEAN" == "$ORIG" ] && return 4$(
    echo "E: failed to guess 'clean' filename from '$ORIG'" >&2)
  echo -n "D: cleanup $ORIG -> $CLEAN : "
    # echo "E: Failed to create output file: $CLEAN" >&2)
  <"$ORIG" sed -rf <(echo '
    1{/^<!DOCTYPE html> <html/{
      : read_all
      $!{N;b read_all}
      s~\r|\f|\a~~g
      s~> <~>\n<~g
    }}
    ') | grep . $(
      # We're not expecting any blank lines.
      # Rather, grep is used to ensure there's a trailing NL at end of file.
    ) | sed -rf <(echo '
      s~ (src|href|content)(=[\x22\x27])(https?://)~ \1\2\r\3~g
      s~(\r)https?://(www\.|)kuketz-blog\.de/~\1blog:///~g
      s~(\r)https?://(www\.|)~\1../web/~g
      s~(\r)blog:///(wp-content/)~\1../../web/\2~g
      s~\r~~g
      s~</head>~\n<style>@import url("../../local/custom.css");</style>\n&~
      s~<div class="hatom-extra"~<section id="nachklapp">\n&~
      s~<div class="comment-container">~</section><!-- /#nachklapp -->\n&~
    ') >"$CLEAN"
  local RV="${PIPESTATUS[*]}"
  let RV="${RV// /+}"
  if [ "$RV" == 0 ]; then
    echo 'ok.'
  else
    echo "fail! rv=$RV" >&2
  fi
  return "$RV"
}






tidy_posts "$@"; exit $?
