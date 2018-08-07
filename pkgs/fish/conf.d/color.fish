if status is-login
  set -U fish_color_normal normal
  set -U fish_color_command --bold
  set -U fish_color_param cyan
  set -U fish_color_redirection brblue
  set -U fish_color_comment 888 brblack  # default: red
  set -U fish_color_error brred
  set -U fish_color_escape bryellow --bold
  set -U fish_color_operator bryellow
  set -U fish_color_end brmagenta
  set -U fish_color_quote yellow
  set -U fish_color_autosuggestion 888 brblack  # default: 555 black
  set -U fish_color_user normal  # default: brgreen
  set -U fish_color_host normal  # default: normal
  set -U fish_color_valid_path --underline
  set -U fish_color_cwd 008787  # default: green
  set -U fish_color_cwd_root red
  set -U fish_color_match --background=brblue
  set -U fish_color_search_match --bold --background=005F87  # default: bryellow --background=brblack
  set -U fish_color_cancel -r
  set -U fish_color_history_current --bold
  set -U fish_color_selection white --bold --background=brblack
  set -U fish_pager_color_prefix normal --bold --underline  # default: white --bold --underline
  set -U fish_pager_color_completion
  set -U fish_pager_color_description yellow  # default: B3A06D yellow
  set -U fish_pager_color_progress black --bold --background=cyan  # default: brwhite --background=cyan

  ## Convenient definitions for VCS, spell check, etc.
  set -U fish_status_color_good green
  set -U fish_status_color_bad red
  set -U fish_status_color_warn yellow
end
