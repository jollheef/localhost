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

          FROM ubuntu:devel

          ENV DEBIAN_FRONTEND noninteractive

          RUN apt update && apt upgrade -y
          RUN apt install -y git libssl-dev bison flex bc build-essential
          RUN apt install -y libelf-dev python python3 zsh repo

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
