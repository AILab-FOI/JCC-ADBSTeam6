# Music App

This app allow you to stream music with a graphical interface.

## Warning

The purpose of the application is educational. Please do not use in production due to low security.

## How to run

In the first place, you will need to install [docker](https://docs.docker.com/compose/install/). Local PostgreSQL will also need to be installed.
Afterwards, it's neccessary to run sudo docker compose -f on the dev.docker-compose.yml file whilst setting up POSTGRES passwords. Then Postgres is opened with the postgres user and the audiot6pg.sql is given as an argument so that the base is built. Next, enter the server file and type npm i, then npm start run. The application should run on localhost://9092.
