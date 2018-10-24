require 'snmp'
require 'Qt'
require './snmp_extension.rb'

class ScanAndSave < Qt::Widget
	signals 'angleChanged(int)'
	signals 'clearResult(void)'
	signals 'addLineToResult(QString)'
	signals 'addressesLoaded(QStringList, int)'
    signals 'calibrationOK(int)', 'calibrationFailed(int)'
    signals 'setDHCP(int)'
    signals 'scanningFailed(void)', 'scanningFinished(void)'
	slots 'setIp(QString)','calibrationOK(int)', 'calibrationFailed(int)', 'setDHCP(int)', 'scanningFailed(void)', 'scanningFinished(void)'
	
	def initialize(parent = nil)
		super
		@ip = nil
    @snmp_port = nil
		
		@DHCP_off_button = Qt::PushButton.new("DHCP off", self)		
		@DHCP_on_button = Qt::PushButton.new("DHCP on", self)
				
		@DHCP_off_button.connect(SIGNAL(:clicked)) {
		    Thread.new{dhcp_set(0)}
		}
		
		@DHCP_on_button.connect(SIGNAL(:clicked)) {
		    Thread.new{dhcp_set(1)}  
		}
        
        @flood_button=[]
		
        @flood_button[0] = Qt::PushButton.new("Calibrate flood port 1", self)
        @flood_button[0].set_enabled(false)
        @flood_button[0].connect(SIGNAL(:clicked)) {
            @flood_button[0].setStyleSheet("background-color: rgb(255, 165, 0); color: rgb(0, 0, 0)")
            Thread.new{calibrate_flood(0)}
        }
        
        @flood_button[1] = Qt::PushButton.new("Calibrate flood port 2", self)
        @flood_button[1].set_enabled(false)
        @flood_button[1].connect(SIGNAL(:clicked)) {
            @flood_button[1].setStyleSheet("background-color: rgb(255, 165, 0); color: rgb(0, 0, 0)")
            Thread.new{calibrate_flood(1)}
        }
        
		@reload_button = Qt::PushButton.new("Scan and Write", self)
		@reload_button.set_enabled(false)
		@reload_button.connect(SIGNAL(:clicked)) {
		    emit clearResult()
		    @reload_button.setStyleSheet("background-color: rgb(255, 165, 0); color: rgb(0, 0, 0)")
		    @reload_button.set_enabled(false)
		    puts 'Scan and save'
		    @@addresses = [[],[],[],[]]
		    @values = [[],[],[],[]]
            @scanning_failed=false;
		    Thread.new{scan_and_save}
		}
		
		layout = Qt::GridLayout.new
		
		layout.addWidget(@DHCP_on_button,0,0)
		layout.addWidget(@DHCP_off_button,0,1)
        layout.addWidget(@flood_button[0],1,0)
        layout.addWidget(@flood_button[1],1,1)
		
		layout.addWidget(@reload_button, 2,0)
		
		setLayout(layout)
		
		
	end
    
    def calibrate_flood(port)
        puts "Calibrating flood port " + (port+1).to_s
        res = SNMPExtension::write_snmp_int(@ip, "1.3.6.1.4.1.42138.5.3." + port.to_s, 0, @snmp_port)
        if res.error_index == 0
            emit calibrationOK(port)
        else
            emit calibrationFailed(port)
        end
    end
        
	
	def dhcp_set(val)
	  puts "Setting DHCP"
	  SNMPExtension::write_snmp_int(@ip, "1.3.6.1.4.1.42138.6.1.0", val, @snmp_port)
	  reload_DHCP_colors
	end
	
	def reload_DHCP_colors
    puts "setting DHCP buttons #{@ip}:#{@snmp_port}"
	  res = SNMPExtension::read_snmp_oid(@ip, "1.3.6.1.4.1.42138.6.1.0", @snmp_port)
	  emit setDHCP(res)
	end

	def scan_and_save
	  (1..4).each do |port|
	    scan_1wire(port)
	    print_scan_results(port)
	  end
	  
	  SNMPExtension::write_config_register(@ip, 0, @snmp_port)
	  
	  unless @scanning_failed
	    store_1_wire_addresses 
	    emit_addresses
	  end
      emit scanningFinished()
	end
	
	def emit_addresses
	  @@addresses.each_with_index do |sensors, i|
	    emit addressesLoaded(sensors, i)
	  end
	end
	
	def print_scan_results(port)
	  emit addLineToResult("Port #{port}:")
	  
	  (0..7).each do |i|
	    line = ""
	    (0..3).each do |j|
	      temp_string = "#{8*j+i}: #{@@addresses[port-1][8*j+i]}::#{@values[port-1][8*j+i]} #{(@values[port-1][8*j+i]/16.0).round(1)} °C"
	      line += sprintf "%-30s \t", temp_string
