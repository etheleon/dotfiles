if [ -d $HOME/local ]; then
    for i in $HOME/local/* ; do
        [ -d $i/bin ] && PATH="${i}/bin:${PATH}"
        [ -d $i/sbin ] && PATH="${i}/sbin:${PATH}"
        [ -d $i/include ] && CPATH="${i}/include:${CPATH}"
        [ -d $i/lib ] && LD_LIBRARY_PATH="${i}/lib:${LD_LIBRARY_PATH}"
        [ -d $i/lib ] && LD_RUN_PATH="${i}/lib:${LD_RUN_PATH}"
        # uncomment the following if you use macintosh
        #  [ -d $i/lib ] && DYLD_LIBRARY_PATH="${i}/lib:${DYLD_LIBRARY_PATH}"
        [ -d $i/lib/pkgconfig ] && PKG_CONFIG_PATH="${i}/lib/pkgconfig:${PKG_CONFIG_PATH}"
        [ -d $i/share/man ] && MANPATH="${i}/share/man:${MANPATH}"
    done
    export PATH
    # strip trailing colons
    export LD_LIBRARY_PATH=${LD_LIBRARY_PATH%:}
    export LD_RUN_PATH=${LD_RUN_PATH%:}
    export PKG_CONFIG_PATH=${PKG_CONFIG_PATH%:}
  fi

# ftags - search ctags
ftags() {
  local line
  [ -e tags ] &&
  line=$(
    awk 'BEGIN { FS="\t" } !/^!/ {print toupper($4)"\t"$1"\t"$2"\t"$3}' tags |
    cut -c1-80 | fzf --nth=1,2
  ) && ${EDITOR:-vim} $(cut -f3 <<< "$line") -c "set nocst" \
                                      -c "silent tag $(cut -f2 <<< "$line")"
}

source $HOME/local/kube-ps1/kube-ps1.sh
PS1=$PS1
PS1='╭─$(kube_ps1) '$PS1'
╰─ '
