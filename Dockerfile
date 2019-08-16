FROM golang:latest
MAINTAINER Michele Bertasi

ADD fs/ /

# install pagkages
RUN apt-get update                                                      && \
    apt-get install -y ncurses-dev libtolua-dev exuberant-ctags sudo       \
    zsh vim-nox                                                         && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# get go tools
RUN go get golang.org/x/tools/cmd/godoc                                 && \
    go get github.com/nsf/gocode                                        && \
    go get golang.org/x/tools/cmd/goimports                             && \
    go get github.com/rogpeppe/godef                                    && \
    go get golang.org/x/tools/cmd/gorename                              && \
    go get golang.org/x/lint/golint                                     && \
    go get github.com/kisielk/errcheck                                  && \
    go get github.com/jstemmer/gotags                                   && \
    go get github.com/tools/godep

# add dev user
RUN adduser dev --disabled-password --gecos ""                          && \
    echo "ALL            ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers     && \
    chown -R dev:dev /home/dev /go                                      && \
# cleanup
    rm -rf /go/src/* /go/pkg                                            && \
    apt-get remove -y ncurses-dev                                       && \
    apt-get autoremove -y                                               && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

USER dev
ENV HOME=/home/dev LC_ALL=en_US.UTF-8

# install vim plugins
RUN curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim && \
    vim +'silent :PlugInstall' +qall       && \
    vim +'silent :GoInstallBinaries' +qall && \
    sudo mv /go/bin/* /usr/local/go/bin    && \
# cleanup
    sudo rm -rf /go/src/* /go/pkg

RUN touch ~/.zshrc && unset ZSH && \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

ENTRYPOINT ["zsh"]

