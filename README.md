# Real-Time-Cryptocurrency-Analytics

A real-time analytics platform for cryptocurrency trading or monitoring. This platform needs to handle high-frequency 
updates of cryptocurrency prices, trading volumes, market sentiment, etc., and provide real-time analytics and insights 
to traders, investors, and analysts.


Data Ingestion with Apache Pulsar
--
Use Apache Pulsar to ingest real-time cryptocurrency data streams from various exchanges, APIs, or blockchain networks.
Pulsar's scalability and durability ensure that all market data updates are captured reliably and in real-time.


Real-Time Processing with Apache Pulsar Functions
--
Utilize Pulsar Functions to perform lightweight processing on the incoming cryptocurrency data streams.
Functions can filter, aggregate, and enrich the data, extracting relevant information such as price changes, trade 
volumes, and market sentiment indicators.

Stream Processing with Apache Pinot
--
Store the preprocessed cryptocurrency data in Apache Pinot for real-time analytics and querying.
Pinot's low-latency querying capabilities enable traders and analysts to retrieve up-to-date insights on market trends, 
volatility, liquidity, etc.

Real-Time Dashboards and Alerts
--
Build interactive dashboards using Pinot's SQL interface to visualize real-time cryptocurrency market data.
These dashboards can display live price charts, order book dynamics, trading volumes, and other key metrics.
Implement alerting mechanisms using Pulsar's messaging capabilities to notify users about significant price movements, 
trading opportunities, or risk events in real-time.

