# name: Draculicious
# An Agnoster + Powerline-inspired theme for FISH
#
# # README
#
# In order for this theme to render correctly, you will need a
# [Powerline-patched font](https://gist.github.com/1595572).

## Set this options in your config.fish (if you want to :])
# set -g theme_display_user yes
# set -g theme_hide_hostname yes
# set -g theme_hide_hostname no
# set -g theme_use_alias yes
# set -g theme_user_alias 1337UserName
# set -g default_user your_normal_user

# black, red, green, brown, yellow, blue, magenta, purple, cyan, grey,
# brgrey, brred, brgreen, brbrown, bryellow, brblue, brmagenta, brpurple, brcyan,
# white, normal

set fish_color_normal normal # the default color
set fish_color_command blue # the color for commands
set fish_color_quote bryellow # the color for quoted blocks of text
# set fish_color_redirection # the color for IO redirections
# set fish_color_end # the color for process separators like ';' and '&'
set fish_color_error brred # the color used to highlight potential errors
set fish_color_param cyan # the color for regular command parameters
# set fish_color_comment # the color used for code comments
# set fish_color_match # the color used to highlight matching parenthesis
# set fish_color_search_match # the color used to highlight history search matches
# set fish_color_operator # the color for parameter expansion operators like '*' and '~'
# set fish_color_escape # the color used to highlight character escapes like '\n' and '\x70'
# set fish_color_cwd # the color used for the current working directory in the default prompt
set fish_color_autosuggestion brgrey # the color used for autosuggestions
set fish_color_user white # the color used to print the current username in some of fish default prompts
# set fish_color_host # the color used to print the current host system in some of fish default prompts

# set fish_pager_color_prefix # the color of the prefix string, i.e. the string that is to be completed
set fish_pager_color_completion brgrey # the color of the completion itself
# set fish_pager_color_description # the color of the completion description
# set fish_pager_color_progress # the color of the progress bar at the bottom left corner
# set fish_pager_color_secondary # the background color of the every second completion

set -g current_bg NONE
set segment_separator \uE0B0
set right_segment_separator \uE0B0
# ===========================
# Helper methods
# ===========================

set -g __fish_git_prompt_showdirtystate 'yes'
set -g __fish_git_prompt_char_dirtystate '±'
set -g __fish_git_prompt_char_cleanstate ''

function parse_git_dirty
  set -l submodule_syntax
  set submodule_syntax "--ignore-submodules=dirty"
  set git_dirty (command git status --porcelain $submodule_syntax  2> /dev/null)
  if [ -n "$git_dirty" ]
    if [ $__fish_git_prompt_showdirtystate = "yes" ]
      echo -n "$__fish_git_prompt_char_dirtystate"
    end
  else
    if [ $__fish_git_prompt_showdirtystate = "yes" ]
      echo -n "$__fish_git_prompt_char_cleanstate"
    end
  end
end


# ===========================
# Segments functions
# ===========================

function prompt_segment -d "Function to draw a segment"
  set -l bg
  set -l fg
  if [ -n "$argv[1]" ]
    set bg $argv[1]
  else
    set bg normal
  end
  if [ -n "$argv[2]" ]
    set fg $argv[2]
  else
    set fg normal
  end
  if [ "$current_bg" != 'NONE' -a "$argv[1]" != "$current_bg" ]
    set_color -b $bg
    set_color $current_bg
    echo -n "$segment_separator "
    set_color -b $bg
    set_color $fg
  else
    set_color -b $bg
    set_color $fg
    echo -n " "
  end
  set current_bg $argv[1]
  if [ -n "$argv[3]" ]
    echo -n -s $argv[3] " "
  end
end

function prompt_finish -d "Close open segments"
  if [ -n $current_bg ]
    set_color -b normal
    set_color $current_bg
    echo -n "$segment_separator "
  end
  set -g current_bg NONE
end


# ===========================
# Theme components
# ===========================

function prompt_virtual_env -d "Display Python virtual environment"
  if test "$VIRTUAL_ENV"
    prompt_segment white black (basename $VIRTUAL_ENV)
  end
end

function prompt_user -d "Display current user if different from $default_user"
  if [ "$theme_display_user" = "yes" ]
    if [ "$USER" != "$default_user" -o -n "$SSH_CLIENT" ]
      get_username
      get_hostname
      if [ $HOSTNAME_PROMPT ]
        set USER_PROMPT $USER@$HOSTNAME_PROMPT
      else
        set USER_PROMPT $USER
      end
      prompt_segment magenta black $USER_PROMPT
    end
  else
    get_hostname
    if [ $HOSTNAME_PROMPT ]
      prompt_segment magenta black $HOSTNAME_PROMPT
    end
  end
end

function get_hostname -d "Set current hostname to prompt variable $HOSTNAME_PROMPT if connected via SSH"
  set -g HOSTNAME_PROMPT ""
  if [ "$theme_hide_hostname" = "no" -o \( "$theme_hide_hostname" != "yes" -a -n "$SSH_CLIENT" \) ]
    set -g HOSTNAME_PROMPT (hostname)
  end
end

function get_username -d "Set username to prompt variable $USERNAME_PROMPT"
  if [ "$theme_use_alias" = "yes" ]
    set USER $theme_user_alias
  else
    set USER (whoami)
  end
end

function prompt_dir -d "Display the current directory"
  prompt_segment brblue black (prompt_pwd)
end


function prompt_hg -d "Display mercurial state"
  set -l branch
  set -l state
  if command hg id >/dev/null 2>&1
    if command hg prompt >/dev/null 2>&1
      set branch (command hg prompt "{branch}")
      set state (command hg prompt "{status}")
      set branch_symbol \uE0A0
      if [ "$state" = "!" ]
        prompt_segment brred black "$branch_symbol $branch ±"
      else if [ "$state" = "?" ]
          prompt_segment yellow black "$branch_symbol $branch ±"
        else
          prompt_segment green black "$branch_symbol $branch"
      end
    end
  end
end


function prompt_git -d "Display the current git state"
  set -l ref
  set -l dirty
  if command git rev-parse --is-inside-work-tree >/dev/null 2>&1
    set dirty (parse_git_dirty)
    set ref (command git symbolic-ref HEAD 2> /dev/null)
    if [ $status -gt 0 ]
      set -l branch (command git show-ref --head -s --abbrev |head -n1 2> /dev/null)
      set ref "➦ $branch "
    end
    set branch_symbol \uE0A0
    set -l branch (echo $ref | sed  "s-refs/heads/-$branch_symbol -")
    if [ "$dirty" != "" ]
      prompt_segment yellow black "$branch $dirty"
    else
      prompt_segment green black "$branch $dirty"
    end
  end
end


function prompt_svn -d "Display the current svn state"
  set -l ref
  if command svn ls . >/dev/null 2>&1
    set branch (svn_get_branch)
    set branch_symbol \uE0A0
    set revision (svn_get_revision)
    prompt_segment green black "$branch_symbol $branch:$revision"
  end
end

function svn_get_branch -d "get the current branch name"
  svn info 2> /dev/null | awk -F/ \
      '/^URL:/ { \
        for (i=0; i<=NF; i++) { \
          if ($i == "branches" || $i == "tags" ) { \
            print $(i+1); \
            break;\
          }; \
          if ($i == "trunk") { print $i; break; } \
        } \
      }'
end

function svn_get_revision -d "get the current revision number"
  svn info 2> /dev/null | sed -n 's/Revision:\ //p'
end


function prompt_status -d "the symbols for a non zero exit status, root and background jobs"
    if [ $RETVAL -ne 0 ]
      prompt_segment brgrey brred "✘"
    end

    # if superuser (uid == 0)
    set -l uid (id -u $USER)
    if [ $uid -eq 0 ]
      prompt_segment brgrey yellow "⚡"
    end

    # Jobs display
    if [ (jobs -l | wc -l) -gt 0 ]
      prompt_segment brgrey cyan "⚙"
    end
end

# ===========================
# Apply theme
# ===========================

function fish_prompt
  set -g RETVAL $status
  prompt_status
  prompt_virtual_env
  prompt_user
  prompt_dir
  type -q hg;  and prompt_hg
  type -q git; and prompt_git
  type -q svn; and prompt_svn
  prompt_finish
end
