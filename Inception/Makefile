NAME	=	Inception

all:	$(NAME)

$(NAME):
	docker-compose -f srcs/docker-compose.yml build
	docker-compose -f srcs/docker-compose.yml up

clean:
	docker system prune -af

re:
	docker-compose -f srcs/docker-compose.yml down
	docker-compose -f srcs/docker-compose.yml build
	docker-compose -f srcs/docker-compose.yml up
