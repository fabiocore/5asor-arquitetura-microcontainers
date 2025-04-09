#!/bin/bash


# Função para exibir mensagens de erro e sai do script
function error_exit {
  echo "Erro: $1"
  exit 1
}

# Garante que o kubectl e o helm encontrem o cluster K3s
if [ -z "$KUBECONFIG" ] && [ -f /etc/rancher/k3s/k3s.yaml ]; then
  export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
  echo "KUBECONFIG não definido. Usando /etc/rancher/k3s/k3s.yaml"
fi

echo "============================================"
echo "   Iniciando deploy do ambiente WordPress   "
echo "============================================"

# 1. Verificar pré-requisitos
echo "[1/5] Checando pré-requisitos..."

# Verifica se o kubectl está instalado
command -v kubectl >/dev/null 2>&1 || error_exit "kubectl não encontrado. Instale o K3s para obter o kubectl."

# Verifica se o cluster K3s está ativo
if ! kubectl get nodes >/dev/null 2>&1; then
  error_exit "Não foi possível acessar o cluster K3s. Verifique a instalação."
fi

# Verifica se o helm está instalado; se não, instala-o automaticamente
if ! command -v helm >/dev/null 2>&1; then
  echo "Helm não encontrado. Instalando Helm..."
  curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 || error_exit "Falha ao baixar script de instalação do Helm."
  chmod 700 get_helm.sh
  ./get_helm.sh || error_exit "Falha ao instalar Helm."
  rm get_helm.sh
fi

echo "Pré-requisitos OK."
sleep 1

# 2. Garantir que o arquivo deploy/values.yaml esteja presente
echo "[2/5] Verificando o arquivo values.yaml..."
if [ ! -f deploy/values.yaml ]; then
  echo "Arquivo deploy/values.yaml não encontrado, baixando..."
  mkdir -p deploy
  curl -sfL https://raw.githubusercontent.com/fabiocore/5asor-arquitetura-microcontainers/main/deploy/values.yaml -o deploy/values.yaml || error_exit "Falha ao baixar deploy/values.yaml."
else
  echo "Arquivo deploy/values.yaml encontrado."
fi
sleep 1

# 3. Configurar repositório Helm
echo "[3/5] Configurando repositório Helm..."
if ! helm repo list | grep -q "bitnami"; then
  echo "Adicionando repositório Bitnami..."
  helm repo add bitnami https://charts.bitnami.com/bitnami || error_exit "Falha ao adicionar o repositório Bitnami."
else
  echo "Repositório Bitnami já configurado."
fi

echo "Atualizando repositórios Helm..."
helm repo update || error_exit "Falha ao atualizar repositórios Helm."
sleep 1

# 4. Deploy do WordPress e MariaDB via Helm
echo "[4/5] Realizando o deploy do WordPress (com MariaDB) usando Helm..."
helm upgrade --install wordpress bitnami/wordpress --values deploy/values.yaml || error_exit "Falha no deploy via Helm."
sleep 1

# 5. Exibir status dos pods e instruções
echo "[5/5] Verificando o status dos pods..."
kubectl get pods -l app=wordpress

echo "============================================"
echo "       Deploy concluído com sucesso       "
echo "============================================"
echo ""
echo "O WordPress e o banco foram implantados com sucesso no cluster K3s."
echo ""
echo "Aguarde alguns instantes até que todos os pods estejam em execução."
echo ""
echo "Para validar a resiliência da solução, você pode executar o comando:"
echo "   kubectl delete pod <nome-do-pod>"
echo ""
echo "============================================"
echo "       Acessando o Blog WordPress           "
echo "============================================"
echo ""

# Verifica se há um recurso Ingress criado para o WordPress
WORDPRESS_HOST=$(kubectl get ingress wordpress -o jsonpath='{.spec.rules[0].host}' 2>/dev/null)

# Pega o IP público da instância EC2 via metadata
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

if [ -n "$WORDPRESS_HOST" ] && [[ "$WORDPRESS_HOST" != *"fiap.com"* ]]; then
  echo "Ingress encontrado! Use o hostname configurado:"
  echo "http://$WORDPRESS_HOST"
else
  if [ -n "$PUBLIC_IP" ]; then
    echo "Ingress está usando um hostname genérico ou não configurado corretamente."
    echo "Acesse o WordPress diretamente pelo IP público da instância EC2:"
    echo "http://$PUBLIC_IP"
    echo ""
    echo "Obs.: Se desejar usar um domínio real, aponte seu DNS para esse IP."
  else
    echo "Não foi possível obter o IP público da instância. Verifique a conectividade com o metadata service."
  fi
fi

echo ""
echo "============================================"
echo "         Fim ;-) Vale um 10?                "
echo "============================================"
