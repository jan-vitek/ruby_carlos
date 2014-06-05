require 'snmp'
require 'Qt'
class ConnectionBox < Qt::Widget
	signals 'ipChanged(QString)'
	signals 'clearResult(void)'
	slots 'setValue(int)', 'setRange(int, int)'

	def initialize(parent = nil)
		super
		@ip_box = Qt::LineEdit.new("10.1.1.1", self)
		@connect_button = Qt::PushButton.new( "Connect", self )
		@connect_button.setStyleSheet("background-color: rgb(255, 0, 0); color: rgb(255, 255, 255)");
		
		
		@connect_button.connect(SIGNAL(:clicked)) {
		  emit clearResult()
		  @connect_button.setStyleSheet("background-color: rgb(255, 165, 0); color: rgb(0, 0, 0)")
		  @apply_button.set_enabled(false)
		  puts 'Connecting: ' + @ip_box.text
		  Thread.new{loadAddressOID}
		}
		
		
		@new_ip_box = Qt::LineEdit.new(self)
		@new_ip_box.setPlaceholderText("New IP address")
		@apply_button = Qt::PushButton.new( "Write value", self )
		@apply_button.set_enabled(false)
		
		@apply_button.connect(SIGNAL(:clicked)) { 
		  @apply_button.setStyleSheet("background-color: rgb(255, 165, 0); color: rgb(0, 0, 0)")
		  puts 'Connecting: ' + @ip_box.text
		  Thread.new{saveNewIP}
		}
		
		layout = Qt::GridLayout.new
		
 		layout.addWidget(@ip_box,1,0)
		layout.addWidget(@connect_button,1,1)
		
	
		layout.addWidget(@new_ip_box,2,0)
		layout.addWidget(@apply_button,2,1)
		
		setLayout(layout)
		
		
	end

	
	def loadAddressOID
	  begin
	    SNMP::Manager.open(:host => @ip_box.text) do |manager|
	      response = manager.get(["1.3.6.1.4.1.42138.1.2.1.1.1.0"])
	      response.each_varbind do |vb|
		puts "#{vb.name.to_s}  #{vb.value.to_s}  #{vb.value.asn1_type}"
		@connect_button.setStyleSheet("background-color: rgb(0, 255, 0); color: rgb(0, 0, 0)");
		@apply_button.set_enabled(true)
		emit ipChanged(@ip_box.text)
	      end
	    end
	  rescue
	    @connect_button.setStyleSheet("background-color: rgb(255, 0, 0); color: rgb(255, 255, 255)");
	  end
	end
	
	def saveNewIP
	  puts "Writing a value to " + @ip_box.text
	  begin
	    SNMP::Manager.open(:host => @ip_box.text) do |manager|
	      varbind = SNMP::VarBind.new("1.3.6.1.4.1.42138.6.0.0", SNMP::IpAddress.new(@new_ip_box.text))
	      manager.set(varbind)
	    end
	    @connect_button.setStyleSheet("background-color: rgb(255, 0, 0); color: rgb(255, 255, 255)");
	    @apply_button.setStyleSheet("background-color: rgb(0, 255, 0); color: rgb(0, 0, 0)");
	    @apply_button.set_enabled(false)
	  rescue
	    @apply_button.setStyleSheet("background-color: rgb(255, 0, 0); color: rgb(255, 255, 255)");
	  end
	end
end
