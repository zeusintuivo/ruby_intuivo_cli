#!/usr/bin/env bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#

set -u
# REQUIRED FOR strcuttesting start
export USER_HOME="${HOME}"
export DEBUG=0
# REQUIRED FOR strcuttesting end
typeset -i CPU_COUNT=1
if ( ! command -v nproc >/dev/null 2>&1; ) ; then {
  CPU_COUNT="$(nproc)"  # Linux
}
fi
if ( ! command -v sysctl >/dev/null 2>&1; ) ; then {
  CPU_COUNT="$(sysctl -n hw.logicalcpu)"  # Mac nproc same
}
fi
[ -z $CPU_COUNT ] && CPU_COUNT=1
[ $CPU_COUNT -lt 1 ] && CPU_COUNT=1

    load_struct_testing_wget() {
        local provider="$HOME/_/clis/execute_command_intuivo_cli/struct_testing"
        [   -e "${provider}"  ] && source "${provider}" && echo "Loading Struct Testing locally"
        command -v passed >/dev/null 2>&1 && echo "                              \.. loading succeeded " && return 0
        ( [ ! -e "${provider}"  ] || ( ! command -v passed >/dev/null 2>&1 ) ) && echo "Loading Struct Testing from the net " && eval """$(wget --quiet --no-check-certificate  https://raw.githubusercontent.com/zeusintuivo/execute_command_intuivo_cli/master/struct_testing -O -  2>/dev/null )"""   # suppress only wget download messages, but keep wget output for variable
        ( ( ! command -v passed >/dev/null 2>&1 ) && echo -e "\n \n  ERROR! Loading struct_testing \n \n " && return 1 )
        return 0
    }
    # end load_struct_testing_wget
    load_struct_testing_wget

function trim_start_space() {
    sed -e 's/^[[:space:]]*//' | sed 's/^\ //g' | sed 's/^\t//g'
}

function load_global_colors(){
  [[ -z "${BLACK-}" ]] && BLACK="\\033[38;5;16m"
  [[ -z "${BRIGHT_BLUE87-}" ]] && BRIGHT_BLUE87="\\033[38;5;87m"
  [[ -z "${CYAN-}" ]] && CYAN="\\033[38;5;123m"
  [[ -z "${GRAY241-}" ]] && GRAY241="\\033[38;5;241m"
  [[ -z "${GREEN-}" ]] && GREEN="\\033[38;5;22m"
  [[ -z "${PURPLE_BLUE-}" ]] && PURPLE_BLUE="\\033[38;5;93m"
  [[ -z "${PURPLE-}" ]] && PURPLE="\\033[01;35m"
  [[ -z "${RED-}" ]] && RED="\\033[38;5;1m"
  [[ -z "${RESET_PROMPT-}" ]] && RESET_PROMPT="[0m"
  [[ -z "${RESET-}" ]] && RESET="\\033[0m"
  [[ -z "${YELLOW220-}" ]] && YELLOW220="\\033[38;5;220m"
  [[ -z "${YELLOW226-}" ]] && YELLOW226="\\033[38;5;226m"
  [[ -z "${YELLOW-}" ]] && YELLOW="\\033[01;33m"
  [[ -z "${FROM_MAGENTA_NOT_VISIBLE-}" ]] && FROM_MAGENTA_NOT_VISIBLE="\\033[39m\\033[38;5;124m"
} # end load_global_colors
load_global_colors
load_temp_keys() {
     export GOOGLE_API_KEY="x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1xx1x1"
     export GOOGLE_CLIENT_ID="012345678900-gmk2gmk2gmk2gmk2gmk2gmk2gmk2gmk2.apps.googleusercontent.com"
     export GOOGLE_CLIENT_SECRET="QuerbyQuerbyErgoIpsonHop"
     export GOOGLE_EMAIL_DOMAIN="weise.box"
          local _temp_keys="empty"
          ! [ -f .temp_keys ] && echo -e "${RED} ERROR - .temp_keys file must exist. Use create_temp_keys script. Or touch .temp_keys" && exit 1
          [ -f .temp_keys ] && _temp_keys=$(<.temp_keys)
          . .temp_keys
          [[ "${_temp_keys}" == "empty" ]] && echo -e "${RED} ERROR - .temp_keys file must exist. Use create_temp_keys script. Or touch .temp_keys and must not be empty." && exit 1
          echo -e "${PURPLE_BLUE}  + TEMP KEYS NEED IT FOR: test/integration/inquiry_plugin_integration_test.rb"
          echo -e "${PURPLE_BLUE}  + "
          echo -e "${PURPLE_BLUE}  + PWD.                :${GRAY241}$(pwd)"
          [[ -z "${KEYS_NEEDED}" ]] && echo -e "${RED} ERROR - KEYS_NEEDED must be defined inside .temp_keys . Sample export KEYS_NEEDED=\"CHECK_REQUIREMENTS\""
          [[ -z "${CHECK_REQUIREMENTS}" ]] && echo -e "${RED} ERROR - CHECK_REQUIREMENTS must be defined inside .temp_keys . Sample export CHECK_REQUIREMENTS=\"mongo\npostgresql\""
          enforce_variable_with_value KEYS_NEEDED "${KEYS_NEEDED}"
          enforce_variable_with_value CHECK_REQUIREMENTS "${CHECK_REQUIREMENTS}"
          echo -e "${PURPLE_BLUE}  + KEYS_NEEDED.        :${GRAY241}${KEYS_NEEDED}"
          echo -e "${PURPLE_BLUE}  + CHECK_REQUIREMENTS  :${GRAY241}${CHECK_REQUIREMENTS}"
          echo -e "${PURPLE_BLUE}  + "
          return 0
} # end load_temp_keys
load_temp_keys

load_temp_env() {
          local _env="empty"
          local -i _err=0
          ! [ -f .env ] && echo -e "${RED} ERROR - .env file must exist. Use create_env script. Or touch .env" && exit 1
          [ -f .env ] && _env=$(<.env)
          . .env
          _err=$?
          [[ ${_err} -gt 0 ]] && echo -e "${RED} ERROR - .env file contains an error. Fix it" && exit 1
          [[ "${_env}" == "empty" ]] && echo -e "${RED} ERROR -  .env file must not be empty." && exit 1
          echo -e "${PURPLE_BLUE}  + .env needed for: entire project"
          echo -e "${PURPLE_BLUE}  + "
          echo -e "${PURPLE_BLUE}  + PWD.                :${GRAY241}$(pwd)"
          echo -e "${PURPLE_BLUE}  + "
          return 0
} # end load_temp_env
load_temp_env


check_keys_needed() {
  local name value requirement requirements="$(grep -vE '^\s+#|^#'<<<"${KEYS_NEEDED}")"
  for requirement in ${requirements} ; do
  {
    [[ -z "${requirement}" ]] && continue
    name="\$${requirement}"
    (( DEBUG )) && echo -e "${YELLOW220}  + name of variable  tested :${GRAY241} ${name}"
    value="$(eval "echo "${name}"")"
    (( DEBUG )) && echo -e "${YELLOW220}  + value of variable tested :${GRAY241} ${value}"
    echo -e "${PURPLE_BLUE}  + ${requirement}  :${GRAY241}${value}"
    [[ -z "${value}" ]] && echo -e "${RED} ERROR - key needed :${requirement}: must be defined inside .temp_keys or .env . Sample \nexport ${requirement}=\"some_value\""
    enforce_variable_with_value ${requirement} "${value}"
  }
  done
  return 0
} # end check_keys_needed
check_keys_needed

check_port_sudo(){
    local port="${1}"
    local service="${2}"
    echo "Require sudo to explore more on ports:"
    local response=""
    response="$(sudo lsof -n -i:${port} | grep LISTEN 2>&1 )" # whats_listening
    if [[ -n "${response}" ]] && [[ "${response}" == *"${service}"* ]] ; then
    {
      echo -e "${GREEN} PORT ${port} -- The ${service} port seems responding "
    }
    else
    {
      echo -e "${RED} ERROR ${service} NOT RUNNING ON PORT ${port}.      Check is install and running on that port   "
      exit 1
    }
    fi

}

check_port(){
  local port="${1}"
  local service="${2}"
# exec 6<>/dev/tcp/ip.addr.of.server/27017
# echo -e "GET / HTTP/1.0\n" >&6
# cat <&6

# exit 0

# linux
# netstat -lnt | awk '$6 == "LISTEN" && $4 ~ /\.27017$/'
# mac
# netstat -ant tcp | awk '$6 == "LISTEN" && $4 ~ /\.27017$/'
if [[ "$(uname)" == "Darwin" ]] ; then
{
  echo "# mac netstat"
  if ! (netstat -ant tcp | awk '$6 == "LISTEN" && $4 ~ /\.'${port}'$/' >/dev/null 2>&1 ); then
    echo -e "${GREEN} PORT ${port} -- The ${service} port seems responding "
  else
    check_port_sudo ${port} ${service}
  fi
}
else
{
  echo "# linux netstat"
  if ! (netstat -lnt | awk '$6 == "LISTEN" && $4 ~ /\.'${port}'$/' >/dev/null 2>&1 ); then
    echo -e "${GREEN} PORT ${port} -- The ${service} port seems responding "
  else
    check_port_sudo ${port} ${service}
  fi
}
fi


} # end check_port_mongo


check_port_mongo(){
if ! (netstat -ant tcp | awk '$6 == "LISTEN" && $4 ~ /\.27017$/' >/dev/null 2>&1 ); then
  echo "PORT 27017 -- The mongo port seems responding "
else
  # msg_red "ERROR MONGO NOT RUNNING ON PORT 27017.      Check is install and running on that port   "
  echo -e "${RED} ERROR MONGO NOT RUNNING ON PORT 27017.      Check is install and running on that port   "
  exit 1
fi
} # end check_port_mongo

check_port_postgresql(){
check_port 5432 postgresql
} # end check_port_postgresql


check_requirements(){
  local requirement requirements="$(grep -vE '^\s+#|^#'<<<"${@}")"
  for requirement in ${requirements} ; do
  {
    [[ -z "${requirement}" ]] && continue
    echo -e "Checking "${requirement}" "
    case "${requirement}" in
      'mongo' )
        check_port_mongo
        ;;
      'postgresql'  )
        check_port_postgresql
        ;;
    esac
  }
  done
} # end check_requirements

# check_requirements "${CHECK_REQUIREMENTS}"






