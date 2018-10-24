require 'snmp'
while true
SNMP::Manager.open(:host => @ip, :port => @snmp_port) do |manager|
    response = manager.get(["1.3.6.1.4.1.42138.5.1.0"])
    response.each_varbind do |vb|
        if vb.value.to_i == 0
          puts "Flood1: OK"
        else
          puts "Flood1: #{ ( (1-(vb.value.to_f/2**32))*10000 ).round / 100.0}%"
        end
    end
end
sleep 1
end
