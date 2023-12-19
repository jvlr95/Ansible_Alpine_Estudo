# Automação Docker com Ansible para Alpine Linux

Este repositório contém scripts e instruções para a criação de containers Docker usando imagens Alpine Linux. Além disso, inclui instruções para a criação de chaves SSH e testes de conectividade.

**Créditos ao Professor Cícero ([GitHub](https://github.com/cicerowordb))**: Este projeto é derivado do repositório [ansible_docker_playground](https://github.com/cicerowordb/ansible_docker_playground) do Professor Cícero. Agradecemos pela contribuição e inspiração.

## Pré-requisitos

Certifique-se de ter o Ansible instalado em sua máquina. Para instalar o Ansible, siga as [instruções oficiais](https://docs.ansible.com/ansible/latest/installation_guide/index.html).

## Geração de Chaves SSH

Execute os seguintes comandos para gerar as chaves SSH necessárias para autenticação durante os testes:

```bash
ssh-keygen -P "" -t rsa -b 4096 -C "root@server.local" -f ansible_root_rsa_key
ssh-keygen -P "" -t rsa -b 4096 -C "user@server.local" -f ansible_user_rsa_key
```

## Executando o script docker_create.sh

Clone este repositório:

```bash
git clone https://github.com/seu-usuario/seu-repositorio.git
cd seu-repositorio
```

Dê permissão de execução para o script `docker_create.sh` usando:

```bash
chmod +x docker_create.sh
```

Execute o script:

```bash
./docker_create.sh
```

O script realiza as seguintes etapas:

- Criação de uma rede Docker chamada `ansible-net`.
- Construção de uma imagem Docker chamada `ansible-srv`.
- Criação de uma configuração de hosts no arquivo `hosts.ini`.
- Execução de containers com base na configuração de hosts.

## Testes de Conectividade SSH

Após a execução do script, você pode realizar testes de conectividade SSH usando as chaves geradas anteriormente. Utilize os seguintes comandos como exemplo:

- Teste com Usuário Root:

```bash
ssh -o "StrictHostKeyChecking no" -i ansible_root_rsa_key root@172.18.1.1
```

- Teste com Usuário Criado no Dockerfile (usuario1):

```bash
ssh -o "StrictHostKeyChecking no" -i ansible_user_rsa_key usuario1@172.18.1.1
```

Certifique-se de substituir `172.18.1.1` pelo endereço IP correto do host onde o Alpine Linux com Docker foi configurado.

Essas instruções pressupõem que o sistema operacional alvo é o Alpine Linux. Se você estiver usando um sistema diferente, os comandos e configurações podem precisar ser ajustados.
```

Este é um exemplo básico e você pode personalizar conforme necessário. Certifique-se de revisar e ajustar conforme a estrutura do seu projeto.