THISSCRIPTNAME=`basename "$0"`
#
# C H E C K   R E P L A C E   F U N C T I O N S   I N S T A L L E D  --Start
#
check_replacer () {
  local REPLACER="$1"
  if command -v "${REPLACER}" >/dev/null 2>&1; then
  {
    # It looks installed
    # .. is it working properly
    # msg_green " ${1} INSTALLED."

    #stdout UND stderr -capture  REF: https://www.thomas-krenn.com/de/wiki/Bash_stdout_und_stderr_umleiten
    ${REPLACER}  --version &> /tmp/ersetze_test_${REPLACER}.txt
    local PROPERLYWORKING=$(cat /tmp/ersetze_test_${REPLACER}.txt)

    if [[ "$PROPERLYWORKING" == *"dyld:"* ]]; then { echo "error"; return;} fi
    if [[ $PROPERLYWORKING == *"GNU"* ]]; then { echo "GNU"; return;} else { echo "MAC";return;} fi
    echo "checked";
    return;
  }
  else
  {
    # msg_red "${GREEN} ${RED} CANNOT REPLACE ...${1} IS MISSING ";
    # msg_red " NEED TO INSTALL ${1}.       Linux:    sudo apt-get install ${1}         Mac:     brew install ${1}   "
    echo "install";
    return;
  }
  fi
}

msg_red () {
    echo -e "${RED} $@"
}

msg_green () {
    echo -e "${GREEN} $@"
}

msg_install () {
  msg_red "${GREEN} ${RED} CANNOT REPLACE ...${1} IS MISSING ";
  msg_red " NEED TO INSTALL ${1}. "
  echo -e "${YELLOW220}
        Linux:   debian  sudo apt-get install ${1}
                 redhat  sudo dnf install ${1}
          Mac:   brew install gnu-${1}

          ${2}
           "
}
# REPLACER="sed"; bix mehmetsafayildiz
# Try vim's ex
REPLACER="sed";
VALID_REPLACER=$(check_replacer "${REPLACER}")


if [[ $VALID_REPLACER == "error" ]] ; then
  msg_red "Error with replacer ${REPLACER}"
  msg_red " - Error:"
  cat /tmp/ersetze_test_${REPLACER}.txt
   rm /tmp/ersetze_test_${REPLACER}.txt
fi

# if [[ $VALID_REPLACER == "install" ]] ; then
#   msg_install "${REPLACER}"
# fi
rm /tmp/ersetze_test_${REPLACER}.txt

# TODO - Remove Repetition HERE
# ? empty still
# if [[ $VALID_REPLACER == "install" || $VALID_REPLACER == "error"  ]] ; then
#   REPLACER="sed";
#   VALID_REPLACER=$(check_replacer "${REPLACER}")

#   if [[ $VALID_REPLACER == "error" ]] ; then
#     msg_red "Error with replacer ${REPLACER}"
#     msg_red " - Error:"
#     cat /tmp/ersetze_test_${REPLACER}.txt
#      rm /tmp/ersetze_test_${REPLACER}.txt
#     exit 1;
#   fi

#   if [[ $VALID_REPLACER == "install" ]] ; then
#     msg_install "${REPLACER}"
#     rm /tmp/ersetze_test_${REPLACER}.txt
#     exit 1;
#   fi
# fi



REPLACER_GNU="NO"
if [[ $VALID_REPLACER == "GNU" ]] ; then
  REPLACER_GNU="YES"
fi

# Test
# echo "REPLACER_GNU: $REPLACER_GNU"
# echo "VALID_REPLACER: $VALID_REPLACER"
# exit
# C H E C K   R E P L A C E   F U N C T I O N S   I N S T A L L E D  -- RESULTS
# Results as
#             $REPLACER_GNU  NO OR YES
#             $REPLACER_GNU  ex or sed
#             halts execution if not found
#
# C H E C K   R E P L A C E   F U N C T I O N S   I N S T A L L E D  -- End

# if [[ $REPLACER_GNU == "NO" ]] ; then
#   msg_install "sed" "This script only works well with Gnu SED
#        On MAC:
#                 brew install gnu-sed
#                 which gsed
#                 /usr/local/bin/gsed
#                 /usr/bin/sed
#                 sudo mv /usr/bin/sed /usr/bin/sed_old
#                 cd /usr/bin
#                 sudo ln -s /usr/local/bin/gsed sed
#                 "
#   exit 1;
# fi

if [ ! -d .git ] ; then
{
  echo " "
  echo -e "${RED} ERROR: There is no .git/ directory. Looks like this is it not the root of the repo or is not a repo.${RESET}"
  echo " "
  exit 1
}
fi


if ! command -v bundle >/dev/null 2>&1; then
{
  echo " "
  echo -e "${RED}  ERROR: Bundle is not installed.${RESET}"
  echo " "
  exit 1
}
fi
#if [ ! -d .bundle/ ] ; then
# {
#  echo " "
#  echo -e "${RED} ERROR: There is no .bundle/ directory.${RESET}"
#  echo " "
#  exit 1
#}
#fi
if ! command -v rubocop >/dev/null 2>&1; then
{
  echo " "
  echo -e "${RED}  ERROR: Rubocop is not installed.${RESET}"
  echo " "
  exit 1
}
fi
if ! command -v git >/dev/null 2>&1; then
{
  echo " "
  echo -e "${RED}  ERROR: Git is not installed.${RESET}"
  echo " "
  exit 1
}
fi





