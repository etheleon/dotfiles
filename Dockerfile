# This script is designed to work with ubuntu 16.04 LTS
FROM nvidia/cuda:9.1-cudnn7-runtime-ubuntu16.04
# ensure system is updated and has basic build tools
RUN apt-get -f -y upgrade
RUN apt-get clean
RUN apt-get update --fix-missing
RUN apt-get -f -y install \
    tmux \
    build-essential \
    gcc g++ make \
    binutils \
    curl \
    git \
    zsh \
    software-properties-common file locales uuid-runtime \
    wget bzip2 ca-certificates \
    libglib2.0-0 libxext6 libsm6 libxrender1 \
    mercurial subversion
RUN apt-get clean
RUN apt-get update
RUN add-apt-repository ppa:neovim-ppa/stable
RUN apt-get update
RUN apt-get install -y -f neovim

ENV LANG=C.UTF-8 LC_ALL=C.UTF-8 \
    SHELL=/bin/zsh

RUN apt-get install -y ruby sudo

RUN echo "LC_ALL=en_US.UTF-8" >> /etc/environment
RUN echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
RUN echo "LANG=en_US.UTF-8" > /etc/locale.conf
RUN locale-gen en_US.UTF-8

# install Anaconda for current user
RUN echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh && \
    wget --quiet https://repo.continuum.io/archive/Anaconda3-5.0.1-Linux-x86_64.sh -O ~/anaconda.sh && \
    /bin/bash ~/anaconda.sh -b -p /opt/conda && \
    rm ~/anaconda.sh

#user uesu
RUN useradd -m -s /bin/zsh uesu
RUN echo 'uesu ALL=(ALL) NOPASSWD:ALL' >>/etc/sudoers
USER uesu
WORKDIR /home/uesu

# install zsh
RUN sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

#linuxbrew
#RUN ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Linuxbrew/install/master/install)"
RUN git clone https://github.com/Linuxbrew/brew.git /home/uesu/.linuxbrew
ENV PATH=/opt/conda/bin:/home/uesu/.linuxbrew/bin:/home/uesu/.linuxbrew/sbin:$PATH
RUN brew doctor
RUN brew update
ENV MANPATH="$(brew --prefix)/share/man:$MANPATH" \
    INFOPATH="$(brew --prefix)/share/info:$INFOPATH"

# install and configure keras
RUN sudo /opt/conda/bin/pip install keras==1.2.2
RUN mkdir ~/.keras
RUN echo '{ "image_dim_ordering": "th", "epsilon": 1e-07, "floatx": "float32", "backend": "theano" }' > ~/.keras/keras.json

# configure jupyter and prompt for password
RUN jupyter notebook --generate-config
#RUN jupass=`python -c "from notebook.auth import passwd; print(passwd())"`
#RUN echo "c.NotebookApp.password = u'"$jupass"'" >> $HOME/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.ip = '*'" >> $HOME/.jupyter/jupyter_notebook_config.py
RUN echo "c.NotebookApp.open_browser = False" >> $HOME/.jupyter/jupyter_notebook_config.py

#configure ipython
RUN ipython profile create


#neovi
RUN echo "set editing-mode vi" >> $HOME/.inputrc

RUN git clone https://github.com/etheleon/nvim.git $HOME/.config/nvim
RUN echo | echo | nvim -i NONE -c PlugInstall -c quitall > /dev/null 2>&1
RUN echo | echo | nvim -i NONE -c UpdateRemotePlugins -c quitall > /dev/null 2>&1

RUN echo "set keymap vi-command\n" >> $HOME/.inputrc
RUN echo "Control-l: clear-screen\n" >> $HOME/.inputrc
RUN echo "set keymap vi-insert\n" >> $HOME/.inputrc
RUN echo "Control-l: clear-screen\n" >> $HOME/.inputrc
RUN echo "bindkey -v\n" >> $HOME/.zshrc
RUN echo "bindkey '^R' history-incremental-search-backward" >> $HOME/.zshrc

RUN echo "hello1234"
RUN echo "c.InteractiveShellApp.extensions = ['autoreload']\n" >> $HOME/.ipython/profile_default/ipython_config.py
RUN echo "c.InteractiveShellApp.exec_lines = ['%autoreload 2']\n" >> $HOME/.ipython/profile_default/ipython_config.py
RUN echo "c.InteractiveShellApp.exec_lines.append('print(\"Warning: disable autoreload in ipython_config.py to improve performance.\")')\n" >> $HOME/.ipython/profile_default/ipython_config.py


RUN sudo apt-get install -y cmake

RUN git clone https://github.com/01org/mkl-dnn.git /home/uesu/mkl-dnn
WORKDIR /home/uesu/mkl-dnn/scripts
RUN bash ./prepare_mkl.sh
WORKDIR /home/uesu/mkl-dnn/
RUN mkdir -p build
WORKDIR /home/uesu/mkl-dnn/build
RUN cmake ..
RUN make
RUN sudo make install

RUN sudo apt-get install -y htop tree


ENV LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/usr/local/lib
RUN sudo /opt/conda/bin/pip install --upgrade https://github.com/mind/wheels/releases/download/tf1.4.1-gpu-cuda91/tensorflow-1.4.1-cp36-cp36m-linux_x86_64.whl

RUN sudo /opt/conda/bin/conda install pytorch torchvision cuda90 -c pytorch

RUN sudo /opt/conda/bin/pip install jupyter-tensorboard

WORKDIR /home/uesu
RUN git clone https://github.com/gpakosz/.tmux.git
RUN ln -s -f .tmux/.tmux.conf
RUN cp .tmux/.tmux.conf.local .

RUN sudo apt-get install -y fonts-powerline
