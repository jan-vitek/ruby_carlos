require 'Qt'
require './sensor_information.rb'
require 'json'

class JsonBox < Qt::Widget
	slots 'updateAddresses(QStringList,int)'
	slots 'setIp(QString)'
	slots 'saveJson(void)'
	slots 'clearBox(void)'
  
	def initialize(parent = nil)
		super
		
		@addresses = [[],[],[],[]]
		@sensors_information = []
		@ip = ""
    @snmp_port = ""
		
		@layout = Qt::GridLayout.new
		setLayout(@layout)

		@parent = self
	end
	
	def updateAddresses(addresses,i)
      Qt.execute_in_main_thread do
	    @addresses[i] = addresses
      end
	  create_fields if i==3
	end
	
	def create_fields
      Qt.execute_in_main_thread do
	    @addresses.each_with_index do |sensors,i|
	      sensors.each_with_index do |sensor,j|
	        @sensors_information.push SensorInformation.new(@parent, i, j, sensor, @layout) unless sensor == "0000000000000000"
	      end
	    end
      end
	end
	
	def clearBox
      Qt.execute_in_main_thread do
 	    @sensors_information.each do |sensor|
 	      puts "removing"
 	      sensor.remove_from_layout(@layout)
 	    end
      end
	end
	
	def setIp(ip)
	  @ip,@snmp_port = ip.split(":")
    @snmp_port = 161 if @snmp_port.nil?
	end
	
	def saveJson
	  file_name = Qt::FileDialog.getSaveFileName
	  unless file_name.nil?
      file_name += ".json" unless file_name[-5..-1] == ".json"
	  result = {"ip" => @ip, "sensors" => []}
	  @sensors_information.each do |sensor|
	    result["sensors"].push sensor.to_hash
	  end
	    File.open(file_name, 'w') do |file|	      
	      file.write(result.to_json)
	    end
	  end
	end
	
	

end
