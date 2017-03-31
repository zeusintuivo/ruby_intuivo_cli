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
if [ ! -d .bundle/ ] ; then
{
  echo " "
  echo -e "${RED} ERROR: There is no .bundle/ directory.${RESET}"
  echo " "
  exit 1
}
fi
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

BRANCH=$(git_current_branch)
echo " "
echo
echo -e "${PURPLE_BLUE} === Branch ${CYAN} ${BRANCH} ${PURPLE_BLUE} === ${GRAY241} ";
echo
echo " "
echo -e "${CYAN} Rubocop only files from this branch"
echo -e "${PURPLE_BLUE}+-+"
echo "  +"
echo -e "  +-- ${CYAN} Locating files that changes in this branch "
echo -e "${PURPLE_BLUE}  +${GRAY241}"

FILES1=$(git diff --name-only "${BRANCH}" $(git merge-base "${BRANCH}" master) | egrep ".rb|.rake")
FILES2=$(git status -sb | egrep -v "##" | cut -c4- | egrep -v ".csv|.sh|.yml|.gitignore|.log|.txt|.key|.crt|.csr|.idl|.json|.js|.jpg|.png|.html|.gif|.feature|.scss|.css|.haml|.erb|.otf|.svg|.ttf|.tiff|.woff|.eot|.editorconfig|.markdown|.headings")
FILES="${FILES1}
${FILES2}"
echo -e "${PURPLE_BLUE}   +"
echo -e "  +---------- ${CYAN}Rubo ${PURPLE_BLUE}- checking files ${CYAN}-----------+ "
echo -e "${PURPLE_BLUE}   +                                            + "
echo -e "~~+                                            +~~${GRAY241}"
while read -r ONE_FILE; do
{
  if [ ! -z "${ONE_FILE}" ] ; then
  {
    echo "  + ${ONE_FILE}"
  }
  fi
}
done <<< "${FILES}"

echo "${FILES}" | sort -n | uniq | xargs bundle exec rubocop -a
echo -e "${PURPLE_BLUE} ~~+                                            +~~"
echo "  +                                            + "
echo -e "  +--------------------------------------------+ ${GRAY241}"


# Then get folder based on ruby version 2.2.5 and rake version 10.5.0 used for development
LOCATION_RAKE_LIB=$(locate test_loader.rb | grep "rake-10.5.0/lib" | grep "ruby-2.2.5")
RAKELOADER_LIB_FOLDER=$(echo ${LOCATION_RAKE_LIB%/*})
RAKE_LIB_FOLDER=$(echo ${RAKELOADER_LIB_FOLDER%/*})

# ALL THE TESTS
# ruby -I"lib:test" -I"$HOME/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib" "$HOME/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib/rake/rake_test_loader.rb" "test/models/insurance_test.rb" "test/workers/twilio_cleaner_worker_test.rb" "test/controllers/account/doctors_controller_test.rb" "test/controllers/doctors/specialties_controller_test.rb" "test/workers/dtms_cleaner_worker_test.rb" "test/controllers/accounts_controller_test.rb" "test/integration/inquiry_plugin_integration_test.rb" "test/controllers/inquiries/confirmations_controller_test.rb" "test/integration/practice_integration_test.rb" "test/services/unprocessed_bookings_test.rb" "test/mailers/user_mailer_test.rb" "test/validators/partner_token_validator_test.rb" "test/models/timeslot_test.rb" "test/lib/tasks/cleanup_email_test.rb" "test/lib/tasks/cleanup_sms_test.rb" "test/models/account_test.rb" "test/models/booking_test.rb" "test/integration/patient_flows_test.rb" "test/controllers/account_backend_controller_test.rb" "test/lib/tasks/unprocessed_bookings_reminders_test.rb" "test/models/inquiry_test.rb" "test/models/partner_test.rb" "test/mailers/smser_test.rb" "test/controllers/directory_controller_test.rb" "test/controllers/account/calendars_controller_test.rb" "test/models/patient_test.rb" "test/integration/review_integration_test.rb" "services/place_service/tests/address_serializer_test.rb"

# Email
# ruby -I"lib:test" -I"$HOME/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib" "$HOME/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib/rake/rake_test_loader.rb"  "test/lib/tasks/cleanup_email_test.rb"

# ruby -I"lib:test" -I"$HOME/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib" "$HOME/.rvm/gems/ruby-2.2.5/gems/rake-10.5.0/lib/rake/rake_test_loader.rb"  "test/lib/tasks/cleanup_sms_test.rb"

if [ -z "${1}" ] ; then
{
  exit 0
}
else
{
  echo " "
  echo "Perform Tests"
  echo " "
  # PERFORM TESTS
  ruby -I"lib:test" -I"${RAKE_LIB_FOLDER}" "${LOCATION_RAKE_LIB}" "${1}"

  # SAMPLES
  # ./check.sh test/lib/tasks/cleanup_email_test.rb
}
fi

