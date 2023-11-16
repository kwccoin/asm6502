# install lisp

## follows 

[](https://susam.net/blog/lisp-in-vim.html)

## one of the key take away is to
## install test all sbcl first and quite the vim
## before do quicklisp

## then instead of vim-nox ... try 

brew install sbcl git macvim tmux

## spend a lot of times updating other compoinents like 
##    llvm, python3.12 ... etc.
##    rust, libssh2, six, xz, pkg-config, ...    

# do the slimv

git clone https://github.com/kovisoft/slimv.git ~/.vim/pack/plugins/start/slimv
vim +'helptags ~/.vim/pack/plugins/start/slimv/doc' +q

tmux

sbcl --load ~/.vim/pack/plugins/start/slimv/slime/start-swank.lisp

vim foo.lisp

; ,c ,e ,b ...
; use ; to avoid the paraedit issue (if you like me do not know the key for that)

; ctrl-ww (and remember those vi mode etc.)

(exit) / (quit) ; no use, use wq and q etc.

## Not in the instruction but in vlime (!?) still need to do it

curl -O https://beta.quicklisp.org/quicklisp.lisp
sbcl --load quicklisp.lisp --eval '(quicklisp-quickstart:install)' --eval '(exit)'
sbcl --load ~/quicklisp/setup.lisp --eval '(ql:add-to-init-file)' --eval '(exit)'

## not do any paraedit but should be done in slimv ...

shift-( turn on and off paredit mode
shift-> < on a () has the slurf and barf thing but very confusing still but sometimes might be better than ;

see [](https://calva.io/paredit/)  and possibly [](https://github.com/vim-scripts/paredit.vim/blob/master/doc/paredit.txt

