{ config, pkgs, ... }:

{
  systemd = {
    services = {
      "docker-build-fhs" = {
        enable = true;
        description = "Create fhs docker container";
        wantedBy = [ "multi-user.target" ];
        script = ''
          mkdir -p /var/docker-fhs && cd /var/docker-fhs
          cat > Dockerfile <<EOF

          FROM ubuntu:latest

          ENV DEBIAN_FRONTEND noninteractive

          RUN apt update && apt upgrade -y && apt install -y wget gnupg

          RUN echo 'deb http://apt.llvm.org/focal/ llvm-toolchain-focal-11 main' \
                  >> /etc/apt/sources.list.d/llvm.list
          RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key| apt-key add -
          RUN apt update

          RUN apt install -y git libssl-dev bison flex bc build-essential gdb
          RUN apt install -y libelf-dev python python3 zsh python3-pip
          RUN apt install -y python3-opencv meson ninja-build cmake afl*
          RUN apt install -y clang-11 lldb-11 llvm-11* libfuzzer-11-dev
          RUN apt install -y pkg-config binutils-dev libunwind-dev
          RUN apt install -y command-not-found libglib2.0-dev bsdmainutils
          RUN apt install -y libarchive-dev nettle-dev libseccomp-dev

          RUN groupmod users -g 100
          RUN useradd user -u 1002 -g 100 -s /bin/zsh

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
