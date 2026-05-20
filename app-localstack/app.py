import boto3
import os
import time

# LocalStack suele ser accesible desde dentro del clúster usando la IP de la máquina host 
# o el DNS si están en la misma red. Para que sea flexible, usaremos una variable de entorno.
LOCALSTACK_URL = os.environ.get("LOCALSTACK_URL", "http://localhost:4566")
BUCKET_NAME = "terraform-localstack-bucket"

print(f"Conectando a LocalStack en el endpoint: {LOCALSTACK_URL}...")

# Inicializamos el cliente de S3 con credenciales ficticias y el endpoint apuntado a LocalStack
s3 = boto3.client(
    "s3",
    endpoint_url=LOCALSTACK_URL,
    aws_access_key_id="mock_access_key",
    aws_secret_access_key="mock_secret_key",
    region_name="us-east-1"
)

def main():
    # Creamos un archivo de prueba local
    filename = "test_k8s.txt"
    with open(filename, "w") as f:
        f.write("¡Hola desde el pod de Kubernetes corriendo en Minikube!")

    print(f"Subiendo {filename} al bucket {BUCKET_NAME}...")
    
    try:
        s3.upload_file(filename, BUCKET_NAME, filename)
        print("¡Archivo subido con éxito!")
        
        # Listamos el contenido para verificar
        response = s3.list_objects_v2(Bucket=BUCKET_NAME)
        print("Archivos actuales en el bucket:")
        for obj in response.get("Contents", []):
            print(f" - {obj['Key']}")
            
    except Exception as e:
        print(f"Error al interactuar con LocalStack: {e}")

    # Mantenemos el pod vivo para poder revisar los logs con calma
    print("Proceso terminado. Durmiendo...")
    while True:
        time.sleep(3600)

if __name__ == "__main__":
    main()