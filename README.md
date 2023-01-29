# Music App

This app allow you to stream music with a graphical interface.

## Members 

Elena Kržina
Marin Bogešić
Lara Tičić
Emilien JACQUES

## Warning

The purpose of the application is educational. Please do not use in production due to low security.

## How to run

In order to properly run the application, you need to exectue some commands in a specific order.

### Setup docker

1. In the first place, you will need to install [docker](https://docs.docker.com/compose/install/).
2. Then, run the containers using `docker compose -f dev.docker-compose.yml up` - You can add the option `-d` if you want to run the command in the background.

### Setup postgres

To be able to store and serve data, we will use postgres database.

1. Install postgresql service, this step depends on your OS but you can find information on https://www.postgresql.org/download/.
2. Once you've started the service, try to enter the psql context using `sudo psql -U postgres -h localhost`. If you achieve to enter, that mean it's working.
3. When you've check that everything was fine with the database, you can use the command `psql -U postgres -h localhost -f pgsql/psql_dump.sql` and enter the password. This will setup the database according to the application and populate it.

### Run the backend

0. If node isn't installed on your machine, please do using the [official downloading page](https://nodejs.org/en/download/).
1. Go into the `server` directory.
2. Add a `.env` file containing the following data and replace the content between `<` and `>` to fit your environement.

```
# Following database variable works for basic configuration, please change if you use another configuration.

DB_USER=postgres    # User of the database
DB_PASSWD=postgres  # Password of the user above
DB_NAME=postgres    # Database name where to find our data
DB_HOST=localhost   # Ip address (or localhost) to find the postgres database
DB_PORT=5432        # Port of the service that host database.

JWT_SECRET=<SOME_RANDOM_CHARS>   # Secrets for the JWT auth.

AUDIO_FILE_DIRPATH=<ABSOLUTE_PATH_TO_AUDIO_DIR> # Path to the audio file directory

KAFKA_CLIENT_ID=nestjs
KAFKA_URIS=localhost:29092  # Multiple brokers with , (no space). In specified configuration in docker, should put localhost:29092
```

3. Unpack the `music_file.zip` archive and put the mp3 files that it contains into the `AUDIO_FILE_DIRPATH` directory that you specify earlier in the `.env` file.
4. Install the dependecies by running `npm i`.
5. Run the app `npm run start`.

### Access the app

Once the final message have been displayed by nestjs, please connect to `http://localhost:3000` using your browser. You should be able to see the first page and some data should have been loaded.

#### Testing authentification features

One user is already in the system and you can login as him. To do so, you need to use the following credentials

```
email:      test2@example.org
password:   1234
```

#### Testing audio

You can now test the audio streaming feature pressing the play button on the music hit section on the home page.

#### Testing variable streaming

After openning two browser and put them side by side. Go to the same music page and play the music on one of them. You should see the views count go up on both of them.

## Troubleshooting

### No audio is playing

Please check that the value of the file columns of the Music table match the actual path to the music files. If not replace the content of the file columns with the actual content. To do so, in the psql context, you can use `UPDATE Music SET file=<actual_file_path> WHERE file=<current_file_path>;` for each one of the audio file. Once done, you can retry to play the audio. Make sure to restart the nestjs application to be sure that no value have been cached.

### Nestjs application cannot connect to kafka broker

Most of the time, this is caused by an error in the configuration or due to a issue with the timelime of the event. Please check that the `.env` file is correct, expecially for the `KAFKA_URIS` attribute. Be sure to start the server **after** the docker have finish its initialisation.

### 404 error when trying to connect to http://localhost:3000

This may be cause by the miss of the frontend generated files in the assets directory of the server application. To fix it please follow the instructions below.

1. Go into the frontend directory.
2. Generate the frontend static files by running `npm run build -- --output-path ../server/assets`.