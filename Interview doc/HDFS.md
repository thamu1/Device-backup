HDFS:
-----
  - Hadoop Distributed File System. Store data across cluster of machine.
  - Store and Manage large datasets.
  - High speed file access and Manage
  - fault tolerence, Replicate data across different nodes.

Architecture:
-------------
  ![image](https://github.com/user-attachments/assets/d4f360c6-9a1d-443e-8670-4254d2a2327f)

Name Node and Data Node:
------------------------
    - Master slave architecture. Name Node : Master, Data Node : Slave.
    - Name Node is hardware contains GNU/Linux OS and software. 
    - HDFS act as a master, can manage the files, access control, file operations (rename, open, close).
    - Metadata Management (file location, replicas, etc)

    - Data Node is hardeware contains GNU/Linux OS and DataNode software.
    - Help to control data storage.
    - as client request > create, replicate, block files when NameNode instruct.

Features:
---------
  - Manage Large datasets
  - Detecting faults
  - Hardware efficiency: Reduce the network traffic and increase the processing speed.

Types of File system:
---------------------
  - Standalone:
    . NTFS (Windows), ExT(Linux - Extensible File System)
  - Distributed File System:
    . HDFS, S3, GCS, CFS

  - Flow: -> File(txt) -> File System (NTFS/HDFS etc) -> HDD (Hard Disk) -> Blocks of data (windows:4KB  |  Ext : 4KB)

Types of Distributed System:
----------------------------
    - Master and Slave: 
      . Master communicate with its slaves. 
      . There is no communication bt Slaves. If Slave filed Master take care of it. (SPOF - Single Point Of Failure or SPOC - Single Point of Communication.) 
      . Ex: Hadoop, Spark
    - Peer to Peer(P2P) : 
      . Decentralized, All node have equal status and interact with each others.
      . Ex: Cassandra
      
  ![image](https://github.com/user-attachments/assets/cf40d8f1-8785-448b-9b99-541364e862dd)
  ![image](https://github.com/user-attachments/assets/3dfc50d1-1914-491e-8668-df1f8714f1d5)

Cluster and Node: 
-----------------
  - Node: single Machine (eg: Laptop, Desktop, VM)
  - Group of Nodes connected with each other.

Hadoop Architecture:
--------------------
  ![image](https://github.com/user-attachments/assets/25fd964f-3494-4c7e-b1f3-c984e720ad98)

  - Eg setup:
    . Create 5 Vm -> install Hadoop in all 6 -> Config one of them as **Master** Remaining 4 as **Slave** (Master need more RAM and all), 1 Machine as Client (**edge Node**) for communicate with Master as a user (for avoid direct interaction)

Flow:
-----
  - EXT(local file system) -> hdfs command (from Edge Node) -> request API -> Master Node -> Metadata creation about the req details (File stored in EXT) -> 

  - Note:
    . Block default size 128MB in hadoop version >= 2
    . Store the 1GB file into blocks like 1024/128 => MB of partitions.
    . The data will also replicate in the other Nodes also for fault tolerence.
    . 1 node will have default 3 replicas, same replica partition will not in single node
    . **RackAwareness Algotithm** responsible for where to store the replica file in HDFS.
    . Heart beat communication: every 3 minute each worker node will send msg to master that he is alive.
    
Failures:
----------
  - Software and Network : temporary
  - Hardware : permenant

Failover:
---------
  - Hadoop failover ensure Hadoop HDFS NameNode High availability.
  - If any DataNode failed, the NameNode try to replicate the copies into other Node or Once new node attached to the Hadoop It will replicate the data to new node.
  - Automatic Failover achieved by **ZooKeeper**.
  - For Temporary Failure, In Hadoop > 2 We have Active Node and Passive Node (By Zookeeper). If active node failed the Passive take over the Active node work.
  - Hadoop > 2 provides **High availability** achieved by Zookeeper(Leader & follower architecture).

Types of Node in Hadoop - 2:
----------------------------
  - Active Master Node: Active NameNode + Active Resource Manager
  - Passive Master Node: Passive NameNode + Passive Resource Manager
  - Secondary Node (if passive node not available)
  - ZooKeeper Node(Quorm)
  - Journal Node

Types Of cluster:
-----------------
  - Single Node or Psudo
  - Distributed Cluster
    . Hadoop < 2 : 1 Name Node + 1 Secondary, can have N slave Node. Minimun 5 required
    . Hadoop >= v2 : 1 Name Node + 1 Passive/Secondary + 1 or 2 Zookeeper + 1 or 2 Journal Node  + N Slave. Minimum 7 required
    



    






















  
