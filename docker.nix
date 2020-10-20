{ config, pkgs, ... }:

{
  systemd = {
    services = {
      "docker-build-fhs" = {
        enable = false;
        description = "Create fhs docker container";
        wantedBy = [ "multi-user.target" ];
        script = ''
          mkdir -p /var/docker-fhs && cd /var/docker-fhs
          cat > Dockerfile <<EOF

          FROM ubuntu:disco

          ENV DEBIAN_FRONTEND noninteractive

          RUN apt update && apt upgrade -y && apt install -y wget gnupg

          RUN echo 'deb http://apt.llvm.org/disco/ llvm-toolchain-disco main' \
                  >> /etc/apt/sources.list.d/llvm.list
          RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key| apt-key add -
          RUN apt update

          RUN apt install -y git libssl-dev bison flex bc build-essential gdb
          RUN apt install -y libelf-dev python python3 zsh repo python3-pip
          RUN apt install -y python3-opencv meson ninja-build cmake afl*
          RUN apt install -y clang-10 lldb-10 llvm-10* libfuzzer-10-dev
          RUN apt install -y pkg-config binutils-dev libunwind-dev
          RUN apt install -y command-not-found libglib2.0-dev bsdmainutils
          RUN apt install -y libarchive-dev nettle-dev

          RUN groupmod users -g 100
          RUN useradd user -u 1000 -g 100 -s /bin/zsh

          RUN echo 'cd \$HOST_PWD' >> /etc/zsh/zshrc

          CMD bash -c 'su user'

          EOF
          ${pkgs.docker}/bin/docker build -t fhs .
        '';
        serviceConfig.Type = "oneshot";
      };
    };
  };
}
