# Real-Time-Cryptocurrency-Analytics

A real-time analytics platform for cryptocurrency trading or monitoring. This platform needs to handle high-frequency 
updates of cryptocurrency prices, trading volumes, market sentiment, etc., and provide real-time analytics and insights 
to traders, investors, and analysts.


🏢 Streaming Platform Infrastructure
--------------------------------------

Before jumping into any of the scenarios, you must start the shared infrastructure for the Cryto-currency application.
This includes Apache Pinot, Apache Pulsar, and Superset


Data Ingestion with Apache Pulsar
--
Use Apache Pulsar to ingest real-time cryptocurrency data streams from various exchanges, APIs, or blockchain networks.
Pulsar's scalability and durability ensure that all market data updates are captured reliably and in real-time.

### 1️⃣ Start Pulsar

[Apache Pulsar](https://pulsar.apache.org/) is an open-source, distributed messaging and streaming platform built for 
the cloud. It will serve as our event streaming storage platform for this demo.

```bash
sh ./bin/pulsar/start-pulsar.sh
```

You can verify that the deployment was successful using the following command, and seeing output similar to that
shown here. This indicates that all three Pulsar-related containers are running.

````bash
docker ps

CONTAINER ID   IMAGE                           COMMAND                  CREATED         STATUS                   PORTS                                            NAMES
d2d2f1371eaa   apachepulsar/pulsar-all:3.2.2   "bash -c 'bin/apply-…"   5 minutes ago   Up 4 minutes (healthy)   0.0.0.0:6650->6650/tcp, 0.0.0.0:8080->8080/tcp   pulsar-broker
0c1afb9a8736   apachepulsar/pulsar-all:3.2.2   "bash -c 'bin/apply-…"   5 minutes ago   Up 4 minutes (healthy)                                                    pulsar-bookie-1
efb296a5fea9   apachepulsar/pulsar-all:3.2.2   "bash -c 'bin/apply-…"   5 minutes ago   Up 5 minutes (healthy)                                                    zookeeper
````


### 2️⃣ Start Ingesting Crypto Market Data

Apache Pulsar provides a serverless computing framework known as [I/O connectors](https://pulsar.apache.org/docs/next/io-overview/), 
that allows us to easily ingest data from external sources into Apache Pulsar. The next step in the demo is to start our
[custom Pulsar source connector](https://github.com/david-streamlio/coinbase-live-feed) that consumes data from the 
[Coinbase Websocket API](https://docs.cloud.coinbase.com/exchange/docs/websocket-overview) and publishes it onto a Pulsar
topic.

```bash
sh ./bin/pulsar/start-coinbase-feed.sh
```

This command starts the connector using the configuration details specified in the
[coinbase-connector-all.yaml](infrastructure%2Fpulsar%2Ffunctions%2Fconf%2Fcoinbase-connector-all.yaml) configuration file.
By default, the configuration will request information for `ETH-USD and BTC-USD` from the following channels: 
`ticker, rfq_matches, and auctionfeed`. See the [Coinbase Websocket API](https://docs.cloud.coinbase.com/exchange/docs/websocket-overview)
for more details.

You can verify that the Source connector is working by running the following command to consume messages from the source's
configured output topic. If it is working properly, you should see output similar to that shown here:

````bash
docker exec -it pulsar-broker sh -c   "./bin/pulsar-client consume -n 0 -p Earliest -s my-sub persistent://feeds/realtime/coinbase-livefeed"

key:[ticker], properties:[product=BTC-USD], content:{"sequence":77240199610,"product_id":"BTC-USD","price":"66050.9","open_24h":"65957.46","volume_24h":"14538.28486134","low_24h":"64500","high_24h":"66944.06","volume_30d":"649666.78865346","best_bid":"66050.90","best_bid_size":"0.02475322","best_ask":"66053.11","best_ask_size":"0.00013000","side":"sell","time":"2024-04-03T19:04:05.198757Z","trade_id":626114466,"last_size":"0.00565955"}
----- got message -----
key:[ticker], properties:[product=BTC-USD], content:{"sequence":77240199612,"product_id":"BTC-USD","price":"66050.9","open_24h":"65957.46","volume_24h":"14538.28514778","low_24h":"64500","high_24h":"66944.06","volume_30d":"649666.78893990","best_bid":"66050.90","best_bid_size":"0.02446678","best_ask":"66053.11","best_ask_size":"0.00013000","side":"sell","time":"2024-04-03T19:04:05.198757Z","trade_id":626114467,"last_size":"0.00028644"}
----- got message -----
key:[ticker], properties:[product=BTC-USD], content:{"sequence":77240199619,"product_id":"BTC-USD","price":"66053.11","open_24h":"65957.46","volume_24h":"14538.28527778","low_24h":"64500","high_24h":"66944.06","volume_30d":"649666.78906990","best_bid":"66050.90","best_bid_size":"0.02446678","best_ask":"66055.99","best_ask_size":"0.00271222","side":"buy","time":"2024-04-03T19:04:05.200346Z","trade_id":626114468,"last_size":"0.00013"}
----- got message -----
key:[ticker], properties:[product=BTC-USD], content:{"sequence":77240199928,"product_id":"BTC-USD","price":"66055.99","open_24h":"65957.46","volume_24h":"14538.28537778","low_24h":"64500","high_24h":"66944.06","volume_30d":"649666.78916990","best_bid":"66053.21","best_bid_size":"0.00077910","best_ask":"66055.99","best_ask_size":"0.00261222","side":"buy","time":"2024-04-03T19:04:05.262708Z","trade_id":626114469,"last_size":"0.0001"}
...
````

Now that we have confirmed that the raw Crypto market data feed is bringing data into Pulsar, the next step is to 
utilize Pulsar Functions to perform lightweight processing on the incoming cryptocurrency data streams.

Real-Time Processing with Apache Pulsar Functions
--
Apache Pulsar provides a serverless computing framework known as [Pulsar Functions](https://pulsar.apache.org/docs/next/functions-overview/)
that allows us to easily execute arbitrary code against messages that are ingested into a Pulsar topic. Functions can 
filter, aggregate, and enrich the data, extracting relevant information such as price changes, trade volumes, and market
sentiment indicators, etc.


### 3️⃣ Start ETL Processing

Based on the configuration of the Crypto Market Feed source connector, we are ingesting data from multiple channels. 
The connector consumes these messages and publishes them as raw JSON String objects in the source topic. However, in order
to use this data for analysis, a schema must be assigned to each of these messages.

Therefore, our [first Pulsar Function](https://github.com/david-streamlio/coinbase-websocket-feed-router) is responsible
for transforming these raw JSON strings into the appropriate schema type based on the channel it came from, and routing 
them to different topics based on their contents.

![coinbase-router.png](doc%2Fimages%2Fcoinbase-router.png)


```bash
sh ./bin/pulsar/start-coinbase-feed-router.sh
```

This command starts the Crypto Market Data Feed routing function using the configuration details specified in the
[coinbase-router-config.yaml](infrastructure%2Fpulsar%2Ffunctions%2Fconf%2Fcoinbase-router-config.yaml) configuration file.

You can verify that the Pulsar Function is working by running the following command to consume messages from one of the
Function's configured output topics. If it is working properly, you should see output similar to that shown here:

````bash
docker exec -it pulsar-broker sh -c   "./bin/pulsar-client consume -n 0 -p Earliest -s my-sub persistent://feeds/realtime/coinbase-ticker"

----- got message -----
key:[null], properties:[], content:{"sequence":58026240238,"product_id":"ETH-USD","price":3317.39,"open_24h":3278.83,"volume_24h":103947.516,"low_24h":3202.8,"high_24h":3369.43,"volume_30d":4280222.53668427,"best_bid":3317.39,"best_bid_size":0.03373329,"best_ask":3317.71,"best_ask_size":0.44106743,"side":"sell","time":"2024-04-03T19:41:53.315111Z","millis":1712173313315,"trade_id":510978124,"last_size":0.15075034}
----- got message -----
key:[null], properties:[], content:{"sequence":77242205012,"product_id":"BTC-USD","price":65791.66,"open_24h":65957.46,"volume_24h":15085.345,"low_24h":64500.0,"high_24h":66944.06,"volume_30d":650213.84849108,"best_bid":65788.94,"best_bid_size":0.00238747,"best_ask":65791.66,"best_ask_size":0.3191051,"side":"buy","time":"2024-04-03T19:41:53.324727Z","millis":1712173313324,"trade_id":626125270,"last_size":0.00741024}
----- got message -----
key:[null], properties:[], content:{"sequence":58026240510,"product_id":"ETH-USD","price":3318.11,"open_24h":3278.83,"volume_24h":103947.71,"low_24h":3202.8,"high_24h":3369.43,"volume_30d":4280222.73668427,"best_bid":3317.77,"best_bid_size":0.7567167,"best_ask":3318.12,"best_ask_size":0.00551561,"side":"sell","time":"2024-04-03T19:41:53.343614Z","millis":1712173313343,"trade_id":510978125,"last_size":0.2}

...
````

Last you need to build and deploy the Python-based [Function](infrastructure%2Fpulsar%2Ffunctions%2Fcoinbase-ticker-stats%2Fsrc%2Fstats.py) 
that calculates various price metrics for the cryptocurrencies using the Pandas library. This can be done in two easy steps. 
First, you need to package the python file along with its dependencies into a zip file using the following command.

```bash
sh ./bin/pulsar/build-ticker-stats.sh

updating: coinbase-ticker-stats/ (stored 0%)
updating: coinbase-ticker-stats/deps/ (stored 0%)
updating: coinbase-ticker-stats/deps/numpy-1.26.4-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (deflated 1%)
updating: coinbase-ticker-stats/deps/python_dateutil-2.9.0.post0-py2.py3-none-any.whl (deflated 1%)
updating: coinbase-ticker-stats/deps/pytz-2024.1-py2.py3-none-any.whl (deflated 25%)
updating: coinbase-ticker-stats/deps/pandas-2.2.2-cp310-cp310-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (deflated 2%)
updating: coinbase-ticker-stats/deps/tzdata-2024.1-py2.py3-none-any.whl (deflated 32%)
updating: coinbase-ticker-stats/deps/six-1.16.0-py2.py3-none-any.whl (deflated 4%)
updating: coinbase-ticker-stats/src/ (stored 0%)
updating: coinbase-ticker-stats/src/stats.py (deflated 71%)
```

Next, you deploy it using the following command:

```bash
sh ./bin/pulsar/start-ticker-stats.sh
```

You can verify that the TickerStats Function is working by running the following command to consume messages from the
Function's configured output topic. If it is working properly, you should see output similar to that shown here:

````
docker exec -it pulsar-broker sh -c   "./bin/pulsar-client consume -n 0 -p Earliest -s my-sub persistent://feeds/realtime/coinbase-ticker-stats"

...
----- got message -----
key:[null], properties:[__pfn_input_msg_id__=CAwQ9B4YAA==, __pfn_input_topic__=persistent://feeds/realtime/coinbase-ticker-partition-0], content:{
 "sequence": 1231277600,
 "product_id": "USDT-USD",
 "price": 1.0005,
 "latest_emwa": 1.000498239928398,
 "latest_std": 4.0152407931263944e-06,
 "latest_variance": 1.6122158626786277e-11,
 "rolling_mean": 1.0004979999999999,
 "rolling_std": 4.472135954755798e-06,
 "rolling_variance": 1.999999999781955e-11,
 "time": "2024-04-15T16:14:21.919683Z",
 "millis": 1713197661919
}
----- got message -----
key:[null], properties:[__pfn_input_msg_id__=CAwQ9R4YAA==, __pfn_input_topic__=persistent://feeds/realtime/coinbase-ticker-partition-0], content:{
 "sequence": 78286110141,
 "product_id": "BTC-USD",
 "price": 64619.98,
 "latest_emwa": 64615.50239556808,
 "latest_std": 2.684163338194109,
 "latest_variance": 7.204732826105343,
 "rolling_mean": 64615.042,
 "rolling_std": 3.143019249066717,
 "rolling_variance": 9.878570000003908,
 "time": "2024-04-15T16:14:21.988357Z",
 "millis": 1713197661988
}
````

Stream Processing with Apache Pinot
--
Store the preprocessed cryptocurrency data in Apache Pinot for real-time analytics and querying. Pinot's low-latency 
querying capabilities enable traders and analysts to retrieve up-to-date insights on market trends, volatility, liquidity, etc.

### 4️⃣ Start Apache Pinot

[Apache Pinot](https://pinot.apache.org/) is a realtime distributed OLAP datastore, designed to answer OLAP queries with low latency. It will serve 
as our analytics engine for this demo.

```bash
sh ./bin/pinot/start-pinot.sh
```

You can verify that the deployment was successful using the following command, and seeing output similar to that
shown here. This indicates that all five Pinot-related containers are running.

````bash
docker ps
CONTAINER ID   IMAGE                                             COMMAND                  CREATED          STATUS                             PORTS                                                       NAMES
9b632d9810b6   apachepinot/pinot:latest-21-openjdk-linux-amd64   "./bin/pinot-admin.s…"   8 seconds ago    Up 6 seconds                       8096-8097/tcp, 8099/tcp, 9000/tcp, 0.0.0.0:8098->8098/tcp   pinot-server
c542a9da108b   apachepinot/pinot-superset:latest                 "/usr/bin/run-server…"   8 seconds ago    Up 6 seconds (health: starting)    0.0.0.0:8088->8088/tcp                                      superset
7a6ac315e086   apachepinot/pinot:latest-21-openjdk-linux-amd64   "./bin/pinot-admin.s…"   8 seconds ago    Up Less than a second              8096-8098/tcp, 9000/tcp, 0.0.0.0:8099->8099/tcp             pinot-broker
7bbe9c77f182   apachepinot/pinot:latest-21-openjdk-linux-amd64   "./bin/pinot-admin.s…"   8 seconds ago    Up 7 seconds                       8096-8099/tcp, 0.0.0.0:9000->9000/tcp                       pinot-controller
4d8201855062   zookeeper:3.5.6                                   "/docker-entrypoint.…"   8 seconds ago    Up 7 seconds                       2888/tcp, 3888/tcp, 0.0.0.0:2181->2181/tcp, 8080/tcp        pinot-zookeeper
````

### 5️⃣ Create the Pinot Table Definitions

Pinot supports consuming data from Apache Pulsar via the pinot-pulsar plugin. In order to expose the Pulsar topics to 
the Pinot analytics engine we need to create a table definition for each Pulsar topic we wish to analyze by running the
following command:

```bash
./bin/pinot/create-pinot-tables.sh

INFO [AddTableCommand] [main] Executing command: AddTable -tableConfigFile /config/coinbase-rfq-match-table-config.json -offlineTableConfigFile null -realtimeTableConfigFile null -schemaFile /config/coinbase-rfq-match-schema.json -controllerProtocol http -controllerHost 172.22.0.6 -controllerPort 9000 -user null -password [hidden] -exec
INFO [AddTableCommand] [main] Executing command: AddTable -tableConfigFile /config/coinbase-ticker-table-config.json -offlineTableConfigFile null -realtimeTableConfigFile null -schemaFile /config/coinbase-ticker-schema.json -controllerProtocol http -controllerHost 172.22.0.6 -controllerPort 9000 -user null -password [hidden] -exec
INFO [AddTableCommand] [main] Executing command: AddTable -tableConfigFile /config/coinbase-ticker-stats-table-config.json -offlineTableConfigFile null -realtimeTableConfigFile null -schemaFile /config/coinbase-ticker-stats-schema.json -controllerProtocol http -controllerHost 172.22.0.6 -controllerPort 9000 -user null -password [hidden] -exec
```

You should see three INFO-level messages in the command output as shown above, indicating that the Tables were successfully 
created. You can confirm that the tables are accessible by using the [Pinot UI](http://localhost:9000/#/tables)

![Pinot-Dashboard.png](doc%2Fimages%2FPinot-Dashboard.png)

You can even run some queries using the Pinot query manager to confirm that the data is correct.

Real-Time Dashboards and Alerts
--
Build interactive dashboards using [Apache Superset](https://superset.apache.org/) to visualize real-time cryptocurrency
market data. These dashboards can display live price charts, order book dynamics, trading volumes, and other key metrics.
Implement alerting mechanisms using Pulsar's messaging capabilities to notify users about significant price movements, 
trading opportunities, or risk events in real-time.

### 6️⃣ Initialize Superset

There is an existing integration for [Apache Pinot and Superset](https://docs.pinot.apache.org/operators/tutorials/build-docker-images#pinot-superset)
that we used in the previous step to launch Apache Superset alongside Apache Pinot. This ensures that the two components
are properly configured to communicate with one another.

By default, Apache Superset is deployed with an admin user, so we will need to run the following command to initialize 
the cluster and create a new `admin` user, that we can use to log into the UI.

```bash
./bin/superset/init-superset.sh
```

In addition to the `Admin User admin created.` output from the above command, we can also verify that we have access to
the [Superset UI](http://localhost:8088/login/) by logging in as the `admin` user, and the password specified in the 
[init-superset.sh](bin%2Fpinot%2Finit-superset.sh) script.

![Superset-Login.png](doc%2Fimages%2FSuperset-Login.png)

### 7️⃣ Import Dashboards

Now that you can access the Superset UI, you are free to create as many DataSets, Charts, and Dashboards as you like. 
You can also import some of the pre-built dashboards from the demo using the following command.

```bash
./bin/pinot/import-dashboards.sh
```

This import includes a simple dataset, chart, and dashboard definition that you can use as a reference for building out 
your own in the future.

![Superset-Dashboards.png](doc%2Fimages%2FSuperset-Dashboards.png)


Requirements
------------

- [Docker](https://www.docker.com/get-started) 4.24+


Ensure you have allocated enough resources to Docker. At least 16GB of RAM, and 8 cores.
Note: *On Macs with ARM chip, enabling Rosetta for amd64 emulation on Docker will make your containers boot faster.*