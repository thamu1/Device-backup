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



















  
