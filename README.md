# DotFiles

My dotfiles, in git form. 

## Quickstart
To initialise a dotfile repository on a new installation of Linux:
1. git clone --separate-git-dir=$HOME/.myconf /path/to/this/repo $HOME/myconf-tmp
2. cp ~/myconf-tmp/.gitmodules ~  # If you use Git submodules
3. rm -r ~/myconf-tmp/
4. alias config='/usr/bin/git --git-dir=$HOME/.myconf/ --work-tree=$HOME'
5. echo "alias config='/usr/bin/git --git-dir=$HOME/.cfg/ --work-tree=$HOME'" >> $HOME/.bashrc # Persist the alias using the local bashrc

## How it Works
Is best explained by [this post](https://developer.atlassian.com/blog/2016/02/best-way-to-store-dotfiles-git-bare-repo/) on the Atlassian developer blog. Credit should also be given to [this thread](https://news.ycombinator.com/item?id=11070797) on HN which inspired the Atlassian post. 
