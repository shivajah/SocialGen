# SocialGen
**SocialGen** is a tool for generating large quantities of synthetic data that models status updates/tweets from users of two imaginary social networks. SocialGen can be configured to run in a parallel/distributed fashion generating partitions of data in parallel using a cluster of machines.

SocialGen generates data in Asterix Data Model (ADM) format. Here is a sample data type definition for the output of SocialGen:

  ```
  create type EmploymentType as {
  organization_name: string,
  start_date: date,
  end_date: date?
  }
  
  create type FacebookUserType as {
  id: int64,
  alias: string,
  name: string,
  user_since: datetime,
  friend_ids: {{ int64 }},
  employment: [EmploymentType]
  }
  
  create type FacebookMessageType as {
  message_id: int64,
  author_id: int64,
  in_response_to: int64?,
  sender_location: point,
  send_time: datetime,
  message: string
  }
  
  create type TwitterUserType as {
  screen_name: string,
  lang: string,
  friends_count: int32,
  statuses_count: int32,
  name: string,
  followers_count: int32
  }
  
  create type TweetMessageType as {
  tweetid: int64,    
  user: TwitterUserType,
  sender_location: point,
  send_time: datetime,
  referred_topics: {{ string }},
  message_text: string
  }
  ```

# Using SocialGen
## Prerequisites
* A suitable *nix environment (Linux, OSX)
* JDK 1.8+
* Maven 3.1.1 or greater

## Steps
1. Check out the SocialGen project in a directory via git. Assume that the path to the directory is $HOME/SocialGen. We will refer to this directory as **SOCIAL_GEN_HOME** in the rest of this document. **Important** If you intend to generate data in parallel using a cluster of machines, it is required that SOCIAL_GEN_HOME is on the NFS (Network File System) and accessible from all the participating machines.

2. Set SOCIAL_GEN_HOME as an environment variable on the machine you are running SocialGen from:

  ```
  > export SOCIAL_GEN_HOME=$HOME/SocialGen
  ```
3. Go into the SOCIAL_GEN_HOME and build its artifacts by executing the following commands:

  ```
  > cd $SOCIAL_GEN_HOME
  > mvn clean package 
  ```
Upon a successful build, a new directory named *target* will be created under SOCIAL_GEN_HOME that contains the jar file for SocialGen i.e. _SocialGen.jar_ .

4. The configuration files for SocialGen are under the _conf_ directory:

  1. machines: This file lists the machine(s) that you want to generate social data on. If you want to generate data only on a single machine, this file may contain the hostname for that machine or simply localhost as the machine name (if everything is done locally). For generating data on a cluster, you need to add the machine names (one machine name per line) into the machines file. 
  __Important:__ SocialGen assumes that the machines that are listed in this file are accessible via password-less SSH.
  
  2. conf.xml: This file describes the input parameters to SocialGen and properties of each partition of the generated data. You need to specify the total number of FacebookUsers and TwitterUsers records in the social network along with the average number of messages and tweets per user. Moreover, for each partition of the generated data, you specify the machine that the partition resides on and the absolute path for that partition. Please note that the machine should be a valid and accessible machine that is already listed in the machines file (see above) and the path to the partition should be writable.

  As an example, imagine we have two machines: _rainbow-1_ and _rainbow-2_, while on each one of them we want to have two partitions of generated data such that partitions _p0_ and _p1_ reside on rainbow-1 and partitions _p2_ and _p3_ reside on rainbow-2. Moreover, assume we decide to have 1000 users in the FacebookUsers dataset with an average of 5 messages per user and 2000 users as the TwitterUsers with an average of 10 tweets per user. The configuration files for this example would look like as:

  _machines_ file:
  ```
  rainbow-1
  rainbow-2
  ```
  _conf.xml_ file:
  ```
  <?xml version="1.0" encoding="UTF-8"?>
  <Dbgen>
  	<facebookUsers>1000</facebookUsers>
  	<twitterUsers>2000</twitterUsers>
  	<avgMsg>5</avgMsg>
  	<avgTweet>10</avgTweet>
  
  	<Partitions>
  		<partition>
  			<name>p0</name>
  			<host>rainbow-1</host>
  			<path>/mnt/data/sda/socialData</path>
  		</partition>
  
  		<partition>
  			<name>p1</name>
  			<host>rainbow-1</host>
  			<path>/mnt/data/sdb/socialData</path>
  		</partition>
  
  		<partition>
  			<name>p2</name>
  			<host>rainbow-2</host>
  			<path>/mnt/data/sda/socialData</path>
  		</partition>
  
  		<partition>
  			<name>p3</name>
  			<host>rainbow-2</host>
  			<path>/mnt/data/sdb/socialData</path>
  		</partition>
   
  	</Partitions>
  </Dbgen>
  ```
5. SocialGen needs to distribute necessary artifacts and scripts to the participating machines. For simplicity, we choose a single path which needs to be available locally on all the machines. SocialGen creates this path and its corresponding directory on the local file system of each machine and copies the necessary artifacts to these directories. We refer to this directory path as __SOCIAL_GEN_LOCAL_HOME__. You need to set this path as an environment variable (on the machine you are running socialGen from):

  ```
  > export SOCIAL_GEN_LOCAL_HOME=<absolute path to the chosen directory>
  ```
6. Install SocialGen by running the _install_ script. This step copies the required artifacts from SOCIAL_GEN_HOME into SOCIAL_GEN_LOCAL_HOME on all machines:

  ```
  > $SOCIAL_GEN_HOME/scripts/install.sh
  ```
7. Run SocialGen to initialize the data generation process:

  ```
  > $SOCIAL_GEN_HOME/scripts/init.sh
  ```
 
Upon termination of the generation process, you can find three data files (in .adm format) per partition under the path that is specified for the partition in the conf.xml file.