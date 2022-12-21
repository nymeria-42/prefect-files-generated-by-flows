from prefect import flow, get_run_logger
import os

@flow
def my_docker_flow():
    logger = get_run_logger()
    logger.info("Hello from Docker!")
    os.makedirs("/files/test_flow", exist_ok=True)
    with open('/files/test_flow/test-file.txt', 'x') as f:
        f.write('Create a new text file!')
