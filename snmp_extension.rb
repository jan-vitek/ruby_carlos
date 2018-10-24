require 'snmp'

class SNMPExtension
  def self.write_config_register(ip, val, port = 161)
    write_snmp_int(ip, '1.3.6.1.4.1.42138.4.20', val, port)
  end
  
  def self.write_snmp_oid(ip, oid, val, value_type, port = 161)
    begin
      puts "Writing value " + val.to_s + " to " + oid + " on " + ip
      SNMP::Manager.open(:host => ip, :port => port) do |manager|
        varbind = SNMP::VarBind.new(oid, value_type.new(val))
        manager.set(varbind)
      end
    rescue
    end
  end
  
  def self.write_snmp_octet_string (ip, oid, val, port = 161)
    write_snmp_oid(ip, oid, val, SNMP::OctetString, port)
  end
  
  def self.write_snmp_int (ip, oid, val, port = 161)
    write_snmp_oid(ip, oid, val, SNMP::Integer, port)
  end
  
  def self.read_snmp_oid(ip, oid, port = 161)
    ret = "";
    puts "test"
#     begin
#       SNMP::Manager.open(:host => ip) do |manager|
# 	      response = manager.get(["10.1.1.1 1.3.6.1.4.1.42138.6.1.0"])
# 	      response.each_varbind do |vb|
# 		puts "#{vb.name.to_s}  #{vb.value.to_s}  #{vb.value.asn1_type}"
# 		ret = vb.value
#               end
#       end
#     rescue
#     end
    begin
	    SNMP::Manager.open(:host => ip, :port => port) do |manager|
	      response = manager.get(["1.3.6.1.4.1.42138.6.1.0"])
	      response.each_varbind do |vb|
		puts "#{vb.name.to_s}  #{vb.value.to_s}  #{vb.value.asn1_type}"
		ret = vb.value
	      end
	    end
    rescue
    end
    
    return ret
  end
  
end
