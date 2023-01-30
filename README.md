Recursos utilizados:
- prefect orion
- prefect agent
- postgres -> BD usado pelo server do prefect
- minio -> simula repositório remoto s3 da AWS

Etapas:
1. `make docker` para construir imagem do server prefect orion
   1. Utiliza o arquivo `Dockerfile`
2. `make docker-agent` para construir imagem do prefect agent
   1. Utiliza o arquivo `Dockerfile-agent`
   2. Nele podem ser instalados os requisitos, copiando o `requirements.txt` para o container
3. `podman-compose up orion minio` para subir container do servidor e do minio
4. Acessar `http://<IP>:9000`. Entrar com `minioadmin` como usuário e senha.
   1. Criar um bucket chamado `prefect-flows` para armazenar os workflows
   2. Clicar em **Access Keys**  para criar chaves de acesso
   3. Copiar chave e segredo
   4. Acessar `http://<IP>:42000`
   5. Clicar em **Blocks**, e adicionar um bloco de **Remote File System**. Dar um nome a ele e lembrar que esse nome é usado na hora de criar um deployment
   6. No campo **Basepath**, colocar `s3://prefect-flows`
   7. O campo de **Settings** deve seguir a estrutura:
      ```
      {
      "key": "CHAVE",
      "secret": "SEGREDO",
      "client_kwargs": {
         "endpoint_url": "http://minio:9000"
      }
      }
      ```
5. `podman-compose up agent` para subir o agente que cuida das queues 
   1. No docker-compose é possível alterar o nome da queue no entrypoint
6. `podman-compose run cli` para gerar o deployment
   1. Navegar até o diretório do workflow
   2. Rodar `python workflow.py`. Esse código deve conter uma estrutura parecida com:
      ```
      if __name__ == "__main__":
         ...
         remote_file_system_block = RemoteFileSystem.load("block-name")
         deployment = Deployment.build_from_flow(flow=flow_name, name=deployment_name, work_queue_name=queue_name, parameters={"param1": value1}, storage=remote_file_system_block)
         deployment.apply()
      ```
7. Acessar `http://<IP>:42000` e verificar o deployment
   1. Pode-se então rodar, agendar e configurar os deployments gerados

Estrutura:
- flows: pasta contendo códigos dos workflows
- files: pasta onde são salvos os arquivos gerados pelos workflows.
  - Importante que nos códigos os arquivos estejam sendo salvos no diretório `/files`
  
OBS:
- É possível modificar a imagem do agente (**Dockerfile-agent**) para que o código rode com todos os requisitos instalados
  - Ela é usada tanto no agent como no cli usado para gerar os deployments
- Para códigos que utilizam virtual_env com python 2, para rodar deve-se instalar o python 2 no container do agente e criar também nele um venv para a aplicação. Para isso, inserir no **docker-compose.yaml**, ou criar no **Dockerfile** do agente um venv e instalar os requisitos.
   - No docker-compose.yaml:
  ```
   command: bash -c "apt-get install -y python2.7 && pip install prefect_shell && virtualenv venv --python=2.7 && prefect agent start -q default"
  ```
   - No Dockerfile:
     ```RUN virtualenv venv --python=2.7 && venv/bin/activate && pip install -r requirements.txt```
   - O código python do flow deve seguir a seguinte estrutura para rodar a aplicação:
   ```
   @flow
   def example_shell_loop():
      cmd = "python arquivo.py"
      shell_run_command(command=cmd, return_all=True, helper_command = ". /opt/prefect/venv/bin/activate")
   ```

Mais infos: https://github.com/rpeden/prefect-docker-compose