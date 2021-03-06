require 'snmp'
require 'Qt'
class ConnectionBox < Qt::Widget
	signals 'ipChanged(QString)'
	signals 'clearResult(void)'
    signals 'connectionFailed(void)'
    signals 'newIpSet(void)'
	slots 'setValue(int)', 'setRange(int, int)', 'setConnected(QString)', 'connectionFailed(void)', 'newIpSet(void)', 'newIpFailed(void)'

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
          @ip,@snmp_port = @ip_box.text.split(":")
          @snmp_port = 161 if @snmp_port.nil?
		  Thread.new{loadAddressOID}
		}
		
		
		@new_ip_box = Qt::LineEdit.new(self)
		@new_ip_box.setPlaceholderText("New IP address")
		@apply_button = Qt::PushButton.new( "Write value", self )
		@apply_button.set_enabled(false)
		
		@apply_button.connect(SIGNAL(:clicked)) { 
		  @apply_button.setStyleSheet("background-color: rgb(255, 165, 0); color: rgb(0, 0, 0)")
          @new_ip = @new_ip_box.text
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
        puts "testtttt"
	  begin
	    SNMP::Manager.open(:host => @ip, :port => @snmp_port) do |manager|
	      response = manager.get(["1.3.6.1.4.1.42138.1.2.1.1.1.0"])
	      response.each_varbind do |vb|
		  puts "#{vb.name.to_s}  #{vb.value.to_s}  #{vb.value.asn1_type}"
          emit ipChanged("#{@ip}:#{@snmp_port}")
	      end
	    end
	  rescue
        emit connectionFailed()
	  end
	end
	
	def saveNewIP
	  puts "Writing a value to " + @ip
	  begin
	    SNMP::Manager.open(:host => @ip, :port => @snmp_port) do |manager|
	      varbind = SNMP::VarBind.new("1.3.6.1.4.1.42138.6.0.0", SNMP::IpAddress.new(@new_ip))
	      manager.set(varbind)
	    end
        emit connectionFailed()
        emit newIpSet()
	  rescue
	    emit newIpFailed()
	  end
	end
    
    def setConnected(val)
        Qt.execute_in_main_thread do
          @connect_button.setStyleSheet("background-color: rgb(0, 255, 0); color: rgb(0, 0, 0)");
          @apply_button.set_enabled(true)
        end
    end
    
    def connectionFailed
        Qt.execute_in_main_thread do
          @connect_button.setStyleSheet("background-color: rgb(255, 0, 0); color: rgb(255, 255, 255)");
          @apply_button.set_enabled(false)
        end
    end
    
    def newIpSet
        Qt.execute_in_main_thread do
          @apply_button.setStyleSheet("background-color: rgb(0, 255, 0); color: rgb(0, 0, 0)");
        end
    end
    
    def newIpFailed
        Qt.execute_in_main_thread do
          @apply_button.setStyleSheet("background-color: rgb(255, 0, 0); color: rgb(0, 0, 0)");
        end
    end
end
