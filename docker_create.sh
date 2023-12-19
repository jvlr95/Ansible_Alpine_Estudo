#!/usr/bin/env bash
#---------------------------------------------------------------------------------------------------#
#AUTOR              : João Rodrigues                                                                #
#LINKEDIN           : https://www.linkedin.com/in/joao-rodrigues-4865441a2/                         #
#DATA-DE-CRIAÇÃO    : 2023-12-19                                                                    #
#DESCRIÇÃO          : Script para automatizar processo de criação de container docker para estudos. #
#                     Baseado no container Alpine Linux ultima versão disponivel, explorando outros #
#                     init como OpenRC.                                                             #
#                     Derivado do repositorio:                                                      #
#                       https://github.com/cicerowordb/ansible_docker_playground                    #
#LICENÇA            : MIT (https://opensource.org/licenses/MIT)                                     #
#                     Sujeito aos termos da licença MIT.                                            #
#---------------------------------------------------------------------------------------------------#

# Função para criar network
CreateNetworkAnsible() {
    docker network create \
        --subnet 172.18.0.0/16 \
        --gateway 172.18.0.1 \
        --driver bridge \
        ansible-net
}

# Função para build do dockerfile
BuildDocker() {
    docker build -t ansible-srv .
}

# Função para criar configuração de hosts
CreateHostConfig() {
    printf 'Hosts configuration [ansible_servers]\n' > hosts.ini

    printf "Quantidade de hosts a serem criados: (ex: 10)\n"
    read num_hosts

    # Utilizando 'seq' para gerar uma sequência de números de 1 até $num_hosts
    for x in $(seq "$num_hosts"); do
        printf "ansible-srv$x ansible_host=172.18.1.$x\n" >> hosts.ini
    done

    printf "Configuração de hosts criada com sucesso em hosts.ini\n"
}

# Função para criar containers
CreateContainers() {
    # Obtém o número de hosts criados
    num_hosts=$(wc -l < hosts.ini)

    for x in $(seq 1 "$num_hosts"); do
        docker run --name ansible-srv$x \
            --detach \
            --privileged \
            --cap-add SYS_ADMIN \
            --security-opt seccomp=unconfined \
            --cgroup-parent docker.slice \
            --cgroupns private \
            --net ansible-net \
            --ip 172.18.1.$x \
            --dns 1.1.1.1 \
            --hostname ansible-srv$x \
            --publish 22 \
            ansible-srv
    done
}

# Função para checar IPs
CheckIP() {
    for x in $(seq "$num_hosts"); do
        printf "ansible-srv$x = "
        docker inspect -f \
            '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' \
            ansible-srv$x
    done
}

# Função para apagar containers e rede criados pelo script
DelAll() {
    for x in $(seq 1 "$num_hosts"); do
        container_name="ansible-srv$x"

        # Verifica se o container existe
        if docker ps -a | grep -q "$container_name"; then
            # Remove o container
            docker rm --force "$container_name"
            printf "Container '%s' removido.\n" "$container_name"
        else
            printf "O container '%s' não existe.\n" "$container_name"
        fi
    done

    # Verifica se a imagem 'ansible-srv' existe
    if docker images | grep -q "ansible-srv"; then
        # Remove a imagem 'ansible-srv'
        docker image rm ansible-srv
        printf "Imagem 'ansible-srv' removida.\n"
    else
        printf "A imagem 'ansible-srv' não existe.\n"
    fi

    # Verifica se a rede 'ansible-net' existe
    if docker network ls | grep -q "ansible-net"; then
        # Remove a rede 'ansible-net'
        docker network rm ansible-net
        printf "Rede 'ansible-net' removida.\n"
    else
        printf "A rede 'ansible-net' não existe.\n"
    fi

    printf "Remoção concluída.\n"
}

# Executar menu principal
MenuPrincipal() {
    local opt

    while true; do
        PS3="Selecione a atividade: "
        select opt in "Criar Network" "Build dockerfile" "Criar Hosts" "Executar containers" "Checar IPs" "Apagar todos containers" "Encerrar"; do
            case "$REPLY" in
                1) CreateNetworkAnsible ;;
                2) BuildDocker ;;
                3) CreateHostConfig ;;
                4) CreateContainers ;;
                5) CheckIP ;;
                6) DelAll ;;
                7) exit ;;
                *) printf "Opção inválida\n" ;;
            esac
            break
        done
    done
}

# Executar menu principal
MenuPrincipal

