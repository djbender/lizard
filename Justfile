image := "lizard"

build:
    docker build -t {{image}} .

run key:
    docker run -d -p 80:80 -e RAILS_MASTER_KEY={{key}} --name {{image}} {{image}}
