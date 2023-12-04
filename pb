#!/bin/sh

# init variables
version="v2023.12.04"
ENDPOINT="https://envs.sh"
flag_options=":hvcfe:s:"
long_flag_options="help,version,color,file,extension:,server:"
flag_version=0
flag_help=0
flag_file=0
flag_colors=0
flag_ext=0
data=""
EXT=""

# help message available via func
show_help() {
  cat > /dev/stdout << END
pb [options] filename
or
(command-with-stdout) | pb

Uploads a file or data to the tilde 0x0 paste bin

OPTIONAL FLAGS:
  -h | --help)                    Show this help
  -v | --version)                 Show current version number
  -f | --file)                    Explicitly interpret stdin as filename
  -c | --color)                   Pretty color output
  -s | --server server_address)   Use alternative pastebin server address
  -e | --extension bin_extension) Specify file extension used in the upload
END
}

show_usage() {
  cat > /dev/stdout << END
usage: pb [-hfvcux] [-s server_address] filename
END
}

# helper for program exit, supports error codes and messages
die () {
  msg="$1"
  code="$2"
  # exit code defaults to 1
  if printf "%s" "${code}" | grep -q '^[0-9]+$'; then
    code=1
  fi
  # output message to stdout or stderr based on code
  if [ -n "${msg}" ]; then
    if [ "${code}" -eq 0 ]; then
      printf "%s\\n" "${msg}"
    else
      printf "%s%s%s\\n" "$ERROR" "${msg}" "$RESET" >&2
    fi
  fi
  exit "${code}"
}

# attempt to parse options or die
if ! PARSED_ARGUMENTS=$(getopt -a -n pb -o ${flag_options} --long ${long_flag_options} -- "$@"); then
  printf "pb: unknown option\\n"
  show_usage
  exit 2
fi

# For debugging: echo "PARSED_ARGUMENTS is $PARSED_ARGUMENTS"
eval set -- "$PARSED_ARGUMENTS"
while :
do
  case "$1" in
    -h | --help)      flag_help=1                  ; shift   ;;
    -v | --version)   flag_version=1               ; shift   ;;
    -c | --color)     flag_color=1                 ; shift   ;;
    -f | --file)      flag_file=1                  ; shift   ;;
    -e | --extension) flag_ext=1;    EXT="$2"      ; shift 2 ;;
    -s | --server)                   ENDPOINT="$2" ; shift 2 ;;
    --) shift; break ;;
    *) echo "Unexpected option: $1 - this should not happen."
       show_usage ; die 3 ;;
  esac
done

# display current version
if [ ${flag_version} -gt 0 ]; then
  printf "%s\\n" "${version}"
  die "" 0
fi

# display help
if [ ${flag_help} -gt 0 ]; then
  show_help
  die "" 0
fi

# is not interactive shell, use stdin
if [ -t 0 ]; then
  flag_file=1
else
  if [ ${flag_ext} -gt 0 ]; then
    # short-circuit stdin access to ensure binary data is transferred to curl
    curl -sF"file=@-;filename=null.${EXT}" "${ENDPOINT}" < /dev/stdin
    exit 0
  else
    data="$(cat < /dev/stdin )"
  fi
fi

# if data variable is empty (not a pipe) use params as fallback
if [ -z "$data" ]; then
  data="$*"
fi

# Colors
if [ ${flag_colors} -gt 0 ]; then
  SUCCESS=$(tput setaf 190)
  ERROR=$(tput setaf 196)
  RESET=$(tput sgr0)
else
  SUCCESS=""
  ERROR=""
  RESET=""
fi

if [ ${flag_file} -gt 0 ]; then
  # file mode
  if [ -z "${data}" ]; then
    # if no data
    # print error message
    printf "%sProvide data to upload%s\\n" "$ERROR" "$RESET"
  elif [ ! -f "${data}" ]; then
    # file not found with name provided
    # print error messagse
    printf "%s%s%s\\tFile not found.%s\\n" "$RESET" "${data}" "$ERROR" "$RESET"
    # attempt to split data string (multi-line?) and upload each string as file
    for f in ${data}; do
      # if there's nothing to parse, skip this loop
      if [ "$f" = "$data" ]; then
        break;
      fi
      # check if file exists
      if [ -f "${f}" ]; then
        if [ ${flag_ext} -gt 0 ]; then
          # send file to endpoint masked with new extension
          result=$(curl -sF"file=@${f};filename=null.${EXT}" "${ENDPOINT}")
        else
          # send file to endpoint
          result=$(curl -sF"file=@${f}" "${ENDPOINT}")
        fi
        printf "%s%s%s\\n" "$SUCCESS" "$result" "$RESET"
      else
        # print error message
        printf "%sFile not found.%s\\n" "$ERROR" "$RESET"
      fi
    done
  else
    # data available in file
    # send file to endpoint
    result=$(curl -sF"file=@${data}" "${ENDPOINT}")
    printf "%s%s%s\\n" "$SUCCESS" "$result" "$RESET"
  fi
else
  # non-file mode
  if [ -z "${data}" ]; then
    # if no data
    # print error message
    printf "%sNo data found for upload. Please try again.%s\\n" "$ERROR" "$RESET"
  else
    # data available
    # send data to endpoint
    result=$(printf "%s" "${data}" | curl -sF"file=@-;filename=null.txt" "${ENDPOINT}")
    printf "%s%s%s\\n" "$SUCCESS" "$result" "$RESET"
  fi
fi
