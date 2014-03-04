require 'Qt'
require 'json'

class SensorInformation < Qt::Widget
	
	def initialize(parent = nil, port, sensor, address, layout)
	        super(parent)
	  
		@port = port
		@sensor = sensor
		
 		@sensor_label = Qt::Label.new("port#{port+1}/#{sensor}", self)
 		@address_label = Qt::Label.new(address, self)
		@room_edit = Qt::LineEdit.new( self )
		@room_edit.setPlaceholderText("room")
		@row_edit = Qt::LineEdit.new( self ) 
		@row_edit.setPlaceholderText("row")
		@rack_edit = Qt::LineEdit.new( self ) 
		@rack_edit.setPlaceholderText("rack")
		@height_edit = Qt::LineEdit.new( self )
		@height_edit.setPlaceholderText("height")
		
		
		last_row = layout.rowCount
		layout.addWidget(@sensor_label, last_row ,0,Qt::AlignTop)
		layout.addWidget(@address_label, last_row ,1,Qt::AlignTop)
		layout.addWidget(@room_edit, last_row ,2,Qt::AlignTop)
		layout.addWidget(@row_edit, last_row ,3,Qt::AlignTop)
		layout.addWidget(@rack_edit, last_row ,4,Qt::AlignTop)
		layout.addWidget(@height_edit, last_row ,5,Qt::AlignTop)
			
	end
	
	def to_hash
	  result = {"port" => @port,
	            "sensor" => @sensor,
	            "room" => @room_edit.text,
	            "row" => @row_edit.text,
	            "rack" => @rack_edit.text,
	            "height" => @height_edit.text}
	end
	
	def remove_from_layout(layout)
	  layout.removeWidget(@sensor_label)
	  layout.removeWidget(@address_label)
	  layout.removeWidget(@room_edit)
	  layout.removeWidget(@row_edit)
	  layout.removeWidget(@rack_edit)
	  layout.removeWidget(@height_edit)       
	end
	

end
