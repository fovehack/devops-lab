#!/bin/bash
# ══════════════════════════════════════════════════════════════
# practica.sh - Script interactivo para el laboratorio K8s
# Uso: ./practica.sh [modulo]
# Ejemplo: ./practica.sh 01   → despliega y practica pods
# ══════════════════════════════════════════════════════════════

MODULO=$1

limpiar_modulo() {
  echo "🧹 Limpiando recursos del módulo $1..."
  kubectl delete -f "$1"/ --ignore-not-found=true 2>/dev/null
  echo "✅ Limpieza completada"
}

esperar_pods() {
  echo "⏳ Esperando que los pods estén Ready..."
  sleep 3
  kubectl get pods -l "modulo=$1" 2>/dev/null || kubectl get pods
}

case $MODULO in
  "01"|"pods")
    echo "══════════════════════════════════"
    echo " MÓDULO 01 - PODS"
    echo "══════════════════════════════════"
    kubectl apply -f 01-pods/01-pod-basico.yaml
    esperar_pods "01-pods"
    echo ""
    echo "📋 Comandos para practicar:"
    echo "  kubectl get pods"
    echo "  kubectl describe pod mi-primer-pod"
    echo "  kubectl logs mi-primer-pod"
    echo "  kubectl exec -it mi-primer-pod -- /bin/sh"
    echo "  kubectl delete pod mi-primer-pod"
    echo ""
    read -p "¿Aplicar pod multi-contenedor? (s/n): " resp
    [ "$resp" = "s" ] && kubectl apply -f 01-pods/02-pod-multicontenedor.yaml
    read -p "¿Aplicar pod init-container? (s/n): " resp
    [ "$resp" = "s" ] && kubectl apply -f 01-pods/03-pod-init-container.yaml
    ;;

  "02"|"deployments")
    echo "══════════════════════════════════"
    echo " MÓDULO 02 - DEPLOYMENTS"
    echo "══════════════════════════════════"
    kubectl apply -f 02-deployments/01-deployment-basico.yaml
    esperar_pods "02-deployments"
    echo ""
    echo "📋 Comandos para practicar:"
    echo "  kubectl get deployments"
    echo "  kubectl get pods -l app=mi-app"
    echo "  kubectl get replicasets"
    echo "  kubectl scale deployment deployment-basico --replicas=5"
    echo "  kubectl set image deployment/deployment-basico nginx=nginx:1.25"
    echo "  kubectl rollout status deployment/deployment-basico"
    echo "  kubectl rollout history deployment/deployment-basico"
    echo "  kubectl rollout undo deployment/deployment-basico"
    ;;

  "04"|"services")
    echo "══════════════════════════════════"
    echo " MÓDULO 04 - SERVICES"
    echo "══════════════════════════════════"
    kubectl apply -f 04-services/01-clusterip.yaml
    kubectl apply -f 04-services/02-nodeport.yaml
    echo ""
    echo "📋 Comandos para practicar:"
    echo "  kubectl get svc"
    echo "  kubectl describe svc svc-clusterip"
    echo "  minikube service svc-nodeport --url"
    echo "  kubectl run test-curl --image=curlimages/curl --rm -it --restart=Never -- curl svc-clusterip"
    ;;

  "07"|"probes")
    echo "══════════════════════════════════"
    echo " MÓDULO 07 - PROBES"
    echo "══════════════════════════════════"
    kubectl apply -f 07-probes/01-probes.yaml
    echo ""
    echo "📋 Observa en tiempo real (abre otra terminal):"
    echo "  kubectl get pods -w"
    echo "  kubectl describe pod pod-probe-command"
    echo "  kubectl get events --sort-by='.lastTimestamp'"
    ;;

  "09"|"storage")
    echo "══════════════════════════════════"
    echo " MÓDULO 09 - STORAGE"
    echo "══════════════════════════════════"
    kubectl apply -f 09-storage/01-storage.yaml
    echo ""
    echo "📋 Comandos para practicar:"
    echo "  kubectl get pv"
    echo "  kubectl get pvc"
    echo "  kubectl describe pvc pvc-demo"
    ;;

  "10"|"ingress")
    echo "══════════════════════════════════"
    echo " MÓDULO 10 - INGRESS"
    echo "══════════════════════════════════"
    echo "⚠️  Habilitando ingress addon..."
    minikube addons enable ingress
    echo "⏳ Esperando ingress controller (puede tardar 1-2 min)..."
    kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=120s
    kubectl apply -f 10-ingress/01-ingress.yaml
    MINIKUBE_IP=$(minikube ip)
    echo ""
    echo "📋 Añade esto a /etc/hosts:"
    echo "  echo '$MINIKUBE_IP devops-lab.local' | sudo tee -a /etc/hosts"
    echo ""
    echo "  Luego prueba:"
    echo "  curl http://devops-lab.local/productos"
    echo "  curl http://devops-lab.local/usuarios"
    ;;

  "clean"|"limpiar")
    echo "🧹 Limpiando TODOS los recursos del laboratorio..."
    for dir in 0*/; do
      kubectl delete -f "$dir" --ignore-not-found=true 2>/dev/null
    done
    kubectl delete namespace desarrollo produccion --ignore-not-found=true
    echo "✅ Todo limpio"
    ;;

  *)
    echo "══════════════════════════════════════════════"
    echo " Laboratorio Kubernetes - Menú de módulos"
    echo "══════════════════════════════════════════════"
    echo ""
    echo "Uso: ./practica.sh <modulo>"
    echo ""
    echo "  01 | pods         → Pods básicos, multi-contenedor, init"
    echo "  02 | deployments  → Deployments, rolling update, rollback"
    echo "  03 | replicasets  → ReplicaSets y auto-recuperación"
    echo "  04 | services     → ClusterIP y NodePort"
    echo "  05 | configmaps   → ConfigMaps como env y archivos"
    echo "  06 | secrets      → Secrets seguros"
    echo "  07 | probes       → Liveness, Readiness, Startup"
    echo "  08 | resources    → Limits, Requests, Quotas"
    echo "  09 | storage      → Volumes, PV, PVC"
    echo "  10 | ingress      → Ingress con Nginx"
    echo "  11 | namespaces   → Namespaces y aislamiento"
    echo "  12 | nodes        → NodeSelector, Affinity, Taints"
    echo ""
    echo "  clean | limpiar   → Borra todos los recursos"
    echo ""
    echo "Estado actual del clúster:"
    kubectl get nodes
    echo ""
    kubectl get pods -A | grep -v "kube-system\|datadog"
    ;;
esac
