
# 🚀 Java K8s Helm Deployment — Guia Completo com Kind + ArgoCD

Este guia documenta o passo a passo completo para criar um cluster **Kind**, configurar o **NGINX Ingress Controller**, instalar o **ArgoCD**, e fazer o deploy da aplicação **Java Spring Boot** utilizando um **Helm Chart**.

A configuração foi validada para rodar **100% localmente**, replicando o mesmo comportamento funcional dos manifests YAML (sem Helm).

---

## 🧱 1. Pré-requisitos

Antes de iniciar, verifique se as ferramentas abaixo estão instaladas no ambiente local:

| Ferramenta | Versão recomendada | Link de instalação |
|-------------|--------------------|--------------------|
| **kubectl** | 1.30+ | https://kubernetes.io/docs/tasks/tools/ |
| **kind** | 0.23+ | https://kind.sigs.k8s.io/ |
| **helm** | 3.14+ | https://helm.sh/docs/intro/install/ |
| **argocd** (CLI, opcional) | 2.12+ | https://argo-cd.readthedocs.io/en/stable/getting_started/ |

> 💡 *No Windows, execute todos os comandos em Git Bash ou PowerShell.*

---

## ☸️ 2. Criar Cluster Kind

```bash
kind create cluster --name cluster11
kubectl cluster-info --context kind-cluster11
```

> 🔹 Caso queira usar um arquivo de configuração customizado, use:  
> `kind create cluster --name cluster11 --config ./kind-config.yaml`

---

## 🌐 3. Instalar NGINX Ingress Controller

```bash
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx   --namespace ingress-nginx   --create-namespace
```

Verifique a instalação:
```bash
kubectl get pods -n ingress-nginx
kubectl get svc -n ingress-nginx
```

---

## 🔄 4. Instalar Argo CD

```bash
kubectl create namespace argocd
kubectl apply -n argocd   -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
```

Verifique:
```bash
kubectl -n argocd get pods
kubectl rollout status deployment/argocd-server -n argocd
```

Obtenha a senha do admin:
```bash
kubectl -n argocd get secret argocd-initial-admin-secret   -o jsonpath="{.data.password}" | base64 -d; echo
```

Acesse a UI:
```bash
kubectl port-forward svc/argocd-server -n argocd 8081:443
# URL: https://localhost:8081
# Usuário: admin
# Senha: <obtida acima>
```

---

## 🗝️ 5. Criar Namespace da Aplicação e Secret (GHCR)

```bash
kubectl create namespace java-k8s

kubectl create secret docker-registry ghcr-secret   --docker-server=ghcr.io   --docker-username="<GHCR_USER>"   --docker-password="<GHCR_TOKEN>"   --docker-email="<EMAIL>"   -n java-k8s

```

---

## 🌍 6. Ajustar o Ingress Controller para NodePort

```bash
kubectl patch svc ingress-nginx-controller -n ingress-nginx   -p '{"spec": {"type": "NodePort"}}'
kubectl get svc -n ingress-nginx
```

---

## ⚙️ 7. Instalar a Aplicação via Helm Chart

```bash
cd  ~/Desktop/development/repos/java-k8s-helm-charts

helm install java-k8s-app ./charts/java-k8s-app-chart -n java-k8s   --create-namespace   --wait
```

Verifique:
```bash
kubectl get all -n java-k8s
kubectl get ingress -n java-k8s
```
   
---

## 🏠 8. Configurar o Host Local

**Windows:**
```
C:\Windows\System32\drivers\etc\hosts
```
Adicionar:
```
127.0.0.1 java-k8s.local
```

## exponha manualmente o INGRESS:
```bash
kubectl port-forward -n ingress-nginx service/ingress-nginx-controller 30351:80
```


Depois:
```bash
curl -v http://localhost:30351 -H "Host: java-k8s.local"
```

---

## 🔍 9. Testar o Acesso

```bash
kubectl get svc -n ingress-nginx
curl -v http://localhost:<NODEPORT> -H "Host: java-k8s.local"
```

---

## 🧩 10. Deploy via ArgoCD (Helm Chart GitOps)

```bash
kubectl apply -f argocd-application.yaml -n argocd
```

Ou via CLI:
```bash
argocd app create java-k8s-app   --repo https://github.com/<SEU_USUARIO>/java-k8s-manifests.git   --path charts/java-k8s-app-chart   --dest-server https://kubernetes.default.svc   --dest-namespace java-k8s   --project default   --helm-release-name java-k8s-app   --sync-policy automated
```

---

## 🩺 11. Troubleshooting

| Problema | Solução |
|-----------|----------|
| `EXTERNAL-IP <pending>` | Alterar o Service para `NodePort` |
| `Connection refused` | Verifique se a porta NodePort está aberta |
| Pods não aparecem no ArgoCD | Verifique `namespace` e permissões |
| Imagem não puxa | Recrie o secret GHCR |

---

## 🧹 12. Rollback / Limpeza

```bash
argocd app delete java-k8s-app --cascade
helm uninstall java-k8s-app -n java-k8s
kubectl delete ns java-k8s
helm uninstall ingress-nginx -n ingress-nginx
kubectl delete ns ingress-nginx
kind delete cluster --name cluster11
```

---

## 📚 Referências

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [ArgoCD Docs](https://argo-cd.readthedocs.io/en/stable/)
- [Helm Docs](https://helm.sh/docs/)
- [NGINX Ingress Controller](https://kubernetes.github.io/ingress-nginx/)

---

**Autor:** Rodrigo Nascimento  
**Data:** Outubro/2025  
**Projeto:** Java K8s Manifests + Helm + ArgoCD

