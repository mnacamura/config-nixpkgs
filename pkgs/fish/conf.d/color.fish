set -q __fish_config_color_sourced
or if status is-login

  set -U fish_color_normal normal
  set -U fish_color_command --bold  # default: 005fd7
  set -U fish_color_param cyan  # default: 00afff
  set -U fish_color_keyword magenta  # default: none
  set -U fish_color_redirection yellow  # default: 00afff
  set -U fish_color_comment brblack  # default: red
  set -U fish_color_error red  # default: ff0000
  set -U fish_color_escape yellow  # default: 00a6b2
  set -U fish_color_operator yellow  # default: 00a6b2
  set -U fish_color_end brblack  # default: 009900
  set -U fish_color_quote brgreen  # default: 999900
  set -U fish_color_autosuggestion brblack  # default: 555 black
  set -U fish_color_user white  # default: brgreen
  set -U fish_color_host white  # default: normal
  set -U fish_color_host_remote bryellow --bold  # default: yellow
  set -U fish_color_valid_path --underline
  set -U fish_color_cwd blue --bold # default: green
  set -U fish_color_cwd_root brred --bold  # default: red
  set -U fish_color_search_match --reverse  # default: bryellow --background=brblack
  set -U fish_color_cancel -r
  set -U fish_color_selection --reverse  # default: white --bold --background=brblack

  set -U fish_pager_color_prefix normal --bold
  # NOTE: Below is not found in share/functions/__fish_config_interactive.fish
  # set -U fish_pager_color_background
  set -U fish_pager_color_completion brblack
  set -U fish_pager_color_description yellow  # default: B3A06D yellow
  set -U fish_pager_color_progress black --bold --background=@accent@  # default: brwhite --background=cyan

  # NOTE: Below are not found in share/functions/__fish_config_interactive.fish
  # set -U fish_pager_color_selected_background
  # set -U fish_pager_color_selected_prefix
  # set -U fish_pager_color_selected_completion
  # set -U fish_pager_color_selected_description
  # set -U fish_pager_color_secondary_background
  # set -U fish_pager_color_secondary_prefix
  # set -U fish_pager_color_secondary_completion
  # set -U fish_pager_color_secondary_description

  ## Convenient definitions for VCS, spell check, etc.
  set -U my_status_color_ok green
  set -U my_status_color_error red
  set -U my_status_color_warn yellow
end

set -g __fish_config_color_sourced
