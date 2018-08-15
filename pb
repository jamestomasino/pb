#!/bin/sh

version="v.2018.08.14"
ENDPOINT="https://0x0.tilde.team"
flag_options="hvfs::x"
flag_version=0
flag_help=0
flag_file=0
flag_shortlist=0
data=""

SUCCESS=$(tput setaf 190)
ERROR=$(tput setaf 196)
RESET=$(tput sgr0)

show_help() {
  cat > /dev/stdout << END
pb [options] filename
or
(command-with-stdout) | pb

Uploads a file or data to the tilde 0x0 paste bin

OPTIONAL FLAGS:
  -h                        Show this help
  -v                        Show current version number
  -f                        Explicitly interpret stdin as filename
  -s server_address         Use alternative pastebin server address
END
}

die () {
  msg="$1"
  code="$2"
  # exit code defaults to 1
  if printf "%s" "${code}" | grep -q '^[0-9]+$'; then
    code=1
  fi
  # output message to stdout or stderr based on code
  if [ ! -z "${msg}" ]; then
    if [ "${code}" -eq 0 ]; then
      printf "%s\\n" "${msg}"
    else
      printf "%s%s%s\\n" "$ERROR" "${msg}" "$RESET" >&2
    fi
  fi
  exit "${code}"
}

# is not interactive shell, use stdin
if [ -t 0 ]; then
  flag_file=1
else
  data="$(cat < /dev/stdin )"
fi

if ! parsed=$(getopt ${flag_options} "$@"); then
  die "Invalid input" 2
fi
eval set -- "${parsed}"
while true; do
  case "$1" in
    -h)
      flag_help=1
      shift
      ;;
    -v)
      flag_version=1
      shift
      ;;
    -f)
      flag_file=1
      shift
      ;;
    -s)
      shift
      ENDPOINT="$2"
      shift
      ;;
    -x)
      flag_shortlist=1
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      die "Internal error: $1" 3
      ;;
  esac
done

if [ -z "$data" ]; then
  data="$*"
fi


if [ ${flag_version} -gt 0 ]; then
  printf "%s\\n" "${version}"
  die "" 0
fi

if [ ${flag_help} -gt 0 ]; then
  show_help
  die "" 0
fi

if [ ${flag_shortlist} -gt 0 ]; then
  out="-f -v -h -s"
  die "${out}" 0
fi

if [ ${flag_file} -gt 0 ]; then
  if [ -z "${data}" ]; then
    printf "%sProvide data to upload%s\\n" "$ERROR" "$RESET"
  elif [ ! -f "${data}" ]; then
    printf "%s%s%s\\tFile not found.%s\\n" "$RESET" "${data}" "$ERROR" "$RESET"
    # attempt to split data and upload each string as file
    for f in ${data}
    do
      # if there's nothing to parse, skip this loop
      if [ "$f" = "$data" ]; then
        break;
      fi
      printf "%s${f}\\t%s" "$RESET" "$SUCCESS"
      if [ -f "${f}" ]; then
        curl -F"file=@${f}" "${ENDPOINT}"
        printf "%s" "$RESET"
      else
        printf "%sFile not found.%s\\n" "$ERROR" "$RESET"
      fi
    done
  else
    printf "%s${data}\\t%s" "$RESET" "$SUCCESS"
    curl -F"file=@${data}" "${ENDPOINT}"
    printf "%s" "$RESET"
  fi
else
  if [ -z "${data}" ]; then
    printf "%sNo data found for upload. Please try again.%s\\n" "$ERROR" "$RESET"
  else
    printf "%s" "$SUCCESS"
    printf "%s" "${data}" | curl -F"file=@-;filename=null.txt" "${ENDPOINT}"
    printf "%s" "$RESET"
  fi
fi

