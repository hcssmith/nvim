FROM alpine:latest

# neovim build requirements
RUN apk add --no-cache build-base cmake coreutils curl gettext-tiny-dev git

# build and install neovim:nightly
ADD https://github.com/neovim/neovim.git#nightly /usr/local/neovim
RUN cd /usr/local/neovim  && make CMAKE_BUILD_TYPE=RelWithDebInfo && make install

# install lsp servers

RUN apk add --no-cache lua-language-server


# install treesitter grammars
RUN apk add --no-cache tree-sitter-grammars

# setup nvim user
RUN adduser --disabled-password --gecos "" nvim
RUN mkdir /src && chown nvim:users /src 

USER nvim
WORKDIR /src

RUN mkdir -p /home/nvim/.local/share/nvim/site/pack/colors/start
ADD https://github.com/rose-pine/neovim.git /home/nvim/.local/share/nvim/site/pack/colors/start/rose-pine

# install config

# go straight into neovim
CMD ["/usr/local/bin/nvim"]
