# @ldu-devtools/devinf

DEV-INF scripts means that we can use .sh or .bat script files to help the developers everyday's work.

## How to make DEV-INF scripts runnable

*(on Windows OS)*

...just allow the script run, if pops up

*(on Linux OS)*

``` sh
sudo chmod -R 755 ${PWD}/DEV-INF/*.sh
```

## DEV-INF core scripts

Basicly core scripts are created to implement those funcionalities, which can use globaly.

* *_checker.sh*: can check if docker, gradlew, java, node or npm are installed or not
* *_dockerIt.sh*: can do docker login | build | push tasks
* *_logger.sh*: created to log every necessary information with configurable logging level
* *_utils.sh*: contains many useful task, like clean folder, or make folder, etc...
* *_zipIt.sh*: created to make quick zip packages

## DEV-INF for Angular projects

Angular DEV-INF scripts created to help developers:

* *build*: their Angular projects, and create a final package for them
* *publish*: their Gulp projects to npmjs public registry with --publish arg
* *docker*: their Angular projects via docker images
* *deploy*: open an ssh tunnel and run one command which can be configured

## DEV-INF for DevOps/Database projects

DevOps DEV-INF scripts created to help developers:

* *running*: database server container modules, with docker-compose up
* *stopping*: database servercontainer modules, with docker-compose down
* *backup*: database via container exec
* *restore*: database via container exec
* *cron*: set cron backup for database via backup script

## DEV-INF for DevOps/Domain projects

DevOps DEV-INF scripts created to help developers:

* *admin*: container modules, with docker image updates
* *api*: container modules, with docker image updates
* *comingsoon*: container modules, with docker image updates
* *landing*: container modules, with docker image updates

## DEV-INF for Gulp projects

Gulp DEV-INF scripts created to help developers:

* *build* their Gulp projects, and create a final package for them
* *publish* their Gulp projects to npmjs public registry with --publish arg

## DEV-INF for SpringBoot projects

SpringBoot DEV-INF scripts created to help developers:

* *build*: their SpringBoot projects, and create a final package for them
* *publish*: their SpringBoot projects to maven central public registry with --publish arg
* *docker*: their SpringBoot projects via docker images
* *deploy*: open an ssh tunnel and run one command which can be configured in configs.json file
* *cacerts*: fila path are under (for Java) -> /etc/ssl/certs/java/cacerts"

## Development

### Install

Installs all of the dependencies for this project

*(on Windows OS)*

``` batch
npm install
```

*(on Linux OS)*

``` sh
npm install
```

### Build

Builds this project to the **dist** folder and creates a zip package from the dist content into the **build** folder

*(on Windows OS)*

``` batch
gulp build-%PROJECT_TYPE%
```

*(on Linux OS)*

``` sh
gulp build-${projectType}
```

## Supported Project Types

Run the following command in terminal to see the supported project type list:

(on Windows OS)

``` batch
npm run supported-pt-list
```

(on Linux OS)

``` sh
npm run supported-pt-list
```

## Future Development

The planning of the future development are the following (any change can happen in the planning):

### v1.5.0

* ...with version 1.4 feature set
* Supports batch scripts too

### v1.6.0

* Some testing framework integration

### v1.x

* DEV-INF for VueJS projects

### v1.x

* DEV-INF for PHP Boot projects

## About

To get more informations about this project, or if you have any question or suggestion, please send an email to [me](mailto:info@lildutils.hu)

## 

Thanks :)
