## Project Log Day 4

We will use maven for building and managing our Java-based project. Maven is a powerful project management tool that is based on POM (project object model). It is used for projects build, dependency and documentation. Maven is a powerful project management tool that is based on POM (project object model). It is used for projects build, dependency and documentation.


![image](https://user-images.githubusercontent.com/67617750/127207933-4dafce23-d0aa-4dbf-9656-7551d7bbe2fb.png)

Core Concepts of Maven:

1. POM Files: Project Object Model(POM) Files are XML file that contains information related to the project and configuration information such as dependencies, source directory, plugin, goals etc. used by Maven to build the project. When you should execute a maven command you give maven a POM file to execute the commands. Maven reads pom.xml file to accomplish its configuration and operations.
2. Dependencies and Repositories: Dependencies are external Java libraries required for Project and repositories are directories of packaged JAR files. The local repository is just a directory on your machine hard drive. If the dependencies are not found in the local Maven repository, Maven downloads them from a central Maven repository and puts them in your local repository.
3. Build Life Cycles, Phases and Goals: A build life cycle consists of a sequence of build phases, and each build phase consists of a sequence of goals. Maven command is the name of a build lifecycle, phase or goal. If a lifecycle is requested executed by giving maven command, all build phases in that life cycle are executed also. If a build phase is requested executed, all build phases before it in the defined sequence are executed too.
4. Build Profiles: Build profiles a set of configuration values which allows you to build your project using different configurations. For example, you may need to build your project for your local computer, for development and test. To enable different builds you can add different build profiles to your POM files using its profiles elements and are triggered in the variety of ways.
5. Build Plugins: Build plugins are used to perform specific goal. you can add a plugin to the POM file. Maven has some standard plugins you can use, and you can also implement your own in Java.
