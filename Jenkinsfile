pipeline {
    agent { label 'vm-agent' }

    environment {
        LOCALSTACK_URL = 'http://192.168.49.1:4566'
        BUCKET_NAME    = 'terraform-localstack-bucket'
    }

    stages {

        stage('1 - Verificar LocalStack') {
            steps {
                sh '''
                    echo "🔍 Verificando LocalStack..."
                    HEALTH=$(curl -s http://localhost:4566/_localstack/health)
                    echo "$HEALTH"
                    if echo "$HEALTH" | grep -qE '"s3": "(available|running)"'; then
                        echo "✅ LocalStack OK"
                    else
                        echo "❌ LocalStack no disponible"
                        exit 1
                    fi
                '''
            }
        }

        stage('2 - Terraform Apply') {
            steps {
                dir('terraform') {
                    sh '''
                        terraform init
                        BUCKET="terraform-localstack-bucket"
                        if aws --endpoint-url=http://localhost:4566 \
                               --region us-east-1 \
                               s3api head-bucket --bucket $BUCKET 2>/dev/null; then
                            echo "⚠️ Bucket existe, importando..."
                            terraform import aws_s3_bucket.mi_bucket_local $BUCKET || true
                        fi
                        terraform apply -auto-approve -refresh=true
                    '''
                }
            }
        }

        stage('3 - Build Docker') {
            steps {
                sh '''
                    eval $(minikube docker-env)
                    docker build -t mi-app-s3:local ./app-localstack
                    echo "✅ Imagen construida"
                '''
            }
        }

        stage('4 - Deploy en Kubernetes') {
            steps {
                sh '''
                    kubectl apply -f app-localstack/deployment.yaml
                    kubectl rollout restart deployment/app-s3-deployment
                    kubectl rollout status deployment/app-s3-deployment --timeout=120s
                    echo "✅ Deploy completado"
                '''
            }
        }

        stage('5 - Verificar Deploy') {
            steps {
                sh '''
                    echo "📦 Pods:"
                    kubectl get pods -o wide
                    sleep 10
                    echo "📋 Logs:"
                    kubectl logs deployment/app-s3-deployment --tail=20
                    echo "🪣 Bucket S3:"
                    aws --endpoint-url=http://localhost:4566 \
                        --region us-east-1 \
                        s3 ls s3://terraform-localstack-bucket
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline completado con éxito'
        }
        failure {
            echo '❌ Pipeline fallido'
        }
    }
}
