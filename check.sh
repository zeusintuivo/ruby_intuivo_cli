#!/bin/bash
#
# @author Zeus Intuivo <zeus@intuivo.com>
#
#
#colors
[[ -z "${CYAN}" ]] && CYAN="\\033[38;5;123m"
[[ -z "${PURPLE_BLUE}" ]] && PURPLE_BLUE="\\033[38;5;93m"
[[ -z "${GRAY241}" ]] && GRAY241="\\033[38;5;241m"
[[ -z "${RED}" ]] && RED="\\033[38;5;1m"
[[ -z "${BRIGHT_BLUE87}" ]] && BRIGHT_BLUE87="\\033[38;5;87m"
[[ -z "${RESET}" ]] && RESET="\\033[0m"
[[ -z "${YELLOW220}" ]] && YELLOW220="\\033[38;5;220m"

THISSCRIPTNAME=`basename "$0"`

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

 
if command -v git_current_branch >/dev/null 2>&1; then
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
interrupt_integrations() {
    echo "${THISSCRIPTNAME} INTEGRATIONS INTERRUPT"
}
interrupt_cucumbers() {
    echo "${THISSCRIPTNAME} CUCUMBERS INTERRUPT"
}
rubocop_testing() {
trap interrupt_rubocop INT
BRANCH=$(git_current_branch)
echo " "
echo
echo -e "${PURPLE_BLUE} === Branch ${CYAN} ${BRANCH} ${PURPLE_BLUE} === ${GRAY241} ";
echo
echo " "
echo -e "${CYAN} Rubocop only files from this branch"
echo -e "${PURPLE_BLUE}+-+"
echo -e "  +"
echo -e "  +-- ${CYAN} Locating files that changes in this branch "
echo -e "${PURPLE_BLUE}  +${GRAY241}"

FILES1=$(git diff --name-only "${BRANCH}" $(git merge-base "${BRANCH}" master) | egrep "\.rb|\.rake")
FILES2=$(git status -sb | egrep -v "##" | cut -c4- | egrep -v "\.tutorial|\.dir_bash_history|\.vscode|\.idea|\.git|\.description|\.editorconfig|\.env.development|\.env-sample|\.gitignore|\.pryrc|\.rspec|\.rubocop_todo.yml|\.rubocop.yml|\.simplecov|\.temp_keys|\.csv|\.sh|\.yml|\.gitignore|\.log|\.txt|\.key|\.crt|\.csr|\.idl|\.json|\.js|\.jpg|\.png|\.html|\.gif|\.feature|\.scss|\.css|\.haml|\.erb|\.otf|\.svg|\.ttf|\.tiff|\.woff|\.eot|\.editorconfig|\.markdown|\.headings")
FILES="${FILES1}
${FILES2}"

FILES=$(echo "${FILES}" | sort | uniq)

NUMBER_LEN="${#FILES}"

if (( ${NUMBER_LEN} == 0  )) ; then
{
  echo -e "${PURPLE_BLUE}  + ${RED}No files found for rubocop"
}
else
{

  echo -e "${PURPLE_BLUE}  +"

  FILE_LONGEST=0
  FILE_LEN=0
  while read -r ONE_FILE; do
  {
    if [ ! -z "${ONE_FILE}" ] ; then
    {
      FILE_LEN="${#ONE_FILE}"
      if (( $FILE_LEN > $FILE_LONGEST )) ; then
      {
        FILE_LONGEST=$FILE_LEN
      }
      fi
    }
    fi
  }
  done <<< "${FILES}"

  (( FILE_LONGEST++ ))
  (( FILE_LONGEST++ ))
  SPACER=""
  LINER=""
  TITLER="  +----------${CYAN}Rubocop${PURPLE_BLUE}---${CYAN}checking${PURPLE_BLUE}---${CYAN}files${PURPLE_BLUE}-"
  COUNTER=0
  until [ $COUNTER -ge $FILE_LONGEST ]; do
  {
    (( COUNTER++ ))
    SPACER="${SPACER} "
    LINER="${LINER}-"
    if (( $COUNTER > 37 )) ; then
    {
      TITLER="${TITLER}-"
    }
    fi
  }
  done
  TITLER="${TITLER}+"
  echo -e "${TITLER}"
  echo -e "${PURPLE_BLUE}  +${SPACER}+ "
  echo -e "~~+${SPACER}+~~${GRAY241}"
  FILERS=""
  ALL_FILERS=""



  while read -r ONE_FILE; do
  {
    if [ ! -z "${ONE_FILE}" ] ; then
    {
      FILERS=$(add_ssspaceSSS_to_name "${ONE_FILE}" $FILE_LONGEST)
      ALL_FILERS="${ALL_FILERS}
${FILERS}"
      #echo -e "${PURPLE_BLUE}  + ${BRIGHT_BLUE87}${ONE_FILE} ${PURPLE_BLUE}  + "
    }
    fi
  }
  done <<< "${FILES}"
  while read -r ONE_FILE; do
  {
    if [ ! -z "${ONE_FILE}" ] ; then
    {
      echo -e "  ${PURPLE_BLUE}+${CYAN} ${ONE_FILE} ${PURPLE_BLUE}+" | sed 's@§@ @g'
    }
    fi
  }
  done <<< "${ALL_FILERS}"
  echo -e "${PURPLE_BLUE}  +${SPACER}+ "
  echo -e "~~+${SPACER}+~~${GRAY241}"
  for ONE_FILE in ${FILES}; do
  {
    if [ ! -z "${ONE_FILE}" ] ; then
    {
      RUBORESULT=$(bundle exec rubocop -a "${ONE_FILE}")
      if [ ! -z "${RUBORESULT}" ] && [[ "${RUBORESULT}" != *"no offenses detected"* ]]; then
      {
        FILERS=$(add_ssspaceSSS_to_name "${ONE_FILE}" $FILE_LONGEST)
        echo -e "  ${RED}+${YELLOW220} ${FILERS} ${RED}+ FAILED" | sed 's@§@ @g'
        while read -r  RUBORESULT_LINE; do
        {
          echo -e "  ${RED}+${YELLOW220}---${RESET} ${RUBORESULT_LINE}  "
        }
        done <<< "${RUBORESULT}"
      }
      fi
    }
    fi
  }
  done
  #echo "${FILES}" | sort -n | uniq | xargs bundle exec rubocop -a
  if (( $? != 0 )) ;  then
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
  echo -e "${PURPLE_BLUE}  +${LINER}+ ${GRAY241}"



} # end rubocop_testing
rubocop_testing





find_location_rake_lib() {
  THIS_RUBY_VERSION=$(ruby --version  | cut -d' ' -f2 | cut -d'p' -f1)

  # Then get folder based on ruby version 2.2.5 and rake version 10.5.0 used for development
  LOCATION_RAKE_LIB=$(locate test_loader.rb | grep "rake-*.*.*/lib" | grep "ruby-${THIS_RUBY_VERSION}")  # RVM Type environment
  [ -z "${LOCATION_RAKE_LIB}" ] && LOCATION_RAKE_LIB=$(locate test_loader.rb | grep "rake-*.*.*/lib" | grep "${THIS_RUBY_VERSION}")         # Other  Install Type environment macthing ruby and gem version
  [ -z "${LOCATION_RAKE_LIB}" ] && LOCATION_RAKE_LIB=$(locate test_loader.rb | grep "rake-*.*.*/lib" | head -1 )  # Ruby compiled installed with WGET, or GEM install folder is not matching to rake install, just get the first one
}



find_location_rake_lib
if [ -z "${LOCATION_RAKE_LIB}" ] ; then
{
  echo -e "${PURPLE_BLUE}  + ${YELLOW220}WARNING COULD NOT FIND  test_loader.rb "
  echo -e "${PURPLE_BLUE}  + ${CYAN}"
  echo -e "${PURPLE_BLUE}  + ${CYAN}Attempting to run ${YELLOW220} sudo updatedb "
  sudo updatedb
  wait
  echo -e "${PURPLE_BLUE}  + ${CYAN}"
  echo -e "${PURPLE_BLUE}  + ${YELLOW220} Attempting to find test_loader.rb  again"
  find_location_rake_lib
  wait
  if [ -z "${LOCATION_RAKE_LIB}" ] ; then
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

  echo -e "${PURPLE_BLUE}  +${LINER}+ ${GRAY241}"
  echo "    LOCATION_RAKE_LIB : $LOCATION_RAKE_LIB"
  echo "RAKELOADER_LIB_FOLDER : $RAKELOADER_LIB_FOLDER"
  echo "      RAKE_LIB_FOLDER : $RAKE_LIB_FOLDER"

# ALL THE TESTS
#ruby -I"lib:test" -I"$HOME/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib" "$HOME/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib/rake/rake_test_loader.rb" "test/models/insurance_test.rb" "test/workers/twilio_cleaner_worker_test.rb" "test/controllers/account/doctors_controller_test.rb" "test/controllers/doctors/specialties_controller_test.rb" "test/workers/dtms_cleaner_worker_test.rb" "test/controllers/accounts_controller_test.rb" "test/integration/inquiry_plugin_integration_test.rb" "test/controllers/inquiries/confirmations_controller_test.rb" "test/integration/practice_integration_test.rb" "test/services/unprocessed_bookings_test.rb" "test/mailers/user_mailer_test.rb" "test/validators/partner_token_validator_test.rb" "test/models/timeslot_test.rb" "test/lib/tasks/cleanup_email_test.rb" "test/lib/tasks/cleanup_sms_test.rb" "test/models/account_test.rb" "test/models/booking_test.rb" "test/integration/patient_flows_test.rb" "test/controllers/account_backend_controller_test.rb" "test/lib/tasks/unprocessed_bookings_reminders_test.rb" "test/models/inquiry_test.rb" "test/models/partner_test.rb" "test/mailers/smser_test.rb" "test/controllers/directory_controller_test.rb" "test/controllers/account/calendars_controller_test.rb" "test/models/patient_test.rb" "test/integration/review_integration_test.rb" "services/place_service/tests/address_serializer_test.rb"

# Email
# ruby -I"lib:test" -I"$HOME/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib" "$HOME/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib/rake/rake_test_loader.rb"  "test/lib/tasks/cleanup_email_test.rb"

# ruby -I"lib:test" -I"$HOME/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib" "$HOME/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib/rake/rake_test_loader.rb"  "test/lib/tasks/cleanup_sms_test.rb"



if [ -z "${1}" ] ; then
{

integrations_testing() {
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
  echo -e "${PURPLE_BLUE}  + ${CYAN}"
  echo -e "${PURPLE_BLUE}  + ${YELLOW220} SO I WILL RUN ALL THE TESTS: All the ${CYAN} Integrations${YELLOW220}, and all the ${CYAN}Cucumbers  "
  echo -e "${PURPLE_BLUE}  + ${CYAN}"

  # PERFORM TESTS
  ALL_INTEGRATION_TESTS=$(find * -type f -name "*_test.rb")
#  ALL_INTEGRATION_TESTS="test/models/insurance_test.rb
#test/workers/twilio_cleaner_worker_test.rb
#test/controllers/account/doctors_controller_test.rb
#test/controllers/doctors/specialties_controller_test.rb
#test/workers/dtms_cleaner_worker_test.rb
#test/controllers/accounts_controller_test.rb
#test/integration/inquiry_plugin_integration_test.rb
#test/controllers/inquiries/confirmations_controller_test.rb
#test/integration/practice_integration_test.rb
#test/services/unprocessed_bookings_test.rb
#test/mailers/user_mailer_test.rb
#test/validators/partner_token_validator_test.rb
#test/models/timeslot_test.rb
#test/lib/tasks/cleanup_email_test.rb
#test/lib/tasks/cleanup_sms_test.rb
#test/models/account_test.rb
#test/models/booking_test.rb
#test/integration/patient_flows_test.rb
#test/controllers/account_backend_controller_test.rb
#test/lib/tasks/unprocessed_bookings_reminders_test.rb
#test/models/inquiry_test.rb
#test/models/partner_test.rb
#test/mailers/smser_test.rb
#test/controllers/directory_controller_test.rb
#test/controllers/account/calendars_controller_test.rb
#test/models/patient_test.rb
#test/integration/review_integration_test.rb
#services/place_service/tests/address_serializer_test.rb"


  INTEGRATION_TESTS_EXISTS=""
  PHANTOM_IS_REQUIRED=0
  PHANTOM_IS_REQUIRED_BY=""
  INTEGRATION_TEST_FILES_NOT_FOUND=""
  while read -r ONE_FILE; do
  {
    if [ ! -z "${ONE_FILE}" ] ; then
    {
      if [ -f "${ONE_FILE}" ] ; then
      {

        if [ -z "${INTEGRATION_TESTS_EXISTS}" ] ; then
        {
          INTEGRATION_TESTS_EXISTS="\"${ONE_FILE}\""
        }
        else
        {
          INTEGRATION_TESTS_EXISTS="${INTEGRATION_TESTS_EXISTS} \"${ONE_FILE}\""
        }
        fi

        #phantomjs is required
        if [[ ! -z $(cat "${ONE_FILE}" | grep "visit") ]] ; then
        {
          PHANTOM_IS_REQUIRED=1
          PHANTOM_IS_REQUIRED_BY="${PHANTOM_IS_REQUIRED_BY}
${PURPLE_BLUE}  + ${YELLOW220}\"${ONE_FILE}\""
        }
        fi
      }
      else
      {
        INTEGRATION_TEST_FILES_NOT_FOUND="${INTEGRATION_TEST_FILES_NOT_FOUND}
${PURPLE_BLUE}  + ${YELLOW220}\"${ONE_FILE}\""
      }
      fi

    }
    fi
  }
  done <<< "${ALL_INTEGRATION_TESTS}"




  if (( ${PHANTOM_IS_REQUIRED} == 1 )) && ! command -v phantomjs >/dev/null 2>&1; then
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
    echo -e "${PURPLE_BLUE}  + ${PHANTOM_IS_REQUIRED_BY}"
    exit 130;
  }
  fi
  if [[ ! -z "${INTEGRATION_TEST_FILES_NOT_FOUND}" ]] ; then
  {
    echo -e "${PURPLE_BLUE}  + "
    echo -e "${PURPLE_BLUE}  + ${YELLOW220} WARNING  ${PURPLE_BLUE}THE FOLLOWING INTEGRATION TEST FILES WHERE NOT FOUND AND were ${YELLOW220}ignored  ${PURPLE_BLUE}from your list"
    echo -e "${PURPLE_BLUE}  + "
    echo -e "${PURPLE_BLUE}  + These are the ignored files:"
    echo -e "${PURPLE_BLUE}  + "
    echo -e "${PURPLE_BLUE}  + ${INTEGRATION_TEST_FILES_NOT_FOUND}"
  }
  fi
  echo -e "${PURPLE_BLUE}  + "
  echo -e "${PURPLE_BLUE}  + ${CYAN}TESTING NOW: ${YELLOW220} INTEGRATION"
  echo -e "${PURPLE_BLUE}  + "

  export GOOGLE_API_KEY="x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1xx1x1"
  export GOOGLE_CLIENT_ID="012345678900-gmk2gmk2gmk2gmk2gmk2gmk2gmk2gmk2.apps.googleusercontent.com"
  export GOOGLE_CLIENT_SECRET="QuerbyQuerbyErgoIpsonHop"
  export GOOGLE_EMAIL_DOMAIN="weise.box"

  LOAD_TEMP_KEYS="# Empty script"
  [ -f .temp_keys ] && LOAD_TEMP_KEYS=$(<.temp_keys)
  eval "${LOAD_TEMP_KEYS}"

  echo -e "${PURPLE_BLUE}  + TEMP KEYS NEED IT FOR: test/integration/inquiry_plugin_integration_test.rb"
  echo -e "${PURPLE_BLUE}  + "
  echo -e "${PURPLE_BLUE}  + GOOGLE_API_KEY      :${GRAY241}${GOOGLE_API_KEY}"
  echo -e "${PURPLE_BLUE}  + GOOGLE_CLIENT_ID    :${GRAY241}${GOOGLE_CLIENT_ID}"
  echo -e "${PURPLE_BLUE}  + GOOGLE_CLIENT_SECRET:${GRAY241}${GOOGLE_CLIENT_SECRET}"
  echo -e "${PURPLE_BLUE}  + GOOGLE_EMAIL_DOMAIN :${GRAY241}${GOOGLE_EMAIL_DOMAIN}"
  echo -e "${PURPLE_BLUE}  + "
  echo -e "${PURPLE_BLUE}  + ${CYAN}ruby -I\"lib:test\" -I\"${RAKE_LIB_FOLDER}\" \"${LOCATION_RAKE_LIB}\" ${YELLOW220}${INTEGRATION_TESTS_EXISTS}${RESET}"
  echo -e "${PURPLE_BLUE}  + ${RESET}"
  eval "ruby -I\"lib:test\" -I\"${RAKE_LIB_FOLDER}\" \"${LOCATION_RAKE_LIB}\" " ${INTEGRATION_TESTS_EXISTS}
  #ruby -I"lib:test" -I"/home/vagrant/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib" "/home/vagrant/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib/rake/rake_test_loader.rb" "test/models/insurance_test.rb" "test/workers/twilio_cleaner_worker_test.rb" "test/controllers/account/doctors_controller_test.rb" "test/controllers/doctors/specialties_controller_test.rb" "test/workers/dtms_cleaner_worker_test.rb" "test/controllers/accounts_controller_test.rb" "test/integration/inquiry_plugin_integration_test.rb" "test/controllers/inquiries/confirmations_controller_test.rb" "test/integration/practice_integration_test.rb" "test/services/unprocessed_bookings_test.rb" "test/mailers/user_mailer_test.rb" "test/validators/partner_token_validator_test.rb" "test/models/timeslot_test.rb" "test/models/account_test.rb" "test/models/booking_test.rb" "test/integration/patient_flows_test.rb" "test/controllers/account_backend_controller_test.rb" "test/lib/tasks/unprocessed_bookings_reminders_test.rb" "test/models/inquiry_test.rb" "test/models/partner_test.rb" "test/mailers/smser_test.rb" "test/controllers/directory_controller_test.rb" "test/controllers/account/calendars_controller_test.rb" "test/models/patient_test.rb" "test/integration/review_integration_test.rb" "services/place_service/tests/address_serializer_test.rb"
  echo -e "${PURPLE_BLUE}  + ${RESET}"
  echo -e "${PURPLE_BLUE}  + ${RESET}"

} # end integrations_testing
integrations_testing "${@}"

cucumbers_testing() {
trap interrupt_cucumbers INT


  # PERFORM TESTS
  ALL_CUCUMBER_TESTS=$(find * -type f -name "*.feature")
#  ALL_CUCUMBER_TESTS="features/sms_resilience.feature
#features/admin/support_inquiry_interface.feature
#features/inquiry_dispatch.feature
#features/publishers/custom_checkout_template.feature
#features/admin/admin_booking_interface.feature
#features/admin/practice_management.feature
#features/review.feature
#features/times.feature
#features/account/inquiry_management.feature"



  CUCUMBER_TESTS_EXISTS=""
  CUCUMBER_TEST_FILES_NOT_FOUND=""
  while read -r ONE_FILE; do
  {
    if [ ! -z "${ONE_FILE}" ] ; then
    {
      if [ -f "${ONE_FILE}" ] ; then
      {

        if [ -z "${CUCUMBER_TESTS_EXISTS}" ] ; then
        {
          CUCUMBER_TESTS_EXISTS="'${ONE_FILE}'"
        }
        else
        {
          CUCUMBER_TESTS_EXISTS="${CUCUMBER_TESTS_EXISTS} '${ONE_FILE}'"
        }
        fi
      }
      else
      {
        CUCUMBER_TEST_FILES_NOT_FOUND="${CUCUMBER_TEST_FILES_NOT_FOUND}
${PURPLE_BLUE}  + ${YELLOW220}'${ONE_FILE}'"
      }
      fi

    }
    fi
  }
  done <<< "${ALL_CUCUMBER_TESTS}"

 if [[ ! -z "${CUCUMBER_TEST_FILES_NOT_FOUND}" ]] ; then
  {
    echo -e "${PURPLE_BLUE}  + "
    echo -e "${PURPLE_BLUE}  + ${YELLOW220} WARNING  ${PURPLE_BLUE}THE FOLLOWING CUCUMBER TEST FILES WHERE NOT FOUND AND were ${YELLOW220}ignored  ${PURPLE_BLUE}from your list"
    echo -e "${PURPLE_BLUE}  + "
    echo -e "${PURPLE_BLUE}  + These are the ignored files:"
    echo -e "${PURPLE_BLUE}  + "
    echo -e "${PURPLE_BLUE}  + ${CUCUMBER_TEST_FILES_NOT_FOUND}"
  }
  fi

  echo -e "${PURPLE_BLUE}  + "
  echo -e "${PURPLE_BLUE}  + ${CYAN}TESTING NOW: ${YELLOW220} CUCUMBER"
  echo -e "${PURPLE_BLUE}  + "
  echo -e "${PURPLE_BLUE}  + "
  echo -e "${PURPLE_BLUE}  + ${CYAN}bundle exec cucumber ${YELLOW220}${CUCUMBER_TESTS_EXISTS}${RED}"
  echo -e "${PURPLE_BLUE}  + ${RED}"
  eval "bundle exec cucumber ${CUCUMBER_TESTS_EXISTS}"
  echo -e "${PURPLE_BLUE}  + ${RESET}"
  echo -e "${PURPLE_BLUE}  + ${RESET}"

} # end cucumbers_testing
cucumbers_testing "${@}"


}
else # -z ${1}
{
  
given_integrations_testing() {
trap interrupt_integrations INT

  echo -e "${PURPLE_BLUE}  + ${CYAN}:"
  echo -e "${PURPLE_BLUE}  + ${CYAN}:"
  echo -e "${PURPLE_BLUE}  + ${CYAN}:  TESTS were given       "
  echo -e "${PURPLE_BLUE}  + ${CYAN}:"
  echo -e "${PURPLE_BLUE}  + ${CYAN}:"
  echo -e "${PURPLE_BLUE}  + ${CYAN}:"
  echo -e "${PURPLE_BLUE}  + ${CYAN}:"
  echo -e "${PURPLE_BLUE}  + ${CYAN}:  Performing Tests      "
  echo -e "${PURPLE_BLUE}  + ${CYAN}:"
  echo -e "${PURPLE_BLUE}  + ${CYAN}:"

  # PERFORM TESTS
  #ruby -I"lib:test" -I"${RAKE_LIB_FOLDER}" "${LOCATION_RAKE_LIB}" "${1}"
  INTEGRATION_TESTS_EXISTS=$(echo "${@}" | sed 's/ /\n/g' | grep -e "_test\.rb")
  if [[ ! -z "${INTEGRATION_TESTS_EXISTS}" ]] ; then
  {
      ##### REAPEAT START
      echo -e "${PURPLE_BLUE}  + "
      echo -e "${PURPLE_BLUE}  + ${CYAN}TESTING NOW: ${YELLOW220} INTEGRATION"
      echo -e "${PURPLE_BLUE}  + "

      export GOOGLE_API_KEY="x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1x1xx1x1"
      export GOOGLE_CLIENT_ID="012345678900-gmk2gmk2gmk2gmk2gmk2gmk2gmk2gmk2.apps.googleusercontent.com"
      export GOOGLE_CLIENT_SECRET="QuerbyQuerbyErgoIpsonHop"
      export GOOGLE_EMAIL_DOMAIN="weise.box"

      LOAD_TEMP_KEYS="# Empty script"
      [ -f .temp_keys ] && LOAD_TEMP_KEYS=$(<.temp_keys)
      eval "${LOAD_TEMP_KEYS}"

      echo -e "${PURPLE_BLUE}  + TEMP KEYS NEED IT FOR: test/integration/inquiry_plugin_integration_test.rb"
      echo -e "${PURPLE_BLUE}  + "
      echo -e "${PURPLE_BLUE}  + GOOGLE_API_KEY      :${GRAY241}${GOOGLE_API_KEY}"
      echo -e "${PURPLE_BLUE}  + GOOGLE_CLIENT_ID    :${GRAY241}${GOOGLE_CLIENT_ID}"
      echo -e "${PURPLE_BLUE}  + GOOGLE_CLIENT_SECRET:${GRAY241}${GOOGLE_CLIENT_SECRET}"
      echo -e "${PURPLE_BLUE}  + GOOGLE_EMAIL_DOMAIN :${GRAY241}${GOOGLE_EMAIL_DOMAIN}"
      echo -e "${PURPLE_BLUE}  + "
      echo -e "${PURPLE_BLUE}  + ${CYAN}ruby -I\"lib:test\" -I\"${RAKE_LIB_FOLDER}\" \"${LOCATION_RAKE_LIB}\" ${YELLOW220}${INTEGRATION_TESTS_EXISTS}${RED}"
      echo -e "${PURPLE_BLUE}  + ${RED}"
      eval "ruby -I\"lib:test\" -I\"${RAKE_LIB_FOLDER}\" \"${LOCATION_RAKE_LIB}\" " ${INTEGRATION_TESTS_EXISTS}
      #ruby -I"lib:test" -I"/home/vagrant/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib" "/home/vagrant/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib/rake/rake_test_loader.rb" "test/models/insurance_test.rb" "test/workers/twilio_cleaner_worker_test.rb" "test/controllers/account/doctors_controller_test.rb" "test/controllers/doctors/specialties_controller_test.rb" "test/workers/dtms_cleaner_worker_test.rb" "test/controllers/accounts_controller_test.rb" "test/integration/inquiry_plugin_integration_test.rb" "test/controllers/inquiries/confirmations_controller_test.rb" "test/integration/practice_integration_test.rb" "test/services/unprocessed_bookings_test.rb" "test/mailers/user_mailer_test.rb" "test/validators/partner_token_validator_test.rb" "test/models/timeslot_test.rb" "test/models/account_test.rb" "test/models/booking_test.rb" "test/integration/patient_flows_test.rb" "test/controllers/account_backend_controller_test.rb" "test/lib/tasks/unprocessed_bookings_reminders_test.rb" "test/models/inquiry_test.rb" "test/models/partner_test.rb" "test/mailers/smser_test.rb" "test/controllers/directory_controller_test.rb" "test/controllers/account/calendars_controller_test.rb" "test/models/patient_test.rb" "test/integration/review_integration_test.rb" "services/place_service/tests/address_serializer_test.rb"
      echo -e "${PURPLE_BLUE}  + ${RESET}"
      echo -e "${PURPLE_BLUE}  + ${RESET}"
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
given_integrations_testing "${@}"

given_cucumbers_testing() {
trap interrupt_cucumbers INT

  CUCUMBER_TESTS_EXISTS=$(echo "${@}" | sed 's/ /\n/g' | grep -e "\.feature")
  if [[ ! -z "${CUCUMBER_TESTS_EXISTS}" ]] ; then
  {
      echo -e "${PURPLE_BLUE}  + "
      echo -e "${PURPLE_BLUE}  + ${CYAN}TESTING NOW: ${YELLOW220} CUCUMBER"
      echo -e "${PURPLE_BLUE}  + "
      echo -e "${PURPLE_BLUE}  + "sed 's/ /\n/g' | grep -e "\.feature"
      echo -e "${PURPLE_BLUE}  + ${CYAN}bundle exec cucumber ${YELLOW220}${CUCUMBER_TESTS_EXISTS}${RED}"
      echo -e "${PURPLE_BLUE}  + ${RED}"
      eval "bundle exec cucumber ${CUCUMBER_TESTS_EXISTS}"
      echo -e "${PURPLE_BLUE}  + ${RESET}"
      echo -e "${PURPLE_BLUE}  + ${RESET}"
  }
  else
  {
    echo -e "${RED}  + ${YELLOW220}:  ${CYAN} No cucumber tests found !     "
    echo -e "${RED}  + ${YELLOW220}:  ${CYAN} I got this but I am looking for *.feature files      "
    for ONETEST in ${@}; do 
    {
      echo -e "${RED}  + ${YELLOW220}:  ${CYAN} ${ONETEST}"  
    }
    done
    echo -e "${RED}  + ${YELLOW220}: ..."
  }
  fi
} # end cucumbers_testing
given_cucumbers_testing "${@}"

} # end if not -z 1 
fi

