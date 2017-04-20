# This is just placeholder if you don't intend to use system's ~/.bashrc
# Othervise add this the following two lines to the end of original system ~/.bashrc

if [ -f ~/.oh_my_bash ]; then
  source ~/.oh_my_bash # oh_my_zsh alternative :-)
fi

if [ -f ~/.localrc ]; then
  source ~/.localrc
fi

