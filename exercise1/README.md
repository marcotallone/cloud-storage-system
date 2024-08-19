# Exercise 1: Cloud-Based File Storage System

> Cloud Basic

This file contains practical instructions to set-up and run the cloud-based file storage system built with docker compose and [Nextcloud](https://nextcloud.com/). Moreover, following the instructions below, the system has been tested using [locust](https://locust.io/) to simulate user interactions.\
All the required files are contained in this directory, which is organized in
the following way:

```bash
📁 .
├── 📄 .env # Environment variables
├── 📄 docker-compose.yaml # Docker compose file
├── 📜 README.md # This file
├── 📁 results # Results of the locust test
├── 📁 scripts # Scripts to interact with the system
│  ├── add_users.sh
│  ├── clean_files.sh
│  ├── get_files.sh
│  ├── init.sh
│  ├── remove_users.sh
│  ├── 📄 testfile.txt
│  └── upload.sh
├── 📁 test # Locust test files
│  └── 🐍 locustfile.py
└── 📁 web # Configuration files for proxy servers
   ├── 📄 Caddyfile
   └── ⚙ nginx.conf
```

## Requirements

The following software is required to run the cloud-based file storage system:

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/)
- [Locust](https://docs.locust.io/en/stable/installation.html)

## Installation

The installation phase is simplified thanks to Docker Compose. To install the
system, it's sufficient to run the following command:

```bash
docker-compose up -d
```

This command will download the required images and start the services. The
system is composed of the following docker images:

| Image     | Version       |
|-----------|---------------|
| Nextcloud | 27.1-fmp      |
| Postgres  | 16.3-alpine   |
| Redis     | 7.2.5-alpine  |
| Nginx     | 1.27.0-alpine |
| Caddy     | 2.8.4-alpine  |

More details can be found in the report file provided in this repository.\
Once the system is up and running, it's possible to access the Nextcloud
interface by visiting the following URL:

> <https://localhost>

The default admnistrator credentials are:

- Username: admin
- Password: 123456

But they can eventually be changes by modifying the associated environment
variables in the `.env` file.

>[!WARNING]
>Depending on the web browser used, a warning message might be shown when accessing the Nextcloud interface. This is due to the self-signed SSL certificate managed by the Caddy server.

To stop the system, the following command can be used:

```bash
docker-compose down
```

Recall that this does not delete the pulled images nor the associated persistent
volumes, but such taks can be achieved through docker commands.

## Testing

It's possible to test the deployed service capabilities using the locust tool. To
conduct the test it's necessary to follow these steps.\
First of all, it's necessary to generate some files to test the upload and
download capabilities of the system. The provided `get_files.sh` script can be
run to generate files of different sizes (*respectively 1 kB, 1 MB and 1 GB*). In particular by running:

```bash
./scripts/get_files.sh
```

from this directory, the relative files will be created in the `test/uploads`
and `test/downloads` folders.

>[!NOTE]
>It's possible to test the system with files bigger than 1 GB, but this requires to adjust the `client_max_body_size` parameter accordingly in the `nginx.conf` file.

Then the system must be populated with users. For this task, first make sure
that the docker containers are up and running with `docker ps` and then it's possible to
run:

```bash
./scripts/init.sh
```

again from this folder. This will add by default 50 users in the nextcloud
instance and upload for each of them a test file. The default number of users
can be tweaked by changing the associated variable at the beginning of the script.\
It's then possible to conduct the test by running:

```bash
cd test
python locustfile.py
```

and then visiting the provided URL, by default:

> <http://localhost:8089>

>[!WARNING] 
>Remember to enter the test directory before running the locust test.
