#!/bin/bash
#
# Plex Linux Server download tool v2.6.3
# ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
# This tool will download the latest version of Plex Media
# Server for Linux. It supports both the public versions
# as well as the PlexPass versions.
#
# PlexPass users:
#     Set your credentials with variables PLEX_USERNAME and PLEX_PASSWORD
#
# Returns 0 on success
#         1 on error
#         2 if file already downloaded
#         3 if page layout has changed.
#         4 if download fails
#
# All other return values not documented.
#
# Enjoy!
#
# Version Description
# ^^^^^^^ ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#  1.0    Initial version, was able to download from plexapp
#  2.0    Initial version supporting plex.tv
#  2.1    Updated to use options and error codes
#  2.2          Layout changed, so code also changed. Added better
#               resiliance to HTML changes and also better error handling
#  2.3          Now reads an optional config file to avoid having to
#               modify this script.
#  2.4          Added support for the public versions of PMS
#  2.5          Supports autoinstall if root and given the option
#  2.6    Support for redhat derived distributions
#  2.6.2  Merge download dir support and moved config sourcing
#   (per request)
#  2.6.3  Added detection for wget to avoid issues downloading
#
#################################################################

: ${PKGEXT:='.deb'}

# Sanity check
if [ -z "$PLEX_USERNAME" ] || [ -z "$PLEX_PASSWORD" ]; then
  [ "$PUBLIC" = "no" ] && {
    echo "Error: Need username & password to download PlexPass version. Otherwise run with -p to download public version."
    exit 1
  }
fi

[ -d "/etc/plexupdate" ] || mkdir /etc/plexupdate

# Useful functions
rawurlencode() {
  local string="${1}"
  local strlen=${#string}
  local encoded=""

  for (( pos=0 ; pos<strlen ; pos++ )); do
    c=${string:$pos:1}
    case "$c" in
    [-_.~a-zA-Z0-9] ) o="${c}" ;;
    * )               printf -v o '%%%02x' "'$c"
  esac
  encoded+="${o}"
  done
  echo "${encoded}"
}

keypair() {
  local key="$( rawurlencode "$1" )"
  local val="$( rawurlencode "$2" )"

  echo "${key}=${val}"
}

# Setup an exit handler so we cleanup
function cleanup {
  rm -f /tmp/kaka >/dev/null 2>&1
  rm -f /tmp/postdata >/dev/null 2>&1
  rm -f "$DOWNLOADDIR/*" >/dev/null 2>&1
}
trap cleanup EXIT
trap cleanup EXIT 2 9 15 

# Fields we need to submit for login to work
#
# Field     Value
# utf8      &#x2713;
# authenticity_token  <Need to be obtained from web page>
# user[login]   $PLEX_USERNAME
# user[password]  $PASSWORD
# user[remember_me] 0
# commit    Sign in

# If user wants, we skip authentication, but only if previous auth exists
if [[ ! -f /tmp/kaka ]] && [ "$PUBLIC" = "no" ]; then
  echo -n "Authenticating..."
  # Clean old session
  rm /tmp/kaka 2>/dev/null

  # Get initial seed we need to authenticate
  SEED=$(wget --save-cookies /tmp/kaka --keep-session-cookies ${URL_LOGIN} -O - 2>/dev/null | grep 'name="authenticity_token"' | sed 's/.*value=.\([^"]*\).*/\1/')
  if [[ $? -ne 0 ]] || [[ "${SEED}" == "" ]]; then
    echo "Error: Unable to obtain authentication token, page changed?"
    exit 1
  fi

  # Build post data
  echo -ne  >/tmp/postdata  "$(keypair "utf8" "&#x2713;" )"
  echo -ne >>/tmp/postdata "&$(keypair "authenticity_token" "${SEED}" )"
  echo -ne >>/tmp/postdata "&$(keypair "user[login]" "${PLEX_USERNAME}" )"
  echo -ne >>/tmp/postdata "&$(keypair "user[password]" "${PLEX_PASSWORD}" )"
  echo -ne >>/tmp/postdata "&$(keypair "user[remember_me]" "0" )"
  echo -ne >>/tmp/postdata "&$(keypair "commit" "Sign in" )"

  # Authenticate
  wget --load-cookies /tmp/kaka --save-cookies /tmp/kaka --keep-session-cookies "${URL_LOGIN}" --post-file=/tmp/postdata -O /dev/null 2>/dev/null
  RET=$?

  # Delete authentication data ... Bad idea to let that stick around
  rm /tmp/postdata

  # Provide some details to the end user
  if [ ${RET} -ne 0 ]; then
    echo "Error: Unable to authenticate"
    exit 1
  fi
  echo "OK"
else
  # It's a public version, so change URL and make doubly sure that cookies are empty
  echo "Using public version"
  rm 2>/dev/null >/dev/null /tmp/kaka
  touch /tmp/kaka
  URL_DOWNLOAD=${URL_DOWNLOAD_PUBLIC}
fi

# Extract the URL for our release
echo -n "Finding download URL for ${RELEASE}..."

DOWNLOAD=$(wget --load-cookies /tmp/kaka --save-cookies /tmp/kaka --keep-session-cookies "${URL_DOWNLOAD}" -O - 2>/dev/null | grep "${PKGEXT}" | grep -m 1 "${RELEASE}" | sed "s/.*href=\"\([^\"]*\\${PKGEXT}\)\"[^>]*>${RELEASE}.*/\1/" )
echo -e "OK"

if [[ "${DOWNLOAD}" == "" ]]; then
  echo "Sorry, page layout must have changed, I'm unable to retrieve the URL needed for download"
  exit 3
fi

FILENAME="$(basename 2>/dev/null ${DOWNLOAD})"
if [ $? -ne 0 ]; then
  echo "Failed to parse HTML, download cancelled."
  exit 3
fi

if [[ "$FILENAME" == "$(cat /etc/plexupdate/version 2>/dev/null)" ]] && [[ ! "$FORCE" =~ "^[yY]" ]]; then
  echo "$FILENAME is current installed version. Bailing."
  exit 0
else
  echo "$FILENAME" > /etc/plexupdate/version
fi

echo -ne "Downloading release \"${FILENAME}\"..."
ERROR=$(wget --load-cookies /tmp/kaka --save-cookies /tmp/kaka --keep-session-cookies "${DOWNLOAD}" -O "${DOWNLOADDIR}/${FILENAME}" 2>&1)
CODE=$?
if [ ${CODE} -ne 0 ]; then
  echo -e "\n  !! Download failed with code ${CODE}, \"${ERROR}\""
  exit ${CODE}
fi
echo "OK"

if [[ -e /first_run ]]; then
  dpkg -i "${DOWNLOADDIR}/${FILENAME}"
  service plexmediaserver stop
  rm -f /usr/sbin/start_pms
  rm -f /first_run
  rm -f "${DOWNLOADDIR}/${FILENAME}"
elif [[ "${AUTOINSTALL}" = "yes" ]]; then
  supervisorctl stop plexmediaserver
  dpkg -i "${DOWNLOADDIR}/${FILENAME}"
  service plexmediaserver stop
  rm -f /usr/sbin/start_pms
  supervisorctl start plexmediaserver
  rm -f "${DOWNLOADDIR}/${FILENAME}"
fi

exit 0
