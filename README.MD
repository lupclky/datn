
## MySql, PHPAdmin

- Install Docker Desktop and Docker compose

```
docker compose -f ./deployment.yaml up -d mysql8-container
docker compose -f ./deployment.yaml up -d phpmyadmin8-container
docker compose -f ./deployment.yaml up -d chroma-container

```

- Go to localhost:8100 and import database name: lockerkorea


## BACKEND

- Install packed and run (Require maven and JavaHome=17)

```
mvn clean install
mvn spring-boot:run
```

## FRONTEND

- Install packed (Require Node Js)

```
npm install --legacy-peer-deps
npm audit fix
npm start
```




