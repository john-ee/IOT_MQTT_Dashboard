require 'mqtt'

# Set your MQTT server
MQTT_SERVER = 'mqtt://localhost'

# Set the MQTT topics you're interested in and the tag (data-id) to send for dashing events
MQTT_TOPICS = { 'light' => 'light',
                'temperature' => 'temp',
		'humidity' => 'hum',
              }

points = []
(1..5).each do |i|
  points << {x: i*2, y: 0 }
end

# Start a new thread for the MQTT client
Thread.new {
  MQTT::Client.connect(MQTT_SERVER) do |client|
    client.subscribe( MQTT_TOPICS.keys )

    # Sets the default values to 0 - used when updating 'last_values'
    current_values = Hash.new(0)

    client.get do |topic,message|
      if topic == 'light'
        time = points.last[:x]+2
	points.shift
	points << { x: time, y: Integer(message) }
	send_event('light', points: points)
      else
        tag = MQTT_TOPICS[topic]
        last_value = current_values[tag]
        current_values[tag] = message
        send_event(tag, { value: message, current: message, last: last_value })
      end
    end
  end
}
