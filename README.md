# @ldu-devtools/devinf

DEV-INF scripts means that we can use .sh or .bat script files to help the developers everyday's work.

## DEV-INF for DevOps projects

DevOps DEV-INF scripts created to help developers:

* running db container modules, with docker-compose up | down
* running admin container modules, with docker image updates
* running api container modules, with docker image updates
* running comingsoon container modules, with docker image updates
* running landing container modules, with docker image updates

## DEV-INF for Gulp projects

Gulp DEV-INF scripts created to help developers:

* build their Gulp projects, and create a final package for them
* publish their Gulp projects to npmjs public registry

## DEV-INF for SpringBoot projects

SpringBoot DEV-INF scripts created to help developers:

* build their SpringBoot projects, and create a final package for them
* publish their SpringBoot projects to maven central public registry
* deploy their SpringBoot projects via docker images

## Development

### Install

Installs all of the dependencies for this project

(on Windows OS)

``` batch
npm install
```

(on Linux OS)

``` sh
npm install
```

### Build

Builds this project to the **dist** folder and creates a zip package from the dist content into the **build** folder

(on Windows OS)

``` batch
gulp build-%projectType%
```

(on Linux OS)

``` sh
gulp build-${projectType}
```

### Supported Project Types

Run the following command in terminal to see the supported project type list:

(on Windows OS)

``` batch
npm run supported-pt-list
```

(on Linux OS)

``` sh
npm run supported-pt-list
```

## About

To get more informations about this project, or if you have any question or suggestion, please send an email to [me](mailto:info@lildutils.hu)

## 

Thanks :)
