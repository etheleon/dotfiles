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

