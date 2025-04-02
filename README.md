# Fiap - 5ASOR - Arquitetura Microcontainers - Prof. Leandro


Repositório do trabalho de conclusão de disciplina Fiap.

## Descrição da Atividade

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

## Membros do Time

- Anderson Luis Lins Rocha
- Augusto Oening Costa
- Carlos Correa
- Fabio Ferreira da Silva
- Giliane Maciel do Vale
- Michael Andre Santos Brito



