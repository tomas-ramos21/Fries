<div align="center">
  
# Fries Disassembler  

![Latest commit](https://img.shields.io/github/last-commit/tomas-ramos21/Fries/main?style=flat)
![License](https://img.shields.io/github/license/tomas-ramos21/Fries?color=purple)
![Version](https://img.shields.io/github/manifest-json/v/tomas-ramos21/Fries?color=purple)

<img src="/img/fries.png" width="275" height="275">

</div>

## Introduction
Fries lets you see the disassembled Java "byte-code" of the class under under the cursor in a new buffer. Heck!! If you have `javap-mode` installed it will even highlight it for you.

## How it Works
It starts by detecting the package of the `class`, the closest "target" directory, and then the JAR file within it or it's sub-directories. After that it will use the shell command `javap` along with some arguments to obtain the code. If no classes are found with the name under the cursor it will show you the error message provided by the `javap` command.

Find below examples of the typical project directory structure that is expected by Fries.

#### SBT - Scala
```
someProject
|-- build.sbt
|-- target
|   |--scala-2.13
|      `-- hello-world_2.13-1.0.jar
`-- src
    |-- main
        `-- scala
           `-- Main.scala

```

#### Maven - Java
```
my-app
|-- pom.xml
`-- src
    |-- main
    |   `-- java
    |       `-- com
    |           `-- mycompany
    |               `-- app
    |                   `-- App.java
    `-- test
        `-- java
            `-- com
                `-- mycompany
                    `-- app
                        `-- AppTest.java
```

## But what does it look like ?
<div align="center">
  <img src="/img/example.png">
</div>


## Supported Languages
The only supported languages as of now are:

 1. Scala
 2. Java

However, I will try to add more of them in future versions (e.g. Clojure, Kotlin, Dart, etc.).

## Installation
🛠 Work in progress ...

## Customization
The arguments and constants assumed by Fries are the industry standard (e.g. JAR file being within the "target" directory). However, you can easily change some of these constants to customise the behaviour of the package, such as:

 - The name of the target directory
 - The argument passed to the `javap` command