# 	      line += "#{8*j+i}: #{@addresses[port-1][8*j+i]}::#{(@values[port-1][8*j+i]/16.0).round(1)} \t \t"
	    end
	    emit addLineToResult(line)
	  end
	  emit addLineToResult("")
	end
	
	
	def scan_1wire(port)
	  SNMPExtension::write_config_register(@ip, port, @snmp_port)
	  sleep 1
	  address_oids = (0..31).to_a.map { |s| s.to_s.insert(0, "1.3.6.1.4.1.42138.4.21.")}
	  values_oids = (0..31).to_a.map { |s| s.to_s.insert(0, "1.3.6.1.4.1.42138.4.22.")}
          max_rows=32
	  begin
	    SNMP::Manager.open(:host => @ip, :port => @snmp_port) do |manager|
# 	      response = manager.get_bulk(0, 32, "1.3.6.1.4.1.42138.4.21")
 	      (21..22).each do |i|
		(0..31).each do |j|
		  response = manager.get("1.3.6.1.4.1.42138.4.#{i}.#{j}")
		  response.each_varbind do |vb|
# 		  emit addLineToResult("#{vb.name.to_s}  #{vb.value.to_s}  #{vb.value.asn1_type}")
		  i == 21 ? (@@addresses[port-1][j] = vb.value.to_s) : (@values[port-1][j] = vb.value.to_i)
	          end
		end
	      end
	    end
	  rescue
        @scanning_failed=true
	    emit scanningFailed()
	  end
	end
	
	def store_1_wire_addresses
	  begin
	    @@addresses.each_with_index do |sensors, i|
	      emit addLineToResult("Storing Port #{i+1} addresses.")
	      sensors.each_with_index do |sensor, j|
		oid = "1.3.6.1.4.1.42138.4.#{i+6}.#{j}"
		SNMPExtension::write_snmp_octet_string(@ip, oid, sensor, @snmp_port)
	      end
	    end
	    emit addLineToResult("\nDone.\n")
	  rescue
	    emit scanningFailed()
	  end
	  
	end
	
	def setIp(val)
      Qt.execute_in_main_thread do
  	    @reload_button.set_enabled( true )
        @flood_button[0].set_enabled( true )
        @flood_button[1].set_enabled( true )
	      @ip,@snmp_port = val.split(":")
      end
      puts "IP set in ScanAndSave: " + @ip
      Thread.new{reload_DHCP_colors}
	end
    
    def calibrationOK(val)
        Qt.execute_in_main_thread do
          @flood_button[val].setStyleSheet("background-color: rgb(0, 255, 0); color: rgb(255, 255, 255)");
        end
    end
    
    def calibrationFailed(val)
        Qt.execute_in_main_thread do
          @flood_button[val].setStyleSheet("background-color: rgb(255, 0, 0); color: rgb(255, 255, 255)");
        end
    end
	
    def setDHCP(res)
        Qt.execute_in_main_thread do
          if res == 0
              @DHCP_on_button.setStyleSheet("background-color: rgb(255, 0, 0); color: rgb(255, 255, 255)");
              @DHCP_off_button.setStyleSheet("background-color: rgb(0, 255, 0); color: rgb(255, 255, 255)");
          elsif res == 1
              @DHCP_on_button.setStyleSheet("background-color: rgb(0, 255, 0); color: rgb(255, 255, 255)");
              @DHCP_off_button.setStyleSheet("background-color: rgb(255, 0, 0); color: rgb(255, 255, 255)");
          else
              puts "Error while setting color of DHCP buttons, returned value: " + res
          end
        end
    end
    
    def scanningFailed()
        Qt.execute_in_main_thread do
          @reload_button.setStyleSheet("background-color: rgb(255, 0, 0); color: rgb(255, 255, 255)");
          @reload_button.set_enabled(true)
        end
    end

    def scanningFinished()
        Qt.execute_in_main_thread do
          @reload_button.setStyleSheet("background-color: rgb(0, 255, 0); color: rgb(0, 0, 0)");
          @reload_button.set_enabled(true)
        end
    end

end
