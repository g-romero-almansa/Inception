Guideo for Inception

Connect with ssh through port 4343 as the subject request.

    ssh gromero-@localhost -p 4343

Makefile with just a few rules to set up all containers, delete all containers images and networks and to put down and then up all containers.

    docker-compose -f srcs/docker-compose.yml build
    docker-compose -f srcs/docker-compose.yml up
    docker-compose -f srcs/docker-compose.yml down
    docker system prune -af
    With build you force a rebuild for the images (-f path to docker-compose that is not in the directory)
    With up you start the and set up the containers
    With down you remove the containers and networks
    With prune you delete all images, containers and networks(-a remove unused images too, -f do not prompt confirmation)
    
Docker-Compose.yml, with this file we can run all containers at the same time and connect all together

    Version(Not supported for new versions, so doesn't matter what you put)
    Services(Declaring the services/containers, example mariadb:)
    Build(Path to dockerfile where is the configuration for the service)
    Env_file(Adds environment variables to the container based on your file)
    Container_name(Set the containers name instead of default name)
    Restart(Define what to do when container end, unless-stopped indicates it always restart no matter what exit code has but stop when the service is removed or stopped)
    Ports(Expose ports, the first one is the host port exposed and the second its the container port)
    Expose(Exposes ports but only to the other services not the host machine)
    Depends_on(Set the start and shutdown dependencies and order, example here wordpress depend on mariadb and nginx on wordpress so the order its mariadb-wordpress-nginx)
    Networks(Define the name of the network and driver on bridge mode means that the services on that network can communicate and are isolates from the other outside the network)
    Volumes(Define the name of the volume, with driver local you mean the volume info will be store locally, driver opts type and o are set to default and the important its device option wich indicates the path to store info)
