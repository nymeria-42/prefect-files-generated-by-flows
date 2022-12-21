from test_flow import my_docker_flow

from prefect.deployments import Deployment
from prefect.filesystems import LocalFileSystem
from prefect.infrastructure import DockerContainer

block = LocalFileSystem(
    basepath="/prefect_files"
)
block.save("flowfiles", overwrite=True)


deployment = Deployment.build_from_flow(
    name="docker-example",
    flow=my_docker_flow,
    storage=LocalFileSystem.load('flowfiles')
)

deployment.apply()