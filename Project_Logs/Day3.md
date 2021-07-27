## Project Log Day 3
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


### Jenkins
Jenkins is a self-contained Java-based program, ready to run out-of-the-box, with packages for Windows, Mac OS X and other Unix-like operating systems. As an extensible automation server, Jenkins can be used as a simple CI server or turned into the continuous delivery hub for any project. We will deploy Jenkins build agents and our test environments on Spot instances at a fraction of the cost of on-demand instances. Once our Jenkins instance was up and running, we will link the Jenkins master node to our team’s git repository.

By default, all builds will be executed on the same instance that Jenkins is running on. This results in a couple of less-than-desirable behaviours: * When CPU-intensive builds are being executed, there may not be sufficient system resources to display the Jenkins server interface; and * The Jenkins server is often provisioned with more resources than the server interface requires in order to allow builds to execute. When builds are not being executed, these server resources are essentially going to waste.

To address these behaviours, Jenkins provides the capability to execute builds on external hosts (called build agents). Further, AWS provides a Jenkins plugin to allow Jenkins to scale out a fleet of EC2 instances in order to execute build jobs on.

#### Provision a Spot fleet for build agents
Before configuring the EC2 Fleet Jenkins Plugin, we will create a Spot Fleet that will be used by the plugin to perform our application builds. 

1. Go to the EC2 console and click on the Spot Requests option from the left frame (or click here);
2. Click on the Request Spot Instances button;
3. At the first screen of the Spot instance launch wizard: Under the Tell us your application or task need heading, ensure that the Load balancing workloads option selected (Note: do NOT select the Flexible workloads option as this will deploy a Spot Fleet with weightings applied to some of the EC2 instance types which will adversely impact how the plugin scales out);
4. In the Configure your instances section, select the JenkinsBuildAgentLaunchTemplate template from the Launch template dropdown (if this option is not present in the dropdown, please verify that the CloudFormation template that you launched during the Workshop Preparation has deployed successfully). Change the Network to be the Spot CICD VPC. After making this selection, enable the check boxes for all three Availability Zones and then select the EC2 Spot CICD Public Subnet associated with each availability zone as the subnet to launch instances in
5. At the Tell us how much capacity you need section, keep the Total target capacity at 1 instance and the Optional On-Demand portion set to 0, and then tick the Maintain target capacity checkbox. Once selected, leave the Interruption behavior set to Terminate;
6. To the right of the Fleet request settings heading, clear the tick from Apply recommendations checkbox. Click on each of the Remove links associated with the all of the instance types initially defined to remove them from the fleet configuration. Then click on the Select instance types button and add the t2.medium, t2.large, t3.medium and t3.large instance types to the fleet definition. 
7. Once the checkboxes for the required instance types have been ticked, click on the Select button. Once you have the four desired instance types listed in the fleet request, select the Lowest Price Fleet allocation strategy (since we’re interested in keeping cost to an absolute minimum for this use case);
8. Review the fleet request as a glance section - it should indicate that the Fleet strength is Strong as a result of being able to draw instances from 12 instance pools, and your Estimated price should indicate that you’re expecting to make a 70% saving compared to the cost of equivalent on-demand resources;
9. Lastly, click on the Launch button. Make a note of the Request ID of the Spot Fleet that you’ve just created.

#### Create a secret key and access key for the plugin

The CloudFormation template we deployed earlier in the previous steps created an IAM User called SpotCICDWorkshopJenkins. Jenkins will use this IAM User to control the spot fleet used for our build slaves. Generate a secret key and access key for this user.

##### Procedure
1. Go to the IAM console and click on the Users option from the left frame (or click here);
2. Click on the SpotCICDWorkshopJenkins user;
3. Click on the Security credentials tab, then click on the Create access key button – Make a note of the Access key ID and Secret access key, then click the Close button.

#### Sign into Jenkins Server

The CloudFormation template deployed deployed a Jenkins server on to an on-demand instance within our VPC and configured an Application Load Balancer (ALB) to proxy requests from the public Internet to the server. The DNS name for the ALB is located in the Output tab of our CloudFormation stack. We will point our web browser to this DNS name and sign in using spotcicdworkshop as the Username and the password that you supplied to the CloudFormation template as the password.

***

##### Configure the EC2 Fleet Jenkins Plugin

The EC2 Fleet Jenkins Plugin was installed on the Jenkins server during the CloudFormation deployment - but now the plugin needs to be configured. You’ll first need to supply the IAM Access Key ID and Secret Key that you created so that the plugin can find your Spot Fleet request. You’ll then need to get the plugin to Launch slave agents via SSH and provide valid SSH credentials (don’t forget to consider how Host Key Verification should be set when using Spot instances).

When configuring the plugin, think about how you could force build processes to run on the spot instances (use the spot-agents label), and consider how you can verify that the fleet scales out when there is a backlog of build jobs waiting to be processed.

 Click to reveal detailed instructions
From the Jenkins home screen, click on the Manage Jenkins link on the left side menu, and then the Configure System link;
Scroll all the way down to the bottom of the page and under the Cloud section, click on the Add a new cloud button, followed by the Amazon SpotFleet option;
Under the Spot Fleet Configuration section, click on the Add button next to the AWS Credentials [sic] dropdown, then click on the Jenkins option. This will pop up a new Jenkins Credentials Provider: Jenkins sub-form. Fill out the form as follows:
Change the Kind to AWS Credentials;
Change the Scope to System (Jenkins and nodes only) – you don’t want your builds to have access to these credentials!
At the ID field, enter SpotCICDWorkshopJenkins;
At the Access Key ID and Secret Access Key fields, enter in the information that you gathered earlier;
Click on the Add button;
Once the sub-form disappears, select your Access Key ID from the AWS Credentials dropdown - the plugin will then issue a request to the AWS APIs and populate the list of regions;
Select eu-west-1 from the Region dropdown - the plugin will now attempt to obtain a list of Spot Fleet requests made in the selected region;
Select the Request Id of the Spot Fleet that you created earlier from the Spot Fleet dropdown (though it might already be selected) and then select the Launch slave agents via SSH option from the Launcher dropdown - this should reveal additional SSH authentication settings;
Click the Add button next to the Credentials dropdown and select the Jenkins option. This will pop up another Jenkins Credentials Provider: Jenkins sub-form. Fill out the form as follows:
Change the Kind to SSH Username with private key;
Change the Scope to System (Jenkins and nodes only) – you also don’t want your builds to have access to these credentials;
At the Username field, enter ec2-user;
For the Private Key, select the Enter directly radio button. Open the .pem file that you downloaded during the workshop setup in a text editor and copy the contents of the file to the Key field including the BEGIN RSA PRIVATE KEY and END RSA PRIVATE KEY fields;
Click on the Add button.
Select the ec2-user option from the Credentials dropdown;
Given that Spot instances will have a random SSH host fingerprint, select the Non verifying Verification Strategy option from the Host Key Verification Strategy dropdown;
Mark the Connect Private checkbox to ensure that your Jenkins Master will always communicate with the Agents via their internal VPC IP addresses (in real-world scenarios, your build agents would likely not be publicly addressable);
Change the Label field to be spot-agents - you’ll shortly reconfigure your build job to run on slave instances featuring this label;
Set the Max Idle Minutes Before Scaledown to 5. As AWS launched per-second billing in 2017, there’s no need to keep a build agent running for too much longer than it’s required;
Change the Maximum Cluster Size from 1 to 2 (so that you can test fleet scale-out);
Finally, click on the Save button.
Within sixty-seconds, the Jenkins Slave Agent should have been installed on to the Spot instance that was launched by your Spot fleet; you should see an EC2 instance ID appear underneath the Build Executor Status section on the left side of the Jenkins user interface. Underneath that, you should see that there is a single Build Executor on this host, which is in an idle state.

RECONFIGURE YOUR BUILD JOBS TO USE THE NEW SPOT INSTANCE(S)
As alluded to in the previous section, you’ll need to reconfigure your build jobs so that they are executed on the build agents running in your Spot fleet (again, use the spot-agents label). In addition, configure each job to execute concurrent builds if necessary - this will help you in testing the scale-out of your fleet.

 Click to reveal detailed instructions
Go back to the Jenkins home screen and repeat the following for each of the five Apache build projects that are configured in your Jenkins deployment:
Click on the title of the build job and then click on the Configure link toward the left side of the screen;
In the General section, click on the Execute concurrent builds if necessary checkbox and the Restrict where this project can be run checkbox. Next, enter spot-agents as the Label Expression (Note: if you select the auto-complete option instead of typing out the full label, Jenkins will add a space to the end of the label - be sure to remove any trailing spaces from the label before proceeding);
Click on the Save button towards the bottom of the screen.


### Configure Git pulgin on Jenkins
Git is one of the most popular tools for version control system. you can pull code from git repositories using jenkins if you use github plugin. We will use our git repository in our CI/CD pipeline for the project. Continuous Integration works by pushing small code chunks to our application’s codebase hosted in a Git repository, and to every push, run a pipeline of scripts to build, test, and validate the code changes before merging them into the main branch. Continuous Delivery and Deployment consist of a step further CI, deploying our application to production at every push to the default branch of the repository.


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

## Install Java
1. We will be using open java for our demo.
   ```sh
   yum install java-1.8*
   #yum -y install java-1.8.0-openjdk-devel
   ```

1. Confirm Java Version and set the java home
   ```sh
   java -version
   find /usr/lib/jvm/java-1.8* | head -n 3
   JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-<Java version which seen in the above output>
   export JAVA_HOME
   PATH=$PATH:$JAVA_HOME
    # To set it permanently update your .bash_profile
   vi ~/.bash_profile
   ```
   _The output should be something like this,_
    ```sh
   [root@~]# java -version
   openjdk version "1.8.0_151"
   OpenJDK Runtime Environment (build 1.8.0_151-b12)
   OpenJDK 64-Bit Server VM (build 25.151-b12, mixed mode)
   ```

   ### Accessing Jenkins
   By default jenkins runs at port `8080`, You can access jenkins at
   ```sh
   http://YOUR-SERVER-PUBLIC-IP:8080
   ```
  #### Configure Jenkins
- The default Username is `admin`
- Grab the default password 
- Password Location:`/var/lib/jenkins/secrets/initialAdminPassword`
- `Skip` Plugin Installation; _We can do it later_
- Change admin password
   - `Admin` > `Configure` > `Password`
- Configure `java` path
  - `Manage Jenkins` > `Global Tool Configuration` > `JDK`  
- Create another admin user id

### Test Jenkins Jobs
1. Create “new item”
1. Enter an item name – `My-First-Project`
   - Chose `Freestyle` project
1. Under the Build section
	Execute shell: echo "Welcome to Jenkins Demo"
1. Save your job 
1. Build job
1. Check "console output"
