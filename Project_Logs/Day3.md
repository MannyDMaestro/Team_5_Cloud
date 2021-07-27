### Project Log Day 3
At this point of the project, We decided to construct our infrastructure through CloudFormation. Our infrastructure focused primarily on high availability and fault tolerance with regard to our CI/CD pipeline for the Minecraft application. 

#### CloudFormation Stack Creation Procedure
1. Log on to AWS console
2. Provision a new EC2 Key Pair
3. Go to the CloudFormation console
4. Click on the Create Stack button towards the top of the console; At the Select Template screen, upload the project cloudformation template, then click on the Next button;
5. At the Specify Details screen, enter in SpotCICDWorkshop as the Stack name. Under the Parameters section:
6. Identify what your current public IP address is by going to https://www.google.com.au/search?q=what%27s+my+ip+address. Enter the first three octets of this IP address into the CurrentIP parameter field and then add the .0/24 suffix. ***PLEASE BE ADVISED, It’s good security practice to ensure that the web and SSH services being used in this project are not accessible to everyone on the Internet. In our case, limiting access to the /24 CIDR block that our IP address is in provides a reasonable level of access control - but this may still be too restrictive in some IT environments.***
7. Enter in a password that you would like to use for the administrator account within the Jenkins server that will be launched by the CloudFormation template;
8. Select the project key pair option in the Keypair dropdown.
9. Click on the Next button;
10. Finally at the Review screen, verify your settings, mark the I acknowledge that AWS CloudFormation might create IAM resources with custom names checkbox and then click on the Create button. Wait for the stack to complete provisioning, which should take a couple of minutes.

### Configure Git pulgin on Jenkins
Git is one of the most popular tools for version control system. you can pull code from git repositories using jenkins if you use github plugin. We will use our git repository in our CI/CD pipeline for the project. Continuous Integration works by pushing small code chunks to our application’s codebase hosted in a Git repository, and to every push, run a pipeline of scripts to build, test, and validate the code changes before merging them into the main branch. Continuous Delivery and Deployment consist of a step further CI, deploying our application to production at every push to the default branch of the repository.

We will deploy Jenkins build agents and our test environments on Spot instances at a fraction of the cost of on-demand instances. Once our Jenkins instance was up and running, we will link the Jenkins master node to our team’s git repository.

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

