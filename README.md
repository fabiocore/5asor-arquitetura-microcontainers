# Fiap - 5ASOR - Arquitetura Microcontainers - Prof. Leandro

Repositório do trabalho de conclusão de disciplina Fiap.

## Índice

1. [Descrição da Atividade](#1-descrição-da-atividade)
2. [Membros do Grupo](#2-membros-do-grupo)
3. [Pré-requisitos](#3-pré-requisitos)
4. [Passo a Passo](#4-passo-a-passo)

## 1. Descrição da Atividade

Você foi contratado para atuar no time DevOps, com a responsabilidade de provisionar um site Wordpress, para que o time de Marketing Digital possa configurar o site principal da companhia. O Kubernetes é a solução oficial de orquestração dos containers da empresa. O MySQL é tecnologia de banco de dados principal, com um time de DBA especializados para sustentação. Foi solicitado o provisionamento do Wordpress, e um banco de dados MySQL de uso exclusivo do Wordpress, para persistência de todas as configurações realizadas pelo time de Marketing Digital. Tanto o Wordpress quanto o MySQL deverão estar em containers geridos pelo Kubernetes.

Para isso, você deverá criar todas as configurações Kubernetes necessárias para provisionamento do Wordpress e MySQL, utilizando microk8s ou k3s, permitindo instanciar todos pods, services, ingress e configurações adicionais necessárias, garantindo que mesmo ao destruir um pod Wordpress e/ou MySQL, os dados de configuração do ambiente Wordpress não sejam perdidos. 

Enviar um arquivo .zip, contendo todos os arquivos de configuração Kubernetes, com as instruções para aplicação dessas configs, possibilitando o deployment da solução e utilização do Wordpress.

As instruções deverão estar descridas num arquivo PDF, Markdown ou txt, com imagens ilustrativas e texto descritivo, indicando quais sequências de comandos devem ser aplicados passo a passo, para instalação do Kubernetes a partir de uma VM Ubuntu (AWS EC2 ou Killercoda) e provisionamento do site Wordpress. Serão seguidas as instruções conforme descritas e o trabalho será avaliado nos seguinte pontos:
    - Atendimento das necessidades da área de Marketing Digital (irei simular um profissional dessa área tentando configurar o Wordpress para a empresa);
    - O Wordpress deverá funcionar após seguir o passo a passo descrito;
    - Será simulado a perda dos pods do Wordpress e MySQL, para validar a resiliência da solução construída;
    - Clareza nas instruções;
    - Completude das configurações disponibilizadas no arquivo .zip, com orientação de suas aplicações no ambiente;
    - Caso o grupo desejar, pode ser disponibilizado um script de IaC (Ansible, Terraform, etc.) ou módulo Kustomize (https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/) para empacotamento das configurações K8S.

## 2. Membros do Grupo

- Anderson Luis Lins Rocha
- Augusto Oening Costa
- Carlos Correa
- Fabio Ferreira da Silva
- Giliane Maciel do Vale
- Michael Andre Santos Brito

## 3. Pré-requisitos

Este guia pressupõe que o professor ou responsável pelo provisionamento e testes já possua:

- Uma conta AWS configurada;
- Um usuário com direitos administrativos.
- Consideramos o uso de um usuário de IAM e **NÃO** iremos abordar configurações com o AWS Identity Center.
- [git-scm](https://git-scm.com/downloads) na máquina local
- Servidor com Ubuntu 22x ou superior

ATENÇÃO! Não abordamos neste material:

- Como criar ou configurar uma conta AWS.
- Como adicionar usuários e políticas de acesso na AWS.
- Como instalar e configurar o Windows WSLv2.
- Instalar o git-scm.

:bangbang: Os recursos provisionados por este laboratório geram custos!

- Região: us-east-2
- EC2 instance t3a.xlarge: USD 0.1504 por hora
- Amazon EBS(gp3): USD 0,08GB-mês
- Internet data transfer(outbound): 100GB free tier por mês

## 4. Passo a Passo

Nosso passo a passo pode ser executado de duas maneiras: desde o início, opcionalmente, criando a infraestrutura básica na AWS através de nossos scripts ou pulando esta estapa e indo diretamente para a configuração da instância com EC2.

- Siga através dos itens 4.1. até 4.2. para provisionar a infra básica na AWS com VPC, subnets, rotas, internet gateway e instância EC2.
- Siga os itens 4.x. até 4.x. se já tiver uma instância ativa e quiser configurar apenas o K3S, Wordpress e MySQL.

### 4.1. Infra Básica - Configuração das credenciais do usuário

Passo a passo para configuração das credenciais do usuário (AccessKey e SecretKey):

Faça o login em sua conta AWS, na mesma janela, pressione ALT+S e busque por IAM:

![ALT+S IAM](./imagens/alts-iam.png)

Do lado esquerdo, no menu do Identiy and Access Management(IAM), click em Users:

![IAM Users](./imagens/iam-users.png)

Localize seu usuário e de um click nele:

![IAM Admin user](./imagens/iam-admin-user.png)

Na parte principal, vá em Security Credentials e depois de um click em Create access key:

![Create Access Key](./imagens/create-access-key.png)

Para finalizar o processo através do wizard:

- Selecione Command Line Interface (CLI)
- Click em "I understand the above recommendation and want to proceed to create an access key."
- Next
- Insira uma descrição (opcional) e click em `Create access key`

Faça o download do arquivo .csv com as credenciais de acesso dando um click em `Download .csv file`:

![Download Credentials](./imagens/download-credentials.png)
> OBSERVAÇÃO: As Access Keys acima foram criadas temporariamente e não existem mais.

### 4.2. Infra Básica - Provisionamento Automatizado

Antes de começar, utilizando um terminal, clone este repositório em sua máquina e mude para o diretório recém clonado com os comandos abaixo:

```bash
# Clonar o REPO
git clone git@github.com:fabiocore/5asor-arquitetura-microcontainers.git

# Mudar para o diretório recém clonado
cd 5asor-arquitetura-microcontainers

# Criar um diretorio de trabalho e outputs chamado live
# Diretório está incluso no arquivo .gitignore
mkdir live # Se Linux ou Mac
md live # Se Windows PowerShell
```

Agora vamos provisionar os seguintes items de infraestrutura básica:

- VPC, network, subnet, route table, security group e internet gateway.
- Instância EC2 que irá suportar o ambiente (t3a.xlarge -4vCPU -16GB RAM -30GB disco)

> Antes de aplicar os comandos abaixo, certifique-se que você está com as variáveis de ambiente (AWS_ACCESS_KEY_ID e AWS_SECRET_ACCESS_KEY) configuradas ou tenha um perfil do aws cli configurado, pois conforme já citado, isto não faz parte do tutorial.

```bash
# Mudar para o diretório terraform
cd terraform

# Plan & Apply da infra
terraform plan && terraform apply --auto-approve
```

Se tudo correu bem, você deve ter recebido uma mensagem de output parecida com esta abaixo:

```bash
Outputs:

instance_public_ip = "18.221.9.27"
ssh_command = "ssh -i '../live/5asor-wordpress-k3s-key.pem' ubuntu@18.221.9.27"
```

O comando acima serve para se conectar no novo servidor e irá funcionar apenas enquanto a instância está ligada ou reiniciada, se o servidor for completamente desligado, destruído e recriado o ip irá mudar. <br />

Note que o arquivo de certificado privado está localizado em "../live", um diretório que está incluso no .gitignore do repositório. <br />

Utilize o comando gerado no output (ssh_command) para se conectar ao seu novo servidor ou se você já está conectado a um servidor existente, vamos começar!

### 4.3 Instalando o K3S

O K3s é uma distribuição leve do Kubernetes, projetada para ambientes com poucos recursos, como IoT, edge computing e desenvolvimento local. Ele simplifica a implantação e o gerenciamento de clusters Kubernetes, mantendo a compatibilidade com o ecossistema.

Para instalar o K3S, execute a linha de comando abaixo:

```bash
curl -sfL https://get.k3s.io | sh -s - --write-kubeconfig-mode 644
```

Teste para ver se está funcionando:

```bash
kubectl get nodes
```
Se tudo estiver correto você deve ver um output parecido com o abaixo:

```txt
ubuntu@ip-192-168-5-12:~$ kubectl get nodes
NAME              STATUS   ROLES                  AGE   VERSION
ip-192-168-5-12   Ready    control-plane,master   19s   v1.32.3+k3s1
```

### 4.4 Deploy do WordPress e Banco de Dados

A instalação do WordPress e banco de dados está automatizada através de um script de deploy neste repositório (deploy/deploy.sh) e um arquivo values.yaml(deploy/values.yaml) utilizando helm. <br />

Faça o deploy automatizado através do script executando o comando abaixo: <br />

```bash
curl -sfL https://raw.githubusercontent.com/fabiocore/5asor-arquitetura-microcontainers/main/deploy/deploy.sh | bash
```

Se tudo rodou direitinho você deve ver um output mais ou menos assim:

```txt
============================================
       Deploy concluído com sucesso
============================================

O WordPress e o banco foram implantados com sucesso no cluster K3s.

Aguarde alguns instantes até que todos os pods estejam em execução.

Para validar a resiliência da solução, você pode executar o comando:
   kubectl delete pod <nome-do-pod>

============================================
       Acessando o Blog WordPress
============================================

Acesse o WordPress diretamente pelo IP público da instância EC2:
>>>>> http://3.16.75.228 <<<<<

Acesse a página de administração do WordPress:
>>>>> http://3.16.75.228/wp-admin <<<<<
username: admin5asor
password: pizza-pepperoni-marguerita
!!! Nem preciso dizer para mudar a senha logo agora, né? ;-)

Obs.: Se desejar usar um domínio real, aponte seu DNS para esse IP.

============================================
         Fim ;-) Vale um 10?
============================================
ubuntu@ip-192-168-5-10:~$
```

:bowtie: That's all! Thank you very much!

### 4.5 Destruir tudão via terraform

:feelsgood: Caso tenha feito deploy via terraform, para destruir tudão, execute o comando abaixo:

```bash
# Dentro do diretorio terraform do repositório, execute:
terraform destroy
```

fim.