Presto:
------
  - Open source Distributed SQL query engine, Fast reliable and efficient at scale.
  - In memory data processing.
  - It is replacement for Hive.
  - Designed for Batch data processing.
  - Master : Slave architecture. [Coordinator - Worker]
  - it's depends on Hive metastore.
  - **Coordinator**:
    . Main component: Parser, Planner, Scheduler.
    . Meta data Management, Worker Management, Query resolution, Scheduling.
  - **Workers**:
    . Slave node: Computing and Read and Write operation.
    . Process data from various sources and perform computation.
    . Adding worker to enhance parallelism and speeds up query processing.
    . Process data in memory and pipeline it across network between stages, Avoiding unnecessary I/O overhead.
  - **Discovery server (Resource Manager):**
    . Enable node to register themselves and help to find other nodes in the cluster. It uses thrift API to communicate with Coordinator and Workers.
    . Aggregate data from all Coordinators and worker.
  - **flow:**
    Client -> Work -> Coordinator -> Optimized query -> Worker -> Fetch data from Connector -> Processing the data -> Result -> Coordinator fetch result from Worker -> result to client.
  - **Components:**
    . Connectors: Driver for data sources. Ex: HDFS, S3, MySQL, Kafka, etc
    . Catalog: Contains schema from a data source specified by the connector.
    . Schemas: Namespace to organize tables
    . Set of unordered rows organized into columns with types.
    
Features:
---------
  - Distributed SQL query engine.
  - Massively Parallel Processing(MPP)
  - In-memory processing.
  - Multi level caching with RaptorX.
  - Extensible: Support various data sources using connectors.
  - Compute and Storage are seperated.
  - Data source abstraction: Query data where it reside.
  - Scalable, Low Latency.

Architecture:
-------------

<img width="545" alt="image" src="https://github.com/user-attachments/assets/372bf295-e3c2-40fa-9338-84384e8d903d" />

Data Model:
-----------
  - Presto adapt three layer table structure
  - <catalog>.<schema>.<table>

![Uploading {66D9FB8A-0594-4AE6-8DBE-46E133DB0430}.png…]()







  



  





    
  
