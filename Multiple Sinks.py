import org.apache.spark.eventhubs._
import org.apache.spark.sql.DataFrame
import org.apache.spark.sql.streaming.Trigger

// EventHub connection string
val endpoint = "Endpoint=sb://SAMPLE;SharedAccessKeyName=KEY_NAME;SharedAccessKey=KEY;"
val src_eventHub = "SRC_EVENTHUBS_NAME"
val dst_eventHub = "DST_EVENTHUBS_NAME"
val consumerGroup = "CONSUMER_GROUP"
val src_connectionString = ConnectionStringBuilder(endpoint)
  .setEventHubName(src_eventHub)
  .build
val dst_connectionString = ConnectionStringBuilder(endpoint)
  .setEventHubName(dst_eventHub)
  .build

// Eventhub configuration
val src_ehConf = EventHubsConf(src_connectionString)
  .setStartingPosition(EventPosition.fromEndOfStream)
  .setConsumerGroup(consumerGroup)
  .setMaxEventsPerTrigger(500)
val dst_ehConf = EventHubsConf(dst_connectionString)

// read stream
val ehStream = spark.readStream
  .format("eventhubs")
  .options(src_ehConf.toMap)
  .load
  .select($"body" cast "string")
  
// eventhub write stream
val wst1 = ehStream.writeStream
  .format("org.apache.spark.sql.eventhubs.EventHubsSourceProvider")
  .options(dst_ehConf.toMap)
  .option("checkpointLocation", "/checkpointDir") 
  .trigger(Trigger.ProcessingTime("10 seconds"))
  .start()

// console write stream
val wst2 = ehStream.writeStream
  .outputMode("append")
  .format("console")
  .option("truncate", false)
  .option("numRows",10)
  .trigger(Trigger.ProcessingTime("10 seconds"))
  .start()

wst1.awaitTermination()
wst2.awaitTermination()