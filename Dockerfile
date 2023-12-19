
FROM alpine:latest

# Instalação de pacotes necessários
RUN apk update && \
    apk upgrade && \
    apk add --no-cache bash openssh sudo python3 py3-pip && \
    rm -rf /var/cache/apk/*

# Definindo variáveis de ambiente
ARG USER_NAME=usuario1
ARG USER_PASS=senha123
ARG ROOT_PASS=senha123

# Adicionando usuário e definindo senha
RUN adduser -D -s /bin/ash -h /home/$USER_NAME -u 1201 $USER_NAME && \
    adduser $USER_NAME wheel && \
    echo "$USER_NAME:$USER_PASS" | chpasswd && \
    echo "root:$USER_PASS" | chpasswd

# Configurando sudoers
RUN cp /etc/sudoers /etc/sudoers.orig && \
    sed "s/ALL=(ALL:ALL) ALL/ALL=(ALL:ALL) NOPASSWD:ALL/" /etc/sudoers.orig > /etc/sudoers

# Copiando chaves SSH
COPY ansible_root_rsa_key.pub /root/.ssh/authorized_keys
COPY ansible_user_rsa_key.pub /home/$USER_NAME/.ssh/authorized_keys

# Instalando e iniciando o servidor SSH
RUN apk add --no-cache openssh-server && \
    ssh-keygen -A && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# Expondo a porta SSH
EXPOSE 22

# Iniciando o SSH
CMD ["/usr/sbin/sshd", "-D"]
