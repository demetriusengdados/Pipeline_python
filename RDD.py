import org.apache.spark.eventhubs._
import org.apache.spark.sql.DataFrame
import org.apache.spark.sql.streaming.Trigger

// EventHubs connection string
val endpoint = "Endpoint=sb://SAMPLE;SharedAccessKeyName=KEY_NAME;SharedAccessKey=KEY;"
val eventHub = "EVENTHUBS_NAME"
val consumerGroup = "CONSUMER_GROUP"
val connectionString = ConnectionStringBuilder(endpoint)
  .setEventHubName(eventHub)
  .build

// Eventhubs configuration
val ehConf = EventHubsConf(connectionString)
  .setStartingPosition(EventPosition.fromEndOfStream)
  .setConsumerGroup(consumerGroup)
  .setMaxEventsPerTrigger(500)

// read stream
val ehStream = spark.readStream
  .format("eventhubs")
  .options(ehConf.toMap)
  .load

ehStream.writeStream
  .trigger(Trigger.ProcessingTime("5 seconds"))
  .foreachBatch { (ehStreamDF,_) => 
      handleEhDataFrame(ehStreamDF)
  }
  .start
  .awaitTermination


def handleEhDataFrame(ehStreamDF : DataFrame) : Unit = {
  val totalSize = ehStreamDF.map(s => s.length).reduce((a, b) => a + b)
  val eventCount = ehStreamDF.count
  println("Batch contained " + eventCount + " events with total size of " + totalSize)
}