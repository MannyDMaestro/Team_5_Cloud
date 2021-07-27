## Project Log Day 5

After successfully building a maven project using jenkins and our git repository. We wanted to see if we could somehow apply this knowledge and develop a build to deploy and integrate Minecraft servers.
This posed as a difficult task. We were running into issues with our build. So we decided to digress from our main project objective and start off with building a website/database of minecraft cheat codes and guides to provide gameplay advice for gamers all around the world.
We decide to use Apache Tomcat to run a HTTP web server environment in which our Java code can run.

Some of our project members asked, "Why use Apache Tomcat over Apache HTTP Server?" Well, comparisons between Apache Tomcat and Apache HTTPS Server can be confusing, since both have Apache in their name, and both are developed by the ASF (Apache Software Foundation). But the truth is that they’re two very different software packages. While Apache is a traditional HTTPS web server, optimised for handling static and dynamic web content (very often PHP-based), it lacks the ability to manage Java Servlets and JSP. Tomcat, on the other hand, is almost totally geared towards Java-based content. In fact, Tomcat was originally developed as a means to provide the JSP functionality that Apache lacked. Even with this in mind, a comparison between Tomcat Server and Apache doesn’t come down to a direct competition. This is because it’s completely viable to run them side by side. So in projects involving both Java and PHP-based content, for example, it makes sense to have Apache handling most of the static and dynamic content, while Tomcat takes care of the JSP.

### Procedure

# Tomcat installation on EC2 instance
- We deployed a t2.micro on demand instance for the Tomcat Installation  
  
### Pre-requisites
1. EC2 instance with Java v1.8.x 
### Install Apache Tomcat
1. Download tomcat packages from  https://tomcat.apache.org/download-80.cgi onto /opt on EC2 instance
   > Note: Make sure you change `<version>` with the tomcat version which you download. 
   ```sh 
   # Create tomcat directory
   cd /opt
   wget http://mirrors.fibergrid.in/apache/tomcat/tomcat-8/v8.5.35/bin/apache-tomcat-8.5.35.tar.gz
   tar -xvzf /opt/apache-tomcat-<version>.tar.gz
   ```
1. give executing permissions to startup.sh and shutdown.sh which are under bin. 
   ```sh
   chmod +x /opt/apache-tomcat-<version>/bin/startup.sh 
   chmod +x /opt/apache-tomcat-<version>/bin/shutdown.sh
   ```
   > Note: you may get below error while starting tomcat incase if you dont install Java   
   `Neither the JAVA_HOME nor the JRE_HOME environment variable is defined At least one of these environment variable is needed to run this program`
1. create link files for tomcat startup.sh and shutdown.sh 
   ```sh
   ln -s /opt/apache-tomcat-<version>/bin/startup.sh /usr/local/bin/tomcatup
   ln -s /opt/apache-tomcat-<version>/bin/shutdown.sh /usr/local/bin/tomcatdown
   tomcatup
   ```
  #### Check point :
access tomcat application from browser on port 8080  
 - http://<Public_IP>:8080

  Using unique ports for each application is a best practice in an environment. But tomcat and Jenkins runs on ports number 8080. Hence lets change tomcat port number to 8090. Change port number in conf/server.xml file under tomcat home
   ```sh
 cd /opt/apache-tomcat-<version>/conf
# update port number in the "connecter port" field in server.xml
# restart tomcat after configuration update
tomcatdown
tomcatup
```
#### Check point :
Access tomcat application from browser on port 8090  
 - http://<Public_IP>:8090

1. now application is accessible on port 8090. but tomcat application doesnt allow to login from browser. changing a default parameter in context.xml does address this issue
   ```sh
   #search for context.xml
   find / -name context.xml
   ```
1. above command gives 3 context.xml files. comment (<!-- & -->) `Value ClassName` field on files which are under webapp directory. 
After that restart tomcat services to effect these changes. 
At the time of writing this lecture below 2 files are updated. 
   ```sh 
   /opt/tomcat/webapps/host-manager/META-INF/context.xml
   /opt/tomcat/webapps/manager/META-INF/context.xml
   
   # Restart tomcat services
   tomcatdown  
   tomcatup
   ```
1. Update users information in the tomcat-users.xml file
goto tomcat home directory and Add below users to conf/tomcat-users.xml file
   ```sh
	<role rolename="manager-gui"/>
	<role rolename="manager-script"/>
	<role rolename="manager-jmx"/>
	<role rolename="manager-status"/>
	<user username="admin" password="admin" roles="manager-gui, manager-script, manager-jmx, manager-status"/>
	<user username="deployer" password="deployer" roles="manager-script"/>
	<user username="tomcat" password="s3cret" roles="manager-gui"/>
   ```
1. Restart serivce and try to login to tomcat application from the browser. This time it should be Successful

### Now its time to deploy our jsp file with Tomcat with the help of Jenkins

# Deploy on a Tomcat server
# *Jenkins Job name:* `Deploy_on_Tomcat_Server`

### Pre-requisites

1. Jenkins server 
2. Tomcat Server 

### Adding Deployment steps

1. Install 'deploy to container' plugin. This plugin needs to deploy on tomcat server. 

  - Install 'deploy to container' plugin without restart  
    - `Manage Jenkins` > `Jenkins Plugins` > `available` > `deploy to container`
 
2. Jenkins should need access to the tomcat server to deploy build artifacts. setup credentials to enable this process. use credentials option on Jenkins home page.

- setup credentials
  - `credentials` > `jenkins` > `Global credentials` > `add credentials`
    - Username	: `deployer`
    - Password : `deployer`
    - id      :  `deployer`
    - Description: `user to deploy on tomcat vm`

### Steps to create "Deploy_on_Tomcat_Server" Jenkin job
 #### From Jenkins home page select "New Item"
   - Enter an item name: `Deploy_on_Tomcat_Server`
     - Copy from: `My_First_Maven_Build`
     
   - *Source Code Management:*
      - Repository: `https://github.com/yankils/hello-world.git`
      - Branches to build : `*/master`  
   - *Poll SCM* :      - `* * * *`

   - *Build:*
     - Root POM:`pom.xml`
     - Goals and options: `clean install package`

 - *Post-build Actions*
   - Deploy war/ear to container
      - WAR/EAR files : `**/*.war`
      - Containers : `Tomcat 8.x`
         - Credentials: `deployer` (user created on above)
         - Tomcat URL : `http://<PUBLIC_IP>:8080`

Save and run the job now.
