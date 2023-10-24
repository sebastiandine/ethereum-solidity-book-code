FROM rust:1.71-bullseye

# install dependencies from package manager
RUN apt update && apt install -y sudo git

# install nodejs, npm & yarn
RUN curl -fsSL https://deb.nodesource.com/setup_16.x | bash - && apt-get install -y nodejs
RUN npm install -g yarn

# create 'dev' user
RUN mkdir /home/dev
RUN useradd -u 1000 -s /bin/bash dev && chown -R dev /home/dev
RUN adduser dev sudo
RUN echo "dev:dev"|chpasswd 

# configure git and install foundry for user 'dev'
USER dev
RUN git config --global user.name "developer" && git config --global user.email "developer@mail.com"
RUN curl -L https://foundry.paradigm.xyz | bash - && /home/dev/.foundry/bin/foundryup

# enable React Hot Reload in Container
ENV WATCHPACK_POLLING=true