#!/usr/bin/env python3

from argparse import ArgumentParser
from json import loads
from socket import gethostname
from os import environ, chdir, getcwd
from pathlib import Path
from os.path import exists
from subprocess import PIPE, run, DEVNULL, Popen
import logging
from logging import getLogger, INFO
from functools import cache
import yaml
from sys import stdout

logger = getLogger("enter-overlay")
logger.setLevel(INFO)
logger.addHandler(logging.StreamHandler(stdout))

environ["HOSTNAME"] = gethostname()
environ["FT_COLCON_HOME"] = environ.get("FT_COLCON_HOME", f"{environ['HOME']}/ft")
environ["FT_CATKIN_HOME"] = environ.get("FT_CATKIN_HOME", f"{environ['HOME']}/catkin_ft")

def get_docker_executable():
    if run(["which", "podman"], stderr=DEVNULL, stdout=DEVNULL).returncode == 0:
        return "podman"
    else:
        return "docker"

@cache
def get_docker_socket():
    if get_docker_executable() == "docker":
        return "/var/run/docker.sock"
    else:
        return "/run/user/1000/podman/podman.sock"

def ensure_docker_x11_cookie():
    if exists("/tmp/docker/cookie"):
        logger.info("😇 X11 cookie for docker already exists 🍪")
    else:
        nlist_output = run(["xauth", "nlist", environ["DISPLAY"]], stdout=PIPE).stdout.decode()
        if len(nlist_output) == 0:
            logger.info("Cant make docker cookie as 'xauth nlist $DISPLAY' returned nothing 😨")
        else:
            Path("/tmp/docker/cookie").unlink(missing_ok=True)
            Path("/tmp/docker").mkdir(exist_ok=True)
            Path("/tmp/docker/cookie").touch(exist_ok=True)
            process = Popen(["xauth", "-f", "/tmp/docker/cookie", "nmerge", "-"], stdin=PIPE)
            logger.info(f"Dumping '{nlist_output}'")
            process.communicate(('ffff' + nlist_output[4:]).encode())
            logger.info("💖 done 👼")

def get_image_for_service(service):
    with open("docker-compose.yml") as docker_compose_file:
        services = yaml.unsafe_load(docker_compose_file)
    try:
        return services["services"][service]["image"]
    except KeyError:
        logger.error(f"Service '{service}' does not exist")
        exit(1)
    
def get_container_of_image(image):
    resolved_image_id = loads(run([get_docker_executable(), "image", "inspect", image], stdout=PIPE).stdout)[0]["Id"]
    containers = loads(run(["curl", "--silent", "--unix-socket", get_docker_socket(), "http://localhost/v1.24/containers/json"], stdout=PIPE).stdout)
    for container in containers:
        if resolved_image_id in container["ImageID"]:
            return container

def main():
    parser = ArgumentParser()
    parser.add_argument("args", nargs='+', type=str)
    parser.add_argument("--root", action="store_const", const=True, dest="root", default=False)
    parser.add_argument("--shell", type=str, default="bash")
    parser.add_argument("--workdir", type=str)
    parser.add_argument("--jobless", action="store_const", const=True, dest="jobless", default=False)
    parser.add_argument("--raw", action="store_const", const=True, dest="raw")
    parser.add_argument("--fresh", action="store_const", const=True, dest="fresh")
    args = parser.parse_args()

    original_directory = getcwd()
    
    ensure_docker_x11_cookie()
    
    service, *tail = args.args
    image = get_image_for_service(service)

    if args.raw:
        run([get_docker_executable(), "compose", "run", service])
        return

    logger.warning(f"Using image '{image}'")

    if args.fresh:
        logger.info("Fresh option chosen. killing existing containers... 😳")
        while container := get_container_of_image(image):
            logger.info(f"killing container {container['Id']} 🩸🍴")
            run([get_docker_executable(), "kill", container["Id"]])
    
    container = get_container_of_image(image)

    if container is None:
        logger.info(f"No container exists with image {image}. Creating a new one")
        run([get_docker_executable(), "compose", "up", "-d", service], check=True)
        container = get_container_of_image(image)
    else:
        logger.info(f"Container for '{service}' exists. Launching another shell within it...")

    run([
        get_docker_executable(),
         "exec",
         "-it",
         *(["--workdir", original_directory if args.workdir is None else args.workdir] if not args.jobless else []), 
         *(["-u", "root"] if args.root else ["-u", "1000"]),
         container["Id"],
         *(tail if len(tail) > 0 else [args.shell])
    ])

if __name__ == "__main__":
    main()
