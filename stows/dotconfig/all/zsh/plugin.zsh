#######################################################
# PLUGINS MANAGEMENT
# see: https://github.com/mattmc3/zsh_unplugged
#######################################################

# where do we want to store our plugins?
ZPLUGINDIR=${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.config/zsh}/plugins}

if [[ ! -d $ZPLUGINDIR ]]; then
    mkdir -p "$ZPLUGINDIR"
fi

# Clone a plugin.
#
# identify its init file, source it,
# and add it to your fpath.
function plugin::load() {
  local repo plugdir initfile initfiles=()
  : ${ZPLUGINDIR:=${ZDOTDIR:-~/.config/zsh}/plugins}

  for repo in $@; do
    plugdir=$ZPLUGINDIR/${repo:t}
    initfile=$plugdir/${repo:t}.plugin.zsh
    if [[ ! -d $plugdir ]]; then
      echo "Cloning $repo..."
      git clone -q --depth 1 --recursive --shallow-submodules \
          https://github.com/"$repo" "$plugdir"
    fi

    if [[ ! -e $initfile ]]; then
      initfiles=("$plugdir"/*.{plugin.zsh,zsh-theme,zsh,sh}(N))
      (( $#initfiles )) || { echo >&2 "No init file '$repo'." && continue }
      ln -sf $initfiles[1] $initfile
    fi
    fpath+=$plugdir
    (( $+functions[zsh-defer] )) && zsh-defer . $initfile || . $initfile
  done
}


function plugin::update() {
  for d in $ZPLUGINDIR/*/.git(/); do
    echo "Updating ${d:h:t}..."
    command git -C "${d:h}" pull --ff --recurse-submodules --depth 1 --rebase --autostash
  done
}


function plugin::list() {
    for d in $ZPLUGINDIR/*/.git; do
        git -C "${d:h}" remote get-url origin
    done
}
