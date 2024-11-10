# Check if we're already inside a tmux session
if [ -z "$TMUX" ]; then
    # Create or attach to a default session
    tmux attach-session -t default || tmux new-session -s default
fi

alias ll='ls --color=auto -alF'
function cd() { builtin cd "$@" && ls -l --color=auto; }

parse_git_branch(){ git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1) /'; }

hostname_if_ssh() 
{
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        echo "[$USER@$(hostname)] "
    fi
}

# extract time
_printtime () {
    local _var=${EPOCHREALTIME/,/};
    echo ${_var%???}
}

# get diff time, print it and end color codings if any
_elapsed () {
    if [ -z "$1" ]; then
        return 0
    fi

    [[ -v "${1}" ]] || ( local _VAR=$(_printtime);
    local _ELAPSED=$(( ${_VAR} - ${1} ));
    echo "${_ELAPTXT}$(_formatms ${_ELAPSED})"$'\e[0m' )
}

# format _elapsed with simple string substitution
_formatms () {
    local _n=$((${1})) && case ${_n} in
        ? | ?? | ???)
            echo $_n"ms"
        ;;
        ????)
            echo ${_n:0:1}${_n:0,-3}"ms"
        ;;
        ?????)
            echo ${_n:0:2}","${_n:0,-3}"s"
        ;;
        ??????)
            printf $((${_n:0:3}/60))m+$((${_n:0:3}%60)),${_n:0,-3}"s"
        ;;
        ???????)
            printf $((${_n:0:4}/60))m$((${_n:0:4}%60))s${_n:0,-3}"ms"
        ;;
        *)
            printf "too much!"
        ;;
    esac
}

prompt_command() {
  local exit_code=$?  # Capture the exit code at the beginning
  local -i start elapsed
  read _ start _ < <(HISTTIMEFORMAT='%s ' history | tail -n 1)
  (( elapsed = $(date +%s) - start ))
  local label="exited with $exit_code after $(_elapsed $PS0time)${PS0:(PS0time=0):0}"
  tput cuf 999
  tput cub ${#label}

  printf '%s\r' "$label"
}

PROMPT_COMMAND=prompt_command

PS0='${PS1:(PS0time=$(_printtime)):0}'
export PS1='$(hostname_if_ssh)\w \[\e[32m\]$(parse_git_branch)\[\e[0m\]\n$ '