if command -v git_current_branch >/dev/null 2>&1; then # git_current_branch polyfill
{
  echo " "
  echo -e "Get Branch git_current_branch installed"
}
else
{
  git_current_branch() {
    local ref
    ref=$(command git symbolic-ref --quiet HEAD 2> /dev/null)
    local ret=$?
    if [[ $ret != 0 ]]
    then
      [[ $ret = 128 ]] && return
      ref=$(command git rev-parse --short HEAD 2> /dev/null)  || return
    fi
    echo ${ref#refs/heads/}
  }
}
fi



# IFS='\n' # hack for force breaks inside "while -r read" and "for in" loops


add_ssspaceSSS_to_name(){
    local ONE_FILE="${1}"
    local FILERS=""
    local COUNTER=0
    local FILE_LONGEST=${2}
    FILE_LEN="${#ONE_FILE}"
    FILERS=" ${ONE_FILE}"
    COUNTER=$FILE_LEN
    (( COUNTER++ ))
    (( COUNTER++ ))
    until [ $COUNTER -ge $FILE_LONGEST ]; do
    {
      (( COUNTER++ ))
      FILERS="${FILERS}§"
    }
    done
    echo "${FILERS}"
} # end add_ssspaceSSS_to_name

interrupt_rubocop() {
    echo "${THISSCRIPTNAME} RUBOCOP INTERRUPT"
}
SPRING_PID=0
kill_spring(){
    FULL_SPEC_RUN=true RACK_ENV=test RAILS_ENV=test NODE_ENV=test COVERAGE=true CI_RSPEC=false bundle exec  spring stop
    wait
    if [ ${SPRING_PID} -gt 0 ] ; then
    {
      kill -9 ${SPRING_PID}
      wait
    }
    fi
    killall spring
}
start_spring(){
  SPRING_PID=$(FULL_SPEC_RUN=true RACK_ENV=test RAILS_ENV=test NODE_ENV=test COVERAGE=true CI_RSPEC=false bundle exec  spring server&)
}
interrupt_rspec() {
    echo "${THISSCRIPTNAME} RSPEC INTERRUPT"
    kill_spring
}
interrupt_integrations() {
    echo "${THISSCRIPTNAME} INTEGRATIONS INTERRUPT"
    kill_spring
}
interrupt_cucumbers() {
    echo "${THISSCRIPTNAME} CUCUMBERS INTERRUPT"
    kill_spring
}


OBSERVE='no'
ONLY_RUBOCOP='no'
SKIP_AUDIT='no'
[[ "${*}" == *"--observe"* ]] && OBSERVE='yes'
[[ "${*}" == *"--rubocop"* ]] && ONLY_RUBOCOP='yes'
[[ "${*}" == *"--only-rubocop"* ]] && ONLY_RUBOCOP='yes'
[[ "${*}" == *"--skip-audit"* ]] && SKIP_AUDIT='yes'


journal_get_target_branch_against(){
  # repated in journal_intuivo_cli/journal_get_target_branch_against journal_get_target_branch_against
	# trap '{ echo -e "${PURPLE_BLUE}  + ${GRAY241} Branch ${_against} ${RED}NOT ${GRAY241}found "; return 130; }' ERR
	local -i DEBUG=0
  local _against="${1}"
  (( DEBUG )) && echo -e "\njournal_get_target_branch_against${PURPLE_BLUE}  + ${GRAY241} Branch ${_against} found "
	if [[ -n "${_against}" ]] && [ "$(echo $(git branch --list "${_against}"))" ] ; then
	{
    _against="${1}"
	}
  else
	{
    (( DEBUG )) && echo "exit"
    return 1
	}
	fi
  local BRANCH=$(git_current_branch)
  local FILES1=$(git diff --name-only "${BRANCH}" $(git merge-base "${BRANCH}" "${_against}") | egrep "\.rb|\.rake")
  local FILES2=$(git status -sb | egrep -v "^(\sD)" | egrep -v "shared/pids/puma.state" | egrep -v "^(\?\?\spublic/assets)" | egrep -v "##" | cut -c4- | egrep -v "commit_exception\.list|.rubocop_todo.yml|\.xls|\.lock|\.tutorial|\.dir_bash_history|\.vscode|\.idea|\.git|\.description|\.editorconfig|\.env.development|\.env-sample|\.gitignore|\.pryrc|\.rspec|\.ruby\-version|db/patch|bundles|\.rubocop_todo.yml|\.rubocop.yml|\.simplecov|\.temp_keys|\.csv|\.sh|\.bash|\.yml|\.gitignore|\.log|\.txt|\.key|\.crt|\.csr|\.idl|\.json|\.js|\.jpg|\.png|\.html|\.gif|\.feature|\.scss|\.css|\.haml|\.erb|\.otf|\.svg|\.ttf|\.tiff|\.woff|\.eot|\.editorconfig|\.markdown|\.headings")
  local ONE_FILE="" FILES="" FILES_TMP=""
  FILES_TMP="${FILES1}
${FILES2}"

  FILES_TMP=$(echo "${FILES_TMP}" | sort | uniq)
  # // Only existing files - start
  while read -r ONE_FILE; do
  {
    [[ -z "${ONE_FILE}" ]] && continue # skip empty
    # echo "ONE_FILE::${ONE_FILE}::"
    [[ "${ONE_FILE}" == "--observe" ]] && OBSERVE='yes' && continue
    [[ -e "${ONE_FILE}" ]] || continue # skip non existent
    FILES="${FILES}
${ONE_FILE}"
  }
  done <<< "${FILES_TMP}"
  # // Only existing files - end
  echo "${FILES}"
  return 0
} # end journal_get_target_branch_against

# echo "$(journal_get_target_branch_against master)"
# echo "$(journal_get_target_branch_against main)"
# exit 0

function get_longest_line_number(){
  local FILES="${@}"
  FILES="${@}"
  local -i FILE_LONGEST=0
  local -i FILE_LEN=0
  local ONE_FILE=""
  while read -r ONE_FILE; do
  {
    [[ -z "${ONE_FILE}" ]] && continue
    FILE_LEN="${#ONE_FILE}"
    (( FILE_LEN > FILE_LONGEST )) &&  FILE_LONGEST=${FILE_LEN}
  }
  done <<< "${FILES}"
  (( FILE_LONGEST++ ))
  (( FILE_LONGEST++ ))
  echo ${FILE_LONGEST}
  return 0
} # end get_longest_line_number


function construct_title_rubocop(){
  local -i FILE_LONGEST=${1}
  local TITLE="  +----------${CYAN}Rubocop${PURPLE_BLUE}---${CYAN}checking${PURPLE_BLUE}---${CYAN}files${PURPLE_BLUE}-"
  local -i COUNTER=0
  until [ $COUNTER -ge $FILE_LONGEST ]; do
  {
    (( COUNTER++ ))
    if (( $COUNTER > 37 )) ; then   # 37 is the length of this line .../\... above without "colors" space
    {
      TITLE="${TITLE}-"
    }
    fi
  }
  done
  TITLE="${TITLE}+"
  echo -e "${TITLE}"
  return 0
} # end construct_title_rubocop
function repeat_char(){
  local -i FILE_LONGEST=${1}
  local char="${2}"
  local LINER=""
  local -i COUNTER=0
  until [ $COUNTER -ge $FILE_LONGEST ]; do
  {
    (( COUNTER++ ))
    LINER="${LINER}${char}"
  }
  done
  echo -e "${LINER}"
  return 0
} # end repeat_char


function construct_files_with_fillers(){
  # A filler is §
  # Adding fillers looks like
  # test/workers/twilio_cleaner_worker_test.rb§§§§§§§§§§§§§§§§§
  local -i FILE_LONGEST=${1}
  local ALL_FILLERS=""
  local FILES="${@:2}"
  local ONE_FILE=""
  local ONE_FILLER=""
  while read -r ONE_FILE; do
  {
    [[ -z "${ONE_FILE}" ]] && continue
    [[ ! -e "${ONE_FILE}" ]] && continue
    ONE_FILLER=$(add_ssspaceSSS_to_name "${ONE_FILE}" ${FILE_LONGEST})
    ALL_FILLERS="${ALL_FILLERS}
${ONE_FILLER}"
  }
  done <<< "${FILES}"
  echo -n "${ALL_FILLERS}"
  return 0
} # end construct_files_with_fillers


function output_fillers_to_stdout(){
  local ONE_FILLER=""
  local ALL_FILERS="${@}"
  while read -r ONE_FILLER; do
  {
    [[ -z "${ONE_FILLER}" ]] && continue
    echo -e "  ${PURPLE_BLUE}+${CYAN} ${ONE_FILLER} ${PURPLE_BLUE}+" | sed 's@§@ @g'
  }
  done <<< "${ALL_FILERS}"
  return 0
}  # end output_fillers_to_stdout


# Function to try getting target branch against a specified branch
try_get_target_branch() {
  local branch=$1
  FILES="$(journal_get_target_branch_against "$branch")"
  _err=$?

  # Check for errors and print messages
  if [ ${_err} -gt 0 ]; then
    echo -e "${PURPLE_BLUE}  + $LINENO ${CYAN}failed _err:${RED}$_err ${branch} branch${GRAY241}"
  fi

  return $_err
}

# Initialize FILES to an empty string
FILES=""

# Try getting target branch against 'master', then 'main' if the former fails
if ! try_get_target_branch "master"; then
  if ! try_get_target_branch "main"; then
    echo -e "${PURPLE_BLUE}  + ${RED} Master and Main branches not found"
  fi
fi


rubocop_testing(){
  DEBUG=1
  local _err=$?
  trap interrupt_rubocop INT
  local BRANCH=$(git_current_branch)
  echo " "
  echo
  echo -e "${PURPLE_BLUE} === Branch ${CYAN} ${BRANCH} ${PURPLE_BLUE} === ${GRAY241} ";
  echo
  echo " "
  echo -e "${YELLOW220} STAGE 1: ${CYAN} Rubocop only files from this branch"
  echo -e "${PURPLE_BLUE}+-+"
  echo -e "  +"
  echo -e "  +-- ${CYAN} Locating files that changes in this branch "
  echo -e "${PURPLE_BLUE}  +${GRAY241}"
  local FILES=""
  FILES="$(journal_get_target_branch_against master)"
	_err=$?
 	if [ ${_err} -gt 0 ] ; then
	{
		echo -e "${PURPLE_BLUE}  + ${CYAN}failed _err:${RED}$_err master branch${GRAY241}"
	  FILES="$(journal_get_target_branch_against main)"
	  _err=$?
 	  if [ ${_err} -gt 0 ] ; then
		{
			echo -e "${PURPLE_BLUE}  + $LINENO ${CYAN}failed _err:${RED}$_err main branch${GRAY241}"
      echo -e "${PURPLE_BLUE}  + ${RED} Master and Main branches not found"
		}
		fi
 	}
	fi


  local -i NUMBER_LEN="${#FILES}"

  if (( ${NUMBER_LEN} == 0  )) ; then
  {
    echo -e "${PURPLE_BLUE}  + ${RED}No files found for rubocop"
  }
  else
  {

    echo -e "${PURPLE_BLUE}  +"

    local -i FILE_LONGEST=0
    FILE_LONGEST=$(get_longest_line_number "${FILES}")
    local TITLER=""
    TITLER="$(construct_title_rubocop "${FILE_LONGEST}")"
    local SPACER=""
    SPACER="$(repeat_char "${FILE_LONGEST}" " ")"
    local LINER=""
    LINER="$(repeat_char "${FILE_LONGEST}" "-")"

    echo -e "${TITLER}"
    echo -e "${PURPLE_BLUE}  +${SPACER}+ "
    echo -e "~~+${SPACER}+~~${GRAY241}"

    local ALL_FILERS=""
    ALL_FILERS=$(construct_files_with_fillers "${FILE_LONGEST}" "${FILES}")
    output_fillers_to_stdout "${ALL_FILERS}"

    echo -e "${PURPLE_BLUE}  +${SPACER}+ "
    echo -e "~~+${SPACER}+~~${GRAY241}"
    # /// ----- rubocop group test --  start
    (( DEBUG )) && echo "bundle exec rubocop -A "${FILES}
    local RUBOCOP_RESULT BUNDLING
    # bundle exec rubocop -A ${FILES} 2>&1 | tee "${RUBOCOP_RESULT}"
    RUBOCOP_RESULT="$(bundle exec rubocop -A ${FILES} 2>&1)"
    _err=$?
    if [ ${_err} -gt 0 ] ; then
    {
      if [[ -n "${RUBOCOP_RESULT}" ]] && [[ "${RUBOCOP_RESULT}" != *"could not find"* ]]; then
      {
        echo -e "  ${RED}+${YELLOW220} $LINENO ${RUBOCOP_RESULT} ${RED}+ FAILED first attempt to run rubocop .F.. Attempting to bundle"
        BUNDLING="$(bundle  2>&1)"
        _err=$?
        if [ ${_err} -gt 0 ] ; then
        {
          echo -e "  ${RED}+${YELLOW220} ${BUNDLING} ${RED}+ FAILED attempt to run bundle"
          echo -e "  ${RED}+${YELLOW220}---${RESET} Fix bundle then try again "
          exit 1
        }
        fi
        echo "bundle exec rubocop -A ${FILES}"
        RUBOCOP_RESULT=$(bundle exec rubocop -A "${FILES}" 2>&1)
        _err=$?
        # /// ----- one line per line --  start
        for ONE_FILE in ${FILES}; do
        {
          [ -z "${ONE_FILE}" ] && continue
          [ -e "${ONE_FILE}" ] || continue
          echo "bundle exec rubocop -A ${ONE_FILE}"
          RUBOCOP_RESULT="$(bundle exec rubocop -A "${ONE_FILE}" 2>&1)"
          _err=$?
          if [ ${_err} -gt 0 ] ; then
          {
            if [[ -n "${RUBOCOP_RESULT}" ]] && [[ "${RUBOCOP_RESULT}" != *"could not find"* ]]; then
            {
              echo -e "  ${RED}+${YELLOW220} $LINENO ${RUBOCOP_RESULT} ${RED}+ FAILED first attempt to run rubocop ..F. Attempting to bundle"
              BUNDLING="$(bundle  2>&1)"
              _err=$?
              if [ ${_err} -gt 0 ] ; then
              {
                echo -e "  ${RED}+${YELLOW220} ${BUNDLING} ${RED}+ FAILED attempt to run bundle"
                echo -e "  ${RED}+${YELLOW220}---${RESET} Fix bundle then try again "
                exit 1
              }
              fi
              echo "bundle exec rubocop -A ${ONE_FILE}"
              RUBOCOP_RESULT=$(bundle exec rubocop -A "${ONE_FILE}" 2>&1)
            }
            fi
          }
          fi

          if [ -n "${RUBOCOP_RESULT}" ] && [[ "${RUBOCOP_RESULT}" != *"no offenses detected"* ]]; then
          {
            FILERS=$(add_ssspaceSSS_to_name "${ONE_FILE}" $FILE_LONGEST)
            echo -e "  ${RED}+${YELLOW220} ${FILERS} ${RED}+ FAILED" | sed 's@§@ @g'
            while read -r  RUBOCOP_RESULT_LINE; do
            {
              echo -e "  ${RED}+${YELLOW220}---${RESET} ${RUBOCOP_RESULT_LINE}  "
            }
            done <<< "${RUBOCOP_RESULT}"
          }
          fi
        }
        done
        # /// ----- one line per line --  end
      }
      fi
    }
    fi
    if [ -n "${RUBOCOP_RESULT}" ] && [[ "${RUBOCOP_RESULT}" != *"no offenses detected"* ]]; then
    {
      FILERS=$(add_ssspaceSSS_to_name "${FILES}" $FILE_LONGEST)
      echo -e "  ${RED}+${YELLOW220} ${FILERS} ${RED}+ FAILED" | sed 's@§@ @g'
      while read -r  RUBOCOP_RESULT_LINE; do
      {
        echo -e "  ${RED}+${YELLOW220}---${RESET} ${RUBOCOP_RESULT_LINE}  "
      }
      done <<< "${RUBOCOP_RESULT}"
    }
    fi
    # /// ----- rubocop group test --  end

    #echo "${FILES}" | sort -n | uniq | xargs bundle exec rubocop -A
    if [ ${_err} -gt 0 ] ;  then
    {
      echo -e "${PURPLE_BLUE}  + ${RED} Rubocop errors. Please fix  "
      echo -e "${PURPLE_BLUE}  + ${CYAN}"
      echo -e "${PURPLE_BLUE}  + ${CYAN}"
      exit 130;
    }
    fi
    echo -e "${PURPLE_BLUE}~~+${SPACER}+~~"
    echo -e "  +${SPACER}+ "
  }
  fi
  [[ -z "${LINER-}" ]] && LINER="$(repeat_char "80" "-")"
  echo -e "${PURPLE_BLUE}  +${LINER}+ ${GRAY241}"


} # end rubocop_testing
rubocop_testing
if [[ "${ONLY_RUBOCOP}" == 'yes' ]] ; then
{
  exit 0
}
fi

ruby_audit_i18n_tasks_test(){
  # ( command -v i18n-tasks >/dev/null 2>&1 ) && found=1
  #  ( ! bundle info i18n-tasks   >/dev/null 2>&1  ) && echo "not"
  if ( ! bundle info i18n-tasks   >/dev/null 2>&1  ) ; then
  {
    echo -e "  ${RED}+${YELLOW220} i18n-tasks ${RED}+ NOT FOUND ...${PURPLE}  Attempting to install and add to bundle"
    echo -e "  ${RED}+${YELLOW220} i18n-tasks ${RED}+ skipping ${YELLOW220}...."
    echo -e " NOTE:TODO:NOTE TO SELF: PERHAPS ADD yes_no TO attempt to install"
    return 0
    # gem install i18n-tasks
    # bundle add i18n-tasks
  }
  fi
  FULL_SPEC_RUN=true RACK_ENV=test RAILS_ENV=test NODE_ENV=test COVERAGE=true CI_RSPEC=false  bundle exec   i18n-tasks missing
  _err=$?
  if [ ${_err} -gt 0 ] ;  then
  {
    echo -e "${PURPLE_BLUE}  + Error running    "
    echo -e "${PURPLE_BLUE}  + ${RED} bundle exec i18n-tasks missing ${PURPLE_BLUE} ${CYAN}"
    echo -e "${PURPLE_BLUE}  + ${YELLOW} Please fix${CYAN}"
    exit 130;
  }
  fi
  FULL_SPEC_RUN=true RACK_ENV=test RAILS_ENV=test NODE_ENV=test COVERAGE=true CI_RSPEC=false  bundle exec   i18n-tasks normalize
  _err=$?
  if [ ${_err} -gt 0 ] ;  then
  {
    echo -e "${PURPLE_BLUE}  + Error running    "
    echo -e "${PURPLE_BLUE}  + ${RED} bundle exec i18n-tasks normalize ${PURPLE_BLUE} ${CYAN}"
    echo -e "${PURPLE_BLUE}  + ${YELLOW} Please fix${CYAN}"
    exit 130;
  }
  fi
}
if [[ "${SKIP_AUDIT}" == 'yes' ]] ; then
{
  echo "--skip-audit Skipping ruby_audit_i18n_tasks_test"
}
else
{
  ruby_audit_i18n_tasks_test
}
fi


ruby_audit_advisory_test(){
  # if ! command -v bundle-audit >/dev/null 2>&1  ; then
  local -i _added=0
  local -i _found=0
  local _auditors="
  bundler-audit|gem install bundler-audit|bundle add bundler-audit|bundle exec bundler-audit check --update
  bundle-audit|gem install bundle-audit|bundle add bundle-audit|bundle exec bundle-audit check --update
  "
  local _name_auditer=bundler-audit
  local _one
  local _name=""
  local _gem_install=""
  local _bundle_add_install=""
  local _audit_run=""
  while read -r _one ; do
  {
    [[ -z "${_one}" ]] && continue
    _name_auditer=$(cut -d'|' -f1 <<< "${_one}" )
    _gem_install=$(cut -d'|' -f2 <<< "${_one}" )
    _bundle_add_install=$(cut -d'|' -f3 <<< "${_one}" )
    _audit_run=$(cut -d'|' -f4 <<< "${_one}" )
    [[ -z "${_name_auditer}" ]] && continue
    if ( ! bundle info "${_name_auditer}"   >/dev/null 2>&1  ) ; then
    {
      echo -e "  ${RED}+${YELLOW220} "${_name_auditer}" ${RED}+ NOT FOUND ...${PURPLE}  Attempting to install  ${_name_auditer}  and add to bundle"
      ${_gem_install}
      ${_bundle_add_install}
    }
    fi
    bundle info "${_name_auditer}"
    _err=$?
    if [ ${_err} -eq 7 ] ;  then
    {
      echo -e "  ${RED}+${YELLOW220} bundle-audit ${RED}+ not Gemfile ...${PURPLE}  Attempting add to bundle again  ${_name_auditer} "
      ${_gem_install}
      ${_bundle_add_install}
    }
    fi
    if [ ${_err} -eq 0 ] ;  then
    {
      _found=1
      _added=1
    }
    fi
  }
  done <<< "${_auditors}"
  if [ ${_found} -eq 1 ] ; then
  {

    # RACK_ENV=test RAILS_ENV=test NODE_ENV=test COVERAGE=true CI_RSPEC=false  bundle exec bundle-audit check --update --ignore CVE-2015-9284 CVE-2019-25025
    echo "FULL_SPEC_RUN=true RACK_ENV=test RAILS_ENV=test NODE_ENV=test COVERAGE=true CI_RSPEC=false  ${_audit_run} --ignore CVE-2015-9284 CVE-2019-25025"
    FULL_SPEC_RUN=true RACK_ENV=test RAILS_ENV=test NODE_ENV=test COVERAGE=true CI_RSPEC=false  ${_audit_run} --ignore CVE-2023-38037 CVE-2023-40175 CVE-2023-26141 CVE-2023-28362
    _err=$?
  }
  fi
  if [ ${_err} -gt 0 ] ;  then
  {
    [ ${_added} -gt 0 ] && git checkout Gemfile Gemfile.lock
    echo -e "${PURPLE_BLUE}  + ${RED} Ruby Audit Advisory errors. Please fix  "
    echo -e "${PURPLE_BLUE}  + ${CYAN}"
    echo -e "${PURPLE_BLUE}  + ${CYAN}"
    exit 130;
  }
  fi
  [ ${_added} -gt 0 ] && git checkout Gemfile Gemfile.lock
}
if [[ "${SKIP_AUDIT}" == 'yes' ]] ; then
{
  echo "--skip-audit Skipping ruby_audit_advisory_test"
}
else
{
  ruby_audit_advisory_test
}
fi


extract_version(){
  sed -nre 's/^[^0-9]*(([0-9]+\.)*[0-9]+).*/\1/p'
}

find_location_rake_lib() {
  (( DEBUG )) && echo -e "${YELLOW226}  find_location_rake_lib => ${CYAN} "
  local rake_version=$(rake --version 2>&1 | extract_version) # Check and catch capture all stout sdout output, error will return none 0 to $?)
  (( DEBUG )) && echo -e "${YELLOW220} rake_version: ${CYAN} ${rake_version}"
  # ALTERNATIVE: local rake_version2=$(gem list rake | grep "^rake (*.*.*)" | extract_version) # Check and catch capture all stout sdout output, error will return none 0 to $?)
  local rake_location=$(which rake | sed 's/bin\/rake//g')
  (( DEBUG )) && echo -e "${YELLOW220} rake_location: ${CYAN} ${rake_location}"
  local ruby_version=$(ruby --version | extract_version)
  (( DEBUG )) && echo -e "${YELLOW220} ruby_version: ${CYAN} ${ruby_version}"


  if command -v launchctl >/dev/null 2>&1  ; then
  {
    (( DEBUG )) &&  echo -e "${YELLOW220} launchctl: ${CYAN} mac "
    if [[ ! -e /var/db/locate.database ]]  ; then
    {
      (( DEBUG )) &&  echo -e "${YELLOW220} launchctl: ${CYAN} /var/db/locate.database exists "
    }
    else
    {
      (( DEBUG )) &&  echo -e "${YELLOW220} launchctl: ${CYAN} /var/db/locate.database creating ..."
      sudo -u root -i -- launchctl load -w /System/Library/LaunchDaemons/com.apple.locate.plist
    }
    fi
  }
  else
  {
    (( DEBUG )) &&  echo -e "${YELLOW220} updatedb: ${CYAN}  "
    command -v updatedb >/dev/null 2>&1  && sudo -u root -i --  sudo updatedb &
    # THIS_RUBY_VERSION=$(ruby --version  | cut -d' ' -f2 | cut -d'p' -f1)
    # Then get folder based on ruby version 2.2.5 and rake version 10.5.0 used for development
    local rake_variable_lib_folder=$(locate test_loader.rb | grep "rake-*.*.*/lib" | grep "ruby-${ruby_version}" | grep "rake-${rake_version}" | head -1 )  # RVM Type environment
    echo -e "${YELLOW220} rake_variable_lib_folder: ${CYAN} ${rake_variable_lib_folder}"
    [ -z "${rake_variable_lib_folder}" ] && rake_variable_lib_folder=$(locate test_loader.rb | grep "rake-*.*.*/lib" | grep "${ruby_version}" | head -1 )         # Other  Install Type environment macthing ruby and gem version
    [ -z "${rake_variable_lib_folder}" ] && rake_variable_lib_folder=$(locate test_loader.rb | grep "rake-*.*.*/lib" | head -1 )  # Ruby compiled installed with WGET, or GEM install folder is not matching to rake install, just get the first one
  }
  fi

  local rake_variable_lib_folder="$(gem info rake | grep "${rake_version}" | grep "Installed" | cut -d: -f2 )"
  (( DEBUG )) && echo -e "${PURPLE_BLUE}  + ${YELLOW220} rake_variable_lib_folder: ${rake_variable_lib_folder}"
  rake_variable_lib_folder="${rake_variable_lib_folder}/gems/rake-${rake_version}/lib"
  (( DEBUG )) && echo -e "${PURPLE_BLUE}  + ${YELLOW220} rake_variable_lib_folder: ${rake_variable_lib_folder}"
  # rake_variable_lib_folder="${rake_variable_lib_folder}/gems/rake-${rake_version}/lib/rake/rake_test_loader.rb"
  #  if [ -d "${HOME}/.rvm/" ] ; then
  #  {
  #      local rake_folder=$(find "${HOME}"/.rvm/ -name "rake-${rake_version}")
  #      local task_manager_location=$(find "${HOME}"/.rvm/ -name "task_manager.rb" | grep "rake-${rake_version}")
  #  }
  #  else
  #  {
  #      local rake_folder=$(locate rake | grep $rake_version | grep -ve test | grep rake.rb$ | sed 's/rake.rb//g' )
  #      local task_manager_location=$(locate rake | grep $rake_version | grep task_manager.rb | grep -ve test)
  #  }
  #  fi
  #  if [ -z "${rake_folder}" ] || [ -z "${task_manager_location}" ] || [ ! -d "${rake_folder}/" ]; then
  #  {
  #      local rake_folder=$(locate rake | grep $rake_version | grep -ve test | grep rake.rb$ | sed 's/rake.rb//g' )
  #      local task_manager_location=$(locate rake | grep $rake_version | grep task_manager.rb | grep -ve test)
  #  }
  #  fi
  # echo " "
  # echo -e " ${GREEN} rake_location${RED}:${CYAN}${rake_location} "
  # echo -e " ${GREEN} rake_folder${RED}:${CYAN}${rake_folder} "
  # #echo -e " ${GREEN} ruby_version${RED}:${CYAN}${ruby_version} "
  # echo -e " ${GREEN} rake_version${RED}:${CYAN}${rake_version} "
  # echo -e " ${GREEN} task_manager_location${RED}:${CYAN}${task_manager_location} "
  # echo -e " ${GREEN} rake_variable_lib_folder${RED}:${CYAN}${rake_variable_lib_folder} "
  echo "${rake_variable_lib_folder}"

} # end find_location_rake_lib


rake_lib_folder() {
              (( DEBUG )) && echo -e "${YELLOW226}  rake_lib_folder => ${CYAN} "
              LOCATION_RAKE_LIB="$(find_location_rake_lib | tail -1)"
              (( DEBUG )) && echo -e "${PURPLE_BLUE}  + ${YELLOW220} LOCATION_RAKE_LIB: ${LOCATION_RAKE_LIB}"
              if [[ -z "${LOCATION_RAKE_LIB}" ]] ; then
              {
                echo -e "${PURPLE_BLUE}  + ${YELLOW220}WARNING COULD NOT FIND  test_loader.rb "
                echo -e "${PURPLE_BLUE}  + ${CYAN}"
                echo -e "${PURPLE_BLUE}  + ${CYAN}Attempting to run ${YELLOW220} sudo updatedb "
                sudo updatedb
                wait
                echo -e "${PURPLE_BLUE}  + ${CYAN}"
                echo -e "${PURPLE_BLUE}  + ${YELLOW220} Attempting to find test_loader.rb  again"
                LOCATION_RAKE_LIB=$(find_location_rake_lib)
                wait
                if [[ -z "${LOCATION_RAKE_LIB}" ]] ; then
                {
                  echo -e "${PURPLE_BLUE}  + ${RED}DID NOT FIND test_loader.rb "
                  echo -e "${PURPLE_BLUE}  + ${CYAN}"
                  echo -e "${PURPLE_BLUE}  + ${CYAN} I Will keep running but this could cause it not to run. ${YELLOW220}Cross fingers"
                  echo -e "${PURPLE_BLUE}  + ${CYAN}"
                }
                fi
              }
              fi

              RAKELOADER_LIB_FOLDER=$(echo ${LOCATION_RAKE_LIB%/*})
              RAKE_LIB_FOLDER=$(echo ${RAKELOADER_LIB_FOLDER%/*})
              RAKE_EXECUTABLE="\"${LOCATION_RAKE_LIB}\" \"${LOCATION_RAKE_LIB}/rake/rake_test_loader.rb\""
RAKE_EXECUTABLE=$(echo "${RAKE_EXECUTABLE}" | sed 's/" /"/g' )
              # ALL THE TESTS
              #ruby -I\"lib:test\" -I\"${RAKE_LIB_FiOLDER}\"                               \"${LOCATION_RAKE_LIB}\"  "                                              ${_integration_tests_exists}
              #ruby -I"lib:test" -I"$HOME/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib" "$HOME/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib/rake/rake_test_loader.rb" "test/models/insurance_test.rb" "test/workers/twilio_cleaner_worker_test.rb"

              # Email
              # ruby -I"lib:test" -I"$HOME/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib" "$HOME/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib/rake/rake_test_loader.rb"  "test/lib/tasks/cleanup_email_test.rb"

              # ruby -I"lib:test" -I"$HOME/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib" "$HOME/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib/rake/rake_test_loader.rb"  "test/lib/tasks/cleanup_sms_test.rb"
} # end rake_lib_folder

find_rake_lib_and_add_it_to_temp_keys() {
  (( DEBUG )) && echo -e "${YELLOW226}  find_rake_lib_and_add_it_to_temp_keys => ${CYAN} "

    rake_lib_folder

    echo "              GLOBALS : ------"
    echo "    LOCATION_RAKE_LIB : $LOCATION_RAKE_LIB"
    echo "RAKELOADER_LIB_FOLDER : $RAKELOADER_LIB_FOLDER"
    echo "      RAKE_LIB_FOLDER : $RAKE_LIB_FOLDER"
    echo "      RAKE_EXECUTABLE : $RAKE_EXECUTABLE"
    local temp=$(escape_double_quotes <<< "${RAKE_EXECUTABLE}")
    (_if_not_contains  ".temp_keys" "export RAKE_EXECUTABLE=") || echo "export RAKE_EXECUTABLE=\"$temp"\" >> ".temp_keys"
    # if [[ -f "./.temp_keys" ]] ; then
    # {
    #   if ! echo .temp_keys | grep "export RAKE_EXECUTABLE" ; then
    #   {
    #     local temp=$(escape_double_quotes <<< "${RAKE_EXECUTABLE}")
    #     echo -e "\n"  >> .temp_keys
    #     sed -i '/export RAKE_EXECUTABLE=/d' .temp_keys
    #     echo "export RAKE_EXECUTABLE=\"$temp"\"   >> .temp_keys
    #   }
    #   fi
    # }
    # fi
} # end find_rake_lib_and_add_it_to_temp_keys

kill_execution() {
  echo -e " ☠ ${LIGHTPINK} KILL EXECUTION SIGNAL SEND ${RESET}"
  exit 69;
} # end kill_execution

failed() {
    ARGS="${@}"
    if [[ -n "${ARGS-x}" ]] ; then # if its set and not empty
    {
      echo -e "${RED} 𝞦 ${LIGHTYELLOW} ${ARGS} ${RED} has failed!  ${RESET}"
      kill_execution
    }
    fi
} # end failed

escape_backslashes() {
    sed 's/\\/\\\\/g'
} # end escape_backslashes

escape_double_quotes() {
    sed 's/\"/\\\"/g'
} # end escape_double_quotes

remove_double_quotes() {
  sed 's/\"//g'
} # end remove_double_quotes

lib_folder_exists() {
  local testing=$(echo "${RAKE_EXECUTABLE}" | remove_double_quotes | sed 's/ /\n/g' | grep -e "lib$")
  [ ! -d  "${testing}/"  ] && return 1
  return 0
} # end lib_folder_exists

loader_file_exists() {
  local testing=$(echo "${RAKE_EXECUTABLE}" | remove_double_quotes | sed 's/ /\n/g' | grep -e "_loader.rb$" )
  (( DEBUG )) && echo "${RAKE_EXECUTABLE}"
  (( DEBUG )) && echo "echo \"${RAKE_EXECUTABLE}\" | remove_double_quotes"
  (( DEBUG )) && echo "${RAKE_EXECUTABLE}" | remove_double_quotes
  (( DEBUG )) && echo "echo \"${RAKE_EXECUTABLE}\" | remove_double_quotes | sed 's/ /\n/g'"
  (( DEBUG )) && echo "${RAKE_EXECUTABLE}" | remove_double_quotes | sed 's/ /\n/g'
  (( DEBUG )) && echo "echo \"${RAKE_EXECUTABLE}\" | remove_double_quotes | sed 's/ /\n/g' | grep -e \"_loader.rb$\""
  (( DEBUG )) && echo "${RAKE_EXECUTABLE}" | remove_double_quotes | sed 's/ /\n/g' | grep -e "_loader.rb$"
  echo "[ ! -f  \"${testing}\"  ] && return 1"
  [ ! -f  "${testing}"  ] && echo "+--- return 1"
  [ ! -f  "${testing}"  ] && return 1
  [ ! -f  "${testing}"  ] && echo "+--- return 0"
  return 0
} # end loader_file_exists

verify_rake_executable() {
    ! lib_folder_exists && failed Lib folder for testing was not found .. ${GREEN} I am looking for something like \"rake-11.3.0/lib\"
    ! loader_file_exists && failed Loader file for loading tests was not found .. ${GREEN} I am looking for something like \"rake-11.3.0/lib/rake/rake_test_loader.rb\"
} # end verify_rake_executable

lib_folder_and_loader_file_exist() {
    ( lib_folder_exists && loader_file_exists )  && return 0
    return 1
} # end lib_folder_and_loader_file_exist

obtain_rake_executable() {
  (( DEBUG )) && echo -e "${YELLOW226}  obtain_rake_executable => ${CYAN} "
  (( DEBUG )) && echo -e "${YELLOW220}     RAKE_EXECUTABLE: ${CYAN} ${RAKE_EXECUTABLE}"
  if [[ -z "${RAKE_EXECUTABLE}" ]] ; then
  {
    (( DEBUG )) && echo -e "${YELLOW220}     RAKE_EXECUTABLE empty: ${CYAN} ${RAKE_EXECUTABLE}"
    find_rake_lib_and_add_it_to_temp_keys
    verify_rake_executable
  }
  else
  {
    (( DEBUG )) && echo -e "${YELLOW220} RAKE_EXECUTABLE else empty: ${CYAN} ${RAKE_EXECUTABLE}"
  # exit 0
  #   if ! lib_folder_and_loader_file_exist ; then
  #   {
  #     echo -e "${PURPLE_BLUE}  + ${YELLOW220} Executable of Folder Lib, loader.rb From .temp_key Not executing correctly. Attempting to seek again "
  #     find_rake_lib_and_add_it_to_temp_keys
  #     verify_rake_executable
  #   }
  #   fi
  }
  fi
} # end obtain_rake_executable

echo " "
echo -e "${YELLOW220} STAGE 2: ${CYAN} Find Rake File... which runs tests"
echo -e "${PURPLE_BLUE}+-+"
echo -e "  +"

[[ -z "${LINER-}" ]] && LINER="$(repeat_char "80" "-")"
echo -e "${PURPLE_BLUE}  +${LINER}+ ${GRAY241}"

obtain_rake_executable
# echo hola && exit 0
echo " "
echo -e "${YELLOW220} STAGE 3: ${CYAN} Check testing requirements"
echo -e "${PURPLE_BLUE}+-+"
echo -e "  +"

[[ -z "${LINER-}" ]] && LINER="$(repeat_char "80" "-")"
echo -e "${PURPLE_BLUE}  +${LINER}+ ${GRAY241}"
# check_requirements "${CHECK_REQUIREMENTS}"

  # FILES="$(journal_get_target_branch_against master)"
	# _err=$?
 	# if [ ${_err} -gt 0 ] ; then
	# {
	# 	echo -e "${PURPLE_BLUE}  + ${CYAN}failed _err:${RED}$_err master branch${GRAY241}"
	#   FILES="$(journal_get_target_branch_against main)"
	#   _err=$?
 	#   if [ ${_err} -gt 0 ] ; then
	# 	{
	# 		echo -e "${PURPLE_BLUE}  + $LINENO ${CYAN}failed _err:${RED}$_err main branch${GRAY241}"
  #     echo -e "${PURPLE_BLUE}  + ${RED} Master and Main branches not found"
	# 	}
	# 	fi
 	# }
	# fi

function _filter_files_test_rpec_feaure_only() {
  # $(egrep "^test|^spec|^feature|_test\.rb|_spec\.rb|\.feature" <<< ${one})"
  local _all_test_files=""
  local _files="${@}"
  local _one=""
  while read -r _one; do
  {
    [[   -z "${_one}" ]] && continue
    [[ ! -e "${_one}" ]] && continue
    ( grep -q "_test.rb[[:space:]]*$"  <<< "${_one}" ) \
    || ( grep -q "_spec.rb[[:space:]]*$"  <<< "${_one}" ) \
    || ( grep -q ".feature[[:space:]]*$"  <<< "${_one}" ) && _all_test_files="${_all_test_files}
${_one}"
  }
  done <<< "${_files}"
  # we want simple check and not quotations to ignoee white spaces
  [[ -z "${_all_test_files}" ]] && return 1

  echo -n "${_all_test_files}"
  return 0
} # end _filter_files_test_rpec_feaure_only


  # function _priorities_passed_files_diff_all() {
  echo "global FILES"
  echo "global DIFFFILES"
  echo "global DOALLTESTS"
  DOALLTESTS='yes'
  echo About to test FILES:${FILES}:
  DIFFFILES="${FILES}"              # array ?
  echo "Backup FILES DIFFFILES:${DIFFFILES}:"
  [[ -n "${1:-}" ]] && FILES="${@}" # array ? expecting a list of files with spaces
  [[ -n "${1:-}" ]] && echo -en "${0}:${LINENO} I think I got something to test::${1:-}:: About to test FILES::${FILES}:: "
  [[ -n "${1:-}" ]] && DOALLTESTS='no'  # do not do all tests because "I have some"

    # Priorities:
    # 1. Passed Files
    # 2. Git diff files - TODO implement file search of classes names like in observe - TODO also expand that to also search filenames like "property_advisor" instead of only class names
    # 3. Search all files

  # } # end _priorities_passed_files_diff_all


  # _counter=0
  # while  [[ "${DOALLTESTS}" == 'no' ]] ; do
  # {
  #   (( _counter++ ))
  # }
  # done # end while

  echo " "
  echo -en "${0}:${LINENO} ..mm checking again arriving files "
  [[ -z "${LINER-}" ]] && LINER="$(repeat_char "80" "-")"
  FILES="$(_filter_files_test_rpec_feaure_only "${FILES}")"
  # echo "FILES:${FILES}:"
  # echo "Backup FILES DIFFFILES:${DIFFFILES}:"
  echo " "
  echo -e "${PURPLE_BLUE}  +${LINER}+ ${GRAY241}"
  echo -e "  +"
  echo -e "${PURPLE_BLUE}+-+ ${GRAY241}"

  if [[ -n "${FILES:-}" ]] ; then  # if not empty, I have file passed Priority 1
  {
    echo '# if not empty, I have file passed Priority 1'
    echo About to test FILES:${FILES}
    echo -e "${YELLOW220} Pretest: ${CYAN} Nothing to test "
    DOALLTESTS='no'
  }
  else # if empty, else check priority 2
  {
    echo '# if empty, else check priority 2'
    if [[ -n "${DIFFFILES:-}" ]] ; then
    {
      echo  '# if empty, else check priority 2 DIFFFILES'
      echo "DIFFFILES:${DIFFFILES}"
      FILES="$(_filter_files_test_rpec_feaure_only "${DIFFFILES}" )"
      echo "_filter_files_test_rpec_feaure_only return:${FILES}:"
      # [[ "${*}" == *"--observe"* ]] && OBSERVE='yes'
      if [[ -n "${FILES:-}" ]] ; then  # if not empty, I have file passed Priority 2
      {
        echo ' # if not empty, I have file passed Priority 2'
        DOALLTESTS='no'
      }
      else # if empty, else check priority 2
      {
        echo ' # if empty, else check priority 2 '
        DOALLTESTS='yes' # trigger Priority 3
        echo ' # trigger Priority 3'
        # exit 0
      }
      fi
    }
    fi
  }
  fi


if [[ "${DOALLTESTS}" == 'yes' ]] ; then   # trigger Priority 3
{
  echo " "
  echo -e "${YELLOW220} STAGE 4-A: ${CYAN} Testing all files hence ... no tests were passed to test  DOALLTESTS=yes"
  echo -e "${PURPLE_BLUE}+-+"
  echo -e "  +"
  # exit 0
  [[ -z "${LINER-}" ]] && LINER="$(repeat_char "80" "-")"
  echo -e "${PURPLE_BLUE}  +${LINER}+ ${GRAY241}"

  integrations_testing() {
    echo " "
    echo -e "${YELLOW220} STAGE 5-A: ${CYAN} Integration testing .. all files hence ... no tests were passed to test "
    echo -e "${PURPLE_BLUE}+-+"
    echo -e "  +"

    [[ -z "${LINER-}" ]] && LINER="$(repeat_char "80" "-")"
    echo -e "${PURPLE_BLUE}  +${LINER}+ ${GRAY241}"

    trap interrupt_integrations INT
    echo -e "${PURPLE_BLUE}  +${LINER}+ ${GRAY241}"
    echo -e "${PURPLE_BLUE}  + ${CYAN}"
    echo -e "${PURPLE_BLUE}  + ${CYAN}"
    echo -e "${PURPLE_BLUE}  + ${YELLOW220} No specific ${CYAN} Integration ${YELLOW220}or ${CYAN} Cucumber${YELLOW220} test was listed "
    echo -e "${PURPLE_BLUE}  + ${CYAN}"
    echo -e "${PURPLE_BLUE}  + ${CYAN}SAMPLE:"
    echo -e "${PURPLE_BLUE}  + ${CYAN}                      ./check.sh test/lib/tasks/cleanup_email_test.rb"
    echo -e "${PURPLE_BLUE}  + ${CYAN}     or   bundle exec ./check.sh test/lib/tasks/cleanup_email_test.rb"
    echo -e "${PURPLE_BLUE}  + ${CYAN}     or            be ./check.sh test/lib/tasks/cleanup_email_test.rb"
    echo -e "${PURPLE_BLUE}  + ${CYAN}     or   bundle exec ./check.sh test/services/boblink_invoice_ledger_details_exporter_spec.rb"
    echo -e "${PURPLE_BLUE}  + ${CYAN}"
    echo -e "${PURPLE_BLUE}  + ${YELLOW220} SO I WILL RUN ALL THE TESTS: All the ${CYAN} Integrations${YELLOW220}, and all the ${CYAN}Cucumbers  "
    echo -e "${PURPLE_BLUE}  + ${CYAN}"

    # PERFORM TESTS
    local ALL_TESTSRB=$(find * -type f -name "*_test.rb" | sort | uniq)
    local ALL_SPECSRB=$(find * -type f -name "*_spec.rb" | sort | uniq)
    ALL_INTEGRATION_TESTS="${ALL_TESTSRB}
${ALL_SPECSRB}"
  #  ALL_INTEGRATION_TESTS="test/models/insurance_test.rb
  #test/workers/twilio_cleaner_worker_test.rb
  #services/place_service/tests/address_serializer_test.rb"


    local _integration_tests_exists=""
    local -i _phatom_is_required=0
    local _phanton_is_required_by=""
    local _integration_test_files_not_found=""
    local _one=""
    while read -r _one; do
    {
      [[ -z "${_one}" ]] && continue
      if [[ ! -f "${_one}" ]] ; then
      {
        _integration_test_files_not_found="${_integration_test_files_not_found}
${PURPLE_BLUE}  + ${YELLOW220}\"${_one}\""
        continue
      }
      fi

      if [[ -z "${_integration_tests_exists}" ]] ; then
      {
        _integration_tests_exists="\"${_one}\""
      }
      else
      {
        _integration_tests_exists="${_integration_tests_exists} \"${_one}\""
      }
      fi

      #phantomjs is required
      if [[ -n $(grep "visit" < "${_one}" ) ]] ; then
      {
        _phatom_is_required=1
        _phanton_is_required_by="${_phanton_is_required_by}
${PURPLE_BLUE}  + ${YELLOW220}\"${_one}\""
      }
      fi
    }
    done <<< "${ALL_INTEGRATION_TESTS}"




    if (( ${_phatom_is_required} == 1 )) && ! command -v phantomjs >/dev/null 2>&1; then
    {
      echo -e "${PURPLE_BLUE}  + "
      echo -e "${PURPLE_BLUE}  + ${RED} phantomjs is required by some tests "
      echo -e "${PURPLE_BLUE}  + "
      echo -e "${PURPLE_BLUE}  + Please install of make available in your path like
            ${BRIGHT_BLUE87} npm -g install phantomjs-prebuilt
            ${PURPLE_BLUE} or
            ${BRIGHT_BLUE87} npm -g install phantomjs2
            ${PURPLE_BLUE} or
            ${BRIGHT_BLUE87} sudo apt-get install phantomjs -y "
      echo -e "${PURPLE_BLUE}  + "
      echo -e "${PURPLE_BLUE}  + These are the tests that require phantomjs:"
      echo -e "${PURPLE_BLUE}  + "
      echo -e "${PURPLE_BLUE}  + ${_phanton_is_required_by}"
      exit 130;
    }
    fi
    if [[ -n "${_integration_test_files_not_found}" ]] ; then
    {
      echo -e "${PURPLE_BLUE}  + "
      echo -e "${PURPLE_BLUE}  + ${YELLOW220} WARNING  ${PURPLE_BLUE}THE FOLLOWING INTEGRATION TEST FILES WHERE NOT FOUND AND were ${YELLOW220}ignored  ${PURPLE_BLUE}from your list"
      echo -e "${PURPLE_BLUE}  + "
      echo -e "${PURPLE_BLUE}  + These are the ignored files:"
      echo -e "${PURPLE_BLUE}  + "
      echo -e "${PURPLE_BLUE}  + ${_integration_test_files_not_found}"
    }
    fi
    echo -e "${PURPLE_BLUE}  + "
    echo -e "${PURPLE_BLUE}  + ${CYAN}TESTING NOW: ${YELLOW220} INTEGRATION"
    echo -e "${PURPLE_BLUE}  + "
    # bundle exec rspec spec/lib/mqtt_subscriber_spec.rb --format progress --format RspecJunitFormatter

    # echo -e "${PURPLE_BLUE}  + ${CYAN}bundle exec ruby -I\"lib:test\" -I${RAKE_EXECUTABLE} ${YELLOW220}${_integration_tests_exists}${RESET}"
    echo -e "${PURPLE_BLUE}  + ${RESET}"
    #ruby -I"lib:test" -I"/home/vagrant/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib" "/home/vagrant/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib/rake/rake_test_loader.rb" "test/models/insurance_test.rb" "test/workers/twilio_cleaner_worker_test.rb"
    # eval " bundle exec rspec --format progress --format RspecJunitFormatter --out rspec.xml " ${_integration_tests_exists}
    # if command -v rspec >/dev/null 2>&1; then
    if ( bundle info rspec   >/dev/null 2>&1  ) ; then
    {
      if [[ "${_integration_tests_exists}" == *"_spec.rb"* ]] ; then
      {
        echo -e "${PURPLE_BLUE}  + ${CYAN}FULL_SPEC_RUN${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}true ${CYAN}RACK_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} RAILS_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} NODE_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} COVERAGE${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}true${CYAN} CI_RSPEC${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}false${CYAN} bundle exec rspec --format progress --format RspecJunitFormatter --out rspec.xml ${YELLOW220}${_integration_tests_exists}${RESET}"
        FULL_SPEC_RUN=true RACK_ENV=test RAILS_ENV=test NODE_ENV=test COVERAGE=true CI_RSPEC=false  bundle exec rspec --format progress --format RspecJunitFormatter --out rspec.xml
      }
      else
      {
      echo -e "${PURPLE_BLUE}  + ${CYAN}FULL_SPEC_RUN${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}true ${CYAN}RACK_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} RAILS_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} NODE_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} COVERAGE${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}true${CYAN} CI_RSPEC${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}false${CYAN} bundle exec ruby -I\"lib:test\" -I${RAKE_EXECUTABLE} ${YELLOW220}${_integration_tests_exists}${RESET}"
      eval "FULL_SPEC_RUN=true RACK_ENV=test RAILS_ENV=test NODE_ENV=test COVERAGE=true CI_RSPEC=false bundle exec ruby -I\"lib:test\" -I${RAKE_EXECUTABLE} " ${_integration_tests_exists}
      echo -e "${PURPLE_BLUE}  + ${RESET}"
      echo -e "${PURPLE_BLUE}  + ${RESET}"
      }
      fi
    }
    fi

  } # end integrations_testing
  integrations_testing "${FILES}"

  cucumbers_testing() {
    echo " "
    echo -e "${YELLOW220} STAGE 6-A: ${CYAN} Cucumber testing  all files hence ... no tests were passed to test"
    echo -e "${PURPLE_BLUE}+-+"
    echo -e "  +"

    [[ -z "${LINER-}" ]] && LINER="$(repeat_char "80" "-")"
    echo -e "${PURPLE_BLUE}  +${LINER}+ ${GRAY241}"

    trap interrupt_cucumbers INT


    # PERFORM TESTS
    ALL_CUCUMBER_TESTS=$(find * -type f -name "*.feature" | sort | uniq)
    #  ALL_CUCUMBER_TESTS="features/sms_resilience.feature
    #features/account/inquiry_management.feature"



      CUCUMBER_TESTS_EXISTS=""
      CUCUMBER_TEST_FILES_NOT_FOUND=""
      while read -r ONE_FILE; do
      {
        [[ -z "${ONE_FILE}" ]] && continue
        if [[ ! -f "${ONE_FILE}" ]] ; then
        {
          CUCUMBER_TEST_FILES_NOT_FOUND="${CUCUMBER_TEST_FILES_NOT_FOUND}
${PURPLE_BLUE}  + ${YELLOW220}'${ONE_FILE}'"
          continue
        }
        fi
        if [[ -z "${CUCUMBER_TESTS_EXISTS}" ]] ; then
        {
          CUCUMBER_TESTS_EXISTS="'${ONE_FILE}'"
          continue
        }
        fi
        CUCUMBER_TESTS_EXISTS="${CUCUMBER_TESTS_EXISTS} '${ONE_FILE}'"

    }
    done <<< "${ALL_CUCUMBER_TESTS}"

    if [[ -n "${CUCUMBER_TEST_FILES_NOT_FOUND}" ]] ; then
    {
      echo -e "${PURPLE_BLUE}  + "
      echo -e "${PURPLE_BLUE}  + ${YELLOW220} WARNING  ${PURPLE_BLUE}THE FOLLOWING CUCUMBER TEST FILES WHERE NOT FOUND AND were ${YELLOW220}ignored  ${PURPLE_BLUE}from your list"
      echo -e "${PURPLE_BLUE}  + "
      echo -e "${PURPLE_BLUE}  + These are the ignored files:"
      echo -e "${PURPLE_BLUE}  + "
      echo -e "${PURPLE_BLUE}  + ${CUCUMBER_TEST_FILES_NOT_FOUND}"
    }
    fi

    if [[ -n "${CUCUMBER_TESTS_EXISTS}" ]] ; then
    {
      echo -e "${PURPLE_BLUE}  + "
      echo -e "${PURPLE_BLUE}  + ${CYAN}TESTING NOW: ${YELLOW220} CUCUMBER"
      echo -e "${PURPLE_BLUE}  + "
      echo -e "${PURPLE_BLUE}  + "
      echo -e "${PURPLE_BLUE}  + ${CYAN}FULL_SPEC_RUN${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}true ${CYAN}RACK_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} RAILS_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} NODE_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} COVERAGE${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}true${CYAN} CI_RSPEC${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}false${CYAN} bundle exec cucumber ${YELLOW220}${CUCUMBER_TESTS_EXISTS}${RED}"
      echo -e "${PURPLE_BLUE}  + ${RESET}"
      eval "FULL_SPEC_RUN=true RACK_ENV=test RAILS_ENV=test NODE_ENV=test COVERAGE=true CI_RSPEC=false bundle exec cucumber ${CUCUMBER_TESTS_EXISTS}"
      echo -e "${PURPLE_BLUE}  + ${RESET}"
      echo -e "${PURPLE_BLUE}  + ${RESET}"
    }
    fi
  } # end cucumbers_testing
  cucumbers_testing


}
else # -z ${1} // if [[ "${DOALLTESTS}" == 'yes' ]] ; then   # trigger Priority 2 or 1
{

  echo " "
  echo -e "${YELLOW220} STAGE 4-B: ${CYAN} Testing only given files or Diff files DOALLTESTS=no" # ${FILES}
  echo -e "${PURPLE_BLUE}+-+"
  echo -e "  +"
  # DEBUG DOALLTESTS exit 0
  [[ -z "${LINER-}" ]] && LINER="$(repeat_char "80" "-")"
  echo -e "${PURPLE_BLUE}  +${LINER}+ ${GRAY241}"

  given_integrations_testing() {
    echo " "
    echo -e "${YELLOW220} STAGE 5-B: ${CYAN} Integration testing  only given files " # ${*}
    echo -e "${PURPLE_BLUE}+-+"
    echo -e "  +"

    [[ -z "${LINER-}" ]] && LINER="$(repeat_char "80" "-")"
    echo -e "${PURPLE_BLUE}  +${LINER}+ ${GRAY241}"
    trap interrupt_integrations INT

    echo -e "${PURPLE_BLUE}  + ${CYAN}:"
    echo -e "${PURPLE_BLUE}  + ${CYAN}:"
    echo -e "${PURPLE_BLUE}  + ${CYAN}:  TESTS were given     ${*}  "
    echo -e "${PURPLE_BLUE}  + ${CYAN}:"
    echo -e "${PURPLE_BLUE}  + ${CYAN}:"
    echo -e "${PURPLE_BLUE}  + ${CYAN}:"
    echo -e "${PURPLE_BLUE}  + ${CYAN}:"
    echo -e "${PURPLE_BLUE}  + ${CYAN}:  Performing Tests      "
    echo -e "${PURPLE_BLUE}  + ${CYAN}:"
    echo -e "${PURPLE_BLUE}  + ${CYAN}:"

    # PERFORM TESTS
    #ruby -I"lib:test" -I"${RAKE_LIB_FOLDER}" "${LOCATION_RAKE_LIB}" "${1}"
    # local
    ALL_TESTSRB=$(echo "${FILES}" | sed 's/ /\n/g' | egrep "^test|_test\.rb"| sort | uniq)
    # local
    ALL_SPECSRB=$(echo "${FILES}" | sed 's/ /\n/g' | egrep "^spec|_spec\.rb"| sort | uniq)
    _integration_tests_exists="${ALL_TESTSRB}
${ALL_SPECSRB}"

    echo "${0}:${LINENO} DEBUG _integration_tests_exists:${_integration_tests_exists}"
    if [[ -n "${_integration_tests_exists}" ]] ; then
    {
      echo "${0}:${LINENO} DEBUG -n "
      if [[ -n "${ALL_TESTSRB}" ]] ; then
      {
          echo "${0}:${LINENO} DEBUG -n "
          trap interrupt_integrations INT
          local -i _specs_count="${#ALL_SPECSRB}"
          if [[ "${OBSERVE}" == 'yes' ]] ; then
          {
            # RACK_ENV=test RAILS_ENV=test NODE_ENV=test COVERAGE=true CI_RSPEC=false bundle exec  spring server&
            wait
            echo "FULL_SPEC_RUN=true RACK_ENV=test RAILS_ENV=test NODE_ENV=test COVERAGE=true CI_RSPEC=false bundle exec  spring status "
            FULL_SPEC_RUN=true RACK_ENV=test RAILS_ENV=test NODE_ENV=test COVERAGE=true CI_RSPEC=false bundle exec  spring status
            ##### REAPEAT START
            echo -e "${PURPLE_BLUE}  + ${0}:${LINENO}"
            echo -e "${PURPLE_BLUE}  + ${CYAN}OBSERVING NOW: ${YELLOW220} INTEGRATION"
            echo -e "${PURPLE_BLUE}  + "

            echo -e "${PURPLE_BLUE}  + ${CYAN}nodemon --watch ${ALL_TESTSRB} --exec ${CYAN}RACK_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} RAILS_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} NODE_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} COVERAGE${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}true${CYAN} CI_RSPEC${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}false${CYAN}  bundle exec ruby -I\"lib:test\" -I${RAKE_EXECUTABLE} ${YELLOW220}${ALL_TESTSRB}${RED}"
            echo -e "${PURPLE_BLUE}  + ${RESET}"
            observe ${ALL_TESTSRB} ${DIFFFILES}
            # eval "nodemon --watch ${ALL_TESTSRB} --exec FULL_SPEC_RUN=true  RACK_ENV=test RAILS_ENV=test NODE_ENV=test COVERAGE=true CI_RSPEC=false bundle exec ruby -I\"lib:test\" -I${RAKE_EXECUTABLE} " ${ALL_TESTSRB}
            #ruby -I"lib:test" -I"/home/vagrant/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib" "/home/vagrant/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib/rake/rake_test_loader.rb" "test/models/insurance_test.rb"  "services/place_service/tests/address_serializer_test.rb"
            echo -e "${PURPLE_BLUE}  + ${RESET}"
            echo -e "${PURPLE_BLUE}  + ${RESET}"
          }
          else # not Observe only rspec
          {
            ##### REAPEAT START
            echo -e "${PURPLE_BLUE}  + ${0}:${LINENO}"
            echo -e "${PURPLE_BLUE}  + ${CYAN}TESTING NOW: ${YELLOW220} INTEGRATION"
            echo -e "${PURPLE_BLUE}  + "

            echo -e "${PURPLE_BLUE}  + ${CYAN}RACK_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} RAILS_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} NODE_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} COVERAGE${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}true${CYAN} CI_RSPEC${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}false${CYAN} bundle exec ruby -I\"lib:test\" -I${RAKE_EXECUTABLE} ${YELLOW220}${ALL_TESTSRB}${RED}"
            echo -e "${PURPLE_BLUE}  + ${RESET}"
            eval "FULL_SPEC_RUN=true RACK_ENV=test RAILS_ENV=test NODE_ENV=test COVERAGE=true CI_RSPEC=false bundle exec ruby -I\"lib:test\" -I${RAKE_EXECUTABLE} " ${ALL_TESTSRB}
            #ruby -I"lib:test" -I"/home/vagrant/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib" "/home/vagrant/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib/rake/rake_test_loader.rb" "test/models/insurance_test.rb"  "services/place_service/tests/address_serializer_test.rb"
            echo -e "${PURPLE_BLUE}  + ${RESET}"
            echo -e "${PURPLE_BLUE}  + ${RESET}"
          }
          fi
      }
      fi

      if [[ -n "${ALL_SPECSRB}" ]] ; then
      {
        # if command -v rspec >/dev/null 2>&1; then
        if ( bundle info rspec   >/dev/null 2>&1  ) ; then
        {
          trap interrupt_rspec INT
          local -i _specs_count="${#ALL_SPECSRB}"
          # typeset -i _specs_count="${#ALL_SPECSRB}"
          # echo "OBSERVE?::${OBSERVE}::"
          if [[ "${OBSERVE}" == 'yes' ]] ; then
          {
            # RACK_ENV=test RAILS_ENV=test NODE_ENV=test COVERAGE=true CI_RSPEC=false bundle exec  spring server&
            wait
            RACK_ENV=test RAILS_ENV=test NODE_ENV=test COVERAGE=true CI_RSPEC=false bundle exec  spring status
            if [ ${_specs_count} -eq 1 ] ; then
            {
              local _related_filename="$(cut -d: -f1<<<"$(basename "${ALL_SPECSRB}" | sed 's/_spec.rb/.rb/g')")"
              echo -e "${PURPLE_BLUE}  + "
              echo -e "${PURPLE_BLUE}  + ${CYAN}OBSERVING ${_specs_count} Rspec now: ${YELLOW220} Rspec"
              echo -e "${PURPLE_BLUE}  + "
              echo -e "${PURPLE_BLUE}  + ${CYAN}RACK_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} RAILS_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} NODE_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} COVERAGE${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}true${CYAN} CI_RSPEC$${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}false${CYAN}OW220}=${FROM_MAGENTA_NOT_VISIBLE}false${CYAN} ${CYAN}nodemon --watch ${ALL_SPECSRB} --exec bundle exec rspec ${ALL_SPECSRB} ${RED}--format ${YELLOW220}progress ${RED}--format  ${YELLOW220}RspecJunitFormatter ${RED}--out ${YELLOW220}rspec.xml${RESET}"
              echo -e "${PURPLE_BLUE}  + ${RESET}"
              FULL_SPEC_RUN=true RACK_ENV=test RAILS_ENV=test NODE_ENV=test COVERAGE=true CI_RSPEC=false  nodemon --watch ${ALL_SPECSRB} --exec bundle exec rspec ${ALL_SPECSRB} --format progress --format RspecJunitFormatter --out rspec.xml
              echo -e "${PURPLE_BLUE}  + ${RESET}"
              echo -e "${PURPLE_BLUE}  + ${RESET}"
            }
            else
            {
              local _one_related=''
              local _one_file=''
              local _file_findings=''
              local _related_filename=''
              local -i _count=0
              local _observing_files_with_watch=''
              local _observing_files=''
              while read -r _one_related; do
              {
                [[ -z "${_one_related}" ]] && continue
                [[ ! -f "${_one_related}" ]] && continue
                (( _count ++ ))
                _related_filename="$(cut -d: -f1<<<"$(basename "${_one_related}" | sed 's/_spec.rb/.rb/g')")"
                echo -e "${PURPLE_BLUE}  + ${CYAN}_related_filename${RED}:${YELLOW220}${_related_filename}"
                echo -e "${PURPLE_BLUE}  + ${CYAN}          running${RED}:${YELLOW220}find . | ag --nocolor "/.*${_related_filename}[^/]*$" | trim_start_space | sed 's/../  /'"
                _file_findings=$(find . | ag --nocolor "/.*${_related_filename}[^/]*$" | trim_start_space | sed 's/^\../  /g')
                [[ -z "${_file_findings}" ]] && continue
                for _one_file in ${_file_findings}; do
                {
                  [[ -z "${_one_file}" ]] && continue
                  [[ ! -f "${_one_file}" ]] && continue
                  echo -e "${GREEN}  + ${YELLOW220}:  ${CYAN}         found${RED}:${YELLOW220}${_one_file}"
                  _observing_files="${_observing_files}  --watch ${_one_file} "
                }
                done
              }
              done <<< "${ALL_SPECSRB}"

              echo -e "${PURPLE_BLUE}  + ${0}:${LINENO}"
              echo -e "${PURPLE_BLUE}  + ${CYAN}OBSERVING ${_specs_count} Test now: ${YELLOW220} Rspec"
              echo -e "${PURPLE_BLUE}  + "
              echo -e "${PURPLE_BLUE}  + ${CYAN}RACK_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} RAILS_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} NODE_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} COVERAGE${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}true${CYAN} CI_RSPEC${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}false${CYAN} ${CYAN}nodemon ${_observing_files} --watch ${ALL_SPECSRB} --exec bundle exec rspec ${ALL_SPECSRB} ${RED}--format ${YELLOW220}progress ${RED}--format  ${YELLOW220}RspecJunitFormatter ${RED}--out ${YELLOW220}rspec.xml${RESET}"
              echo -e "${PURPLE_BLUE}  + ${RESET}"
              observe  ${ALL_SPECSRB} ${DIFFFILES}
              # FULL_SPEC_RUN=true RACK_ENV=test RAILS_ENV=test NODE_ENV=test COVERAGE=true CI_RSPEC=false  nodemon --watch ${ALL_SPECSRB} ${_observing_files}  --exec bundle exec rspec ${ALL_SPECSRB} --format progress --format RspecJunitFormatter --out rspec.xml
              echo -e "${PURPLE_BLUE}  + ${RESET}"
              echo -e "${PURPLE_BLUE}  + ${RESET}"

            }
            fi
          }
          else # else OBSERVE not observe only rspec
          {
            echo -e "${PURPLE_BLUE}  + ${0}:${LINENO}"
            echo -e "${PURPLE_BLUE}  + ${CYAN}TESTING NOW: ${YELLOW220} Rspec"
            echo -e "${PURPLE_BLUE}  + "
            # echo -e "${PURPLE_BLUE}  + ${CYAN} bundle exec rspec --format progress --format RspecJunitFormatter --out rspec.xml ${YELLOW220}${_integration_tests_exists}${RESET}"
            echo -e "${PURPLE_BLUE}  + ${CYAN}RACK_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} RAILS_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} NODE_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} COVERAGE${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}true${CYAN} CI_RSPEC${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}false${CYAN} ${CYAN}bundle exec rspec ${ALL_SPECSRB} ${RED}--format ${YELLOW220}progress ${RED}--format  ${YELLOW220}RspecJunitFormatter ${RED}--out ${YELLOW220}rspec.xml${RESET}"
            # echo -e "${PURPLE_BLUE}  + ${CYAN}bundle exec rspec ${YELLOW220}${ALL_SPECSRB}${RED}"
            echo -e "${PURPLE_BLUE}  + ${RESET}"
            FULL_SPEC_RUN=true RACK_ENV=test RAILS_ENV=test NODE_ENV=test COVERAGE=true CI_RSPEC=false  bundle exec rspec ${ALL_SPECSRB} --format progress --format RspecJunitFormatter --out rspec.xml
            # eval "bundle exec rspec" ${ALL_SPECSRB}
            #ruby -I"lib:test" -I"/home/vagrant/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib" "/home/vagrant/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib/rake/rake_test_loader.rb" "test/models/insurance_test.rb" "services/place_service/tests/address_serializer_test.rb"
            echo -e "${PURPLE_BLUE}  + ${RESET}"
            echo -e "${PURPLE_BLUE}  + ${RESET}"
          }
          fi  # end OBSERVE
        }
        fi # end bundle info rspec
      }
      fi # end ALL_SPECSRB
    }
    else
    {
      echo -e "${RED}  + ${YELLOW220}:  ${CYAN} No integration tests found !     "
      echo -e "${RED}  + ${YELLOW220}:  ${CYAN} I got this but I am looking for *_test.rb files      "
      for ONETEST in ${@}; do
      {
        echo -e "${RED}  + ${YELLOW220}:  ${CYAN} ${ONETEST}"
      }
      done
      echo -e "${RED}  + ${YELLOW220}: ..."
    }
    fi

  } # end given_integrations_testing
  given_integrations_testing "${FILES}"

  given_cucumbers_testing() {
    echo " "
    CUCUMBER_TESTS_EXISTS=$(echo "${@}" | sed 's/ /\n/g' | egrep "^feature|\.feature" | sort | uniq)
     [[ -z "${CUCUMBER_TESTS_EXISTS}" ]] && return 0
    echo -e "${YELLOW220} STAGE 6-B: ${CYAN} Cucumber testing  only given files " # ${CUCUMBER_TESTS_EXISTS}
    echo -e "${PURPLE_BLUE}+-+"
    echo -e "  +"

    [[ -z "${LINER-}" ]] && LINER="$(repeat_char "80" "-")"
    echo -e "${PURPLE_BLUE}  +${LINER}+ ${GRAY241}"
    trap interrupt_cucumbers INT

    if [[ -n "${CUCUMBER_TESTS_EXISTS}" ]] ; then
    {
        echo -e "${PURPLE_BLUE}  + "
        echo -e "${PURPLE_BLUE}  + ${CYAN}TESTING NOW: ${YELLOW220} CUCUMBER"
        echo -e "${PURPLE_BLUE}  + "
        echo -e "${PURPLE_BLUE}  + " #sed 's/ /\n/g' | grep -e "\.feature"
        echo -e "${PURPLE_BLUE}  + ${CYAN}RACK_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} RAILS_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} NODE_ENV${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}test${CYAN} COVERAGE${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}true${CYAN} CI_RSPEC${YELLOW220}=${FROM_MAGENTA_NOT_VISIBLE}false${CYAN} bundle exec cucumber ${YELLOW220}"${CUCUMBER_TESTS_EXISTS}"${RED}"
        echo -e "${PURPLE_BLUE}  + ${RED}"
        eval "FULL_SPEC_RUN=true RACK_ENV=test RAILS_ENV=test NODE_ENV=test COVERAGE=true CI_RSPEC=false bundle exec cucumber ${CUCUMBER_TESTS_EXISTS}"
        echo -e "${PURPLE_BLUE}  + ${RESET}"
        echo -e "${PURPLE_BLUE}  + ${RESET}"
    }
    else
    {
      echo -e "${RED}  + ${YELLOW220}:  ${CYAN} No cucumber tests found !     "
      # echo -e "${RED}  + ${YELLOW220}:  ${CYAN} I got this but I am looking for *.feature files      "
      # for ONETEST in ${@}; do
      # {
      #   echo -e "${RED}  + ${YELLOW220}:  ${CYAN} ${ONETEST}"
      # }
      # done
      # echo -e "${RED}  + ${YELLOW220}: ..."
    }
    fi
  } # end cucumbers_testing
  given_cucumbers_testing "${FILES}"

} # end if not -z 1  // if [[ "${DOALLTESTS}" == 'yes' ]] ; then
fi

