Presto:
------
  - Open source Distributed SQL query engine, Fast reliable and efficient at scale.
  - In memory data processing.
  - It is replacement for Hive.
  - Designed for Batch data processing.
  - Master : Slave architecture. [Coordinator - Worker]
  - Coorinator:
    . Main component: Parser, Planner, Scheduler.
    . Meta data Management, Worker Management, Query resolution, Scheduling.
  - Workers:
    . Slave node: Computing and Read and Write operation.
    . Process data from various sources and perform computation.
    . Adding worker to enhance parallelism and speeds up query processing.
    . Process data in memory and pipeline it across network between stages, Avoiding unnecessary I/O overhead.
  - Discovery server:
    . Enable node to register themselves and help to find other nodes in the cluster
    . 

Features:
---------
  - Distributed SQL query engine.
  - Massively Parallel Processing(MPP)
  - In-memory processing.
  - Extensible: Support various data sources using connectors.
  - Compute and Storage are seperated.
  - Data source abstraction: Query data where it reside.
  - Scalable, Low Latency.

Architecture:
-------------

<img width="545" alt="image" src="https://github.com/user-attachments/assets/372bf295-e3c2-40fa-9338-84384e8d903d" />



    
  
