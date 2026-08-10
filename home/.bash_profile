#
# AWS profiles
#

awsp() {
  export AWS_PROFILE="$1"
  export AWS_REGION=ap-southeast-2
}

_awsp_complete() {
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -W "$(sed -n 's/^\[profile \(.*\)\]$/\1/p; s/^\[\(.*\)\]$/\1/p' ~/.aws/config 2>/dev/null)" -- "$cur") )
}
complete -F _awsp_complete awsp
