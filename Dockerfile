# Use Fedora as the base image
FROM fedora:latest

# Update and install dependencies
RUN dnf update -y && \
	dnf install -y \
	rustup \
	nu \
	neovim \
	openssh-server \
	curl \
	git \
	sudo \
	vim \
	@development-tools \
	&& dnf clean all


RUN echo $(which nu) >> /etc/shells

RUN yes | dnf copr enable jdxcode/mise
RUN yes | dnf install mise

RUN yes | dnf copr enable varlad/zellij 
RUN yes | dnf install zellij

# Allow root login and set a password
RUN echo 'root:root' | chpasswd

# Allow SSH connections
RUN sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# RUN chsh $(which nu)

# Create a workspace folder for the project
WORKDIR /workspace

# Expose the SSH port
EXPOSE 22

ARG DOCKER_USER=fox
RUN useradd --system --user-group --create-home $DOCKER_USER --shell "$(which nu)"
USER $DOCKER_USER

RUN /bin/rustup-init -y --default-host x86_64-unknown-linux-gnu --default-toolchain nightly --profile minimal
# RUN rustup toolchain install nightly --component rustc cargo rust-std rust-docs llvm-tools

ENTRYPOINT ["nu", "-l"]
