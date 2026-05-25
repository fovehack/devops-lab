# Laboratorio Kubernetes - Práctica Completa

## Orden de práctica recomendado

| Módulo | Concepto | Carpeta |
|--------|----------|---------|
| 01 | Pods básicos | 01-pods/ |
| 02 | Deployments | 02-deployments/ |
| 03 | ReplicaSets | 03-replicasets/ |
| 04 | Services (ClusterIP, NodePort) | 04-services/ |
| 05 | ConfigMaps | 05-configmaps/ |
| 06 | Secrets | 06-secrets/ |
| 07 | Probes (Liveness, Readiness, Startup) | 07-probes/ |
| 08 | Resources (limits, requests) | 08-resources/ |
| 09 | Storage (Volumes, PV, PVC) | 09-storage/ |
| 10 | Ingress + Nginx | 10-ingress/ |
| 11 | Namespaces | 11-namespaces/ |
| 12 | Nodes y scheduling | 12-nodes/ |

## Comandos útiles generales

```bash
# Ver todo en un namespace
kubectl get all -n <namespace>

# Describir cualquier recurso
kubectl describe <tipo> <nombre>

# Ver logs
kubectl logs <pod> -f

# Entrar a un pod
kubectl exec -it <pod> -- /bin/sh

# Borrar todo de un archivo
kubectl delete -f <archivo.yaml>

# Ver eventos del clúster
kubectl get events --sort-by='.lastTimestamp'
```
