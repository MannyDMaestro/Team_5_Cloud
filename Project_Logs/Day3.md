### Project Log Day 3
At this point of the project, We decided to construct our infrastructure through CloudFormation. Our infrastructure focused primarily on high availability and fault tolerance with regard to our CI/CD pipeline for the Minecraft application. **Discuss auto scaling** 
Once our Jenkins instance was up and running, we decided to link the Jenkins master node to our team’s git repository.


### Configure Git pulgin on Jenkins
Git is one of the most popular tools for version control system. you can pull code from git repositories using jenkins if you use github plugin. 


#### Prerequisites
1. Jenkins server 

#### Install Git on Jenkins server
1. Install git packages on jenkins server
   ```sh
   yum install git -y
   ```

#### Setup Git on jenkins console
- Install git plugin without restart  
  - `Manage Jenkins` > `Jenkins Plugins` > `available` > `github`

- Configure git path
  - `Manage Jenkins` > `Global Tool Configuration` > `git`

