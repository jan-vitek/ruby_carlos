require 'snmp'

class SNMPExtension
  def self.write_config_register(ip, val)
    write_snmp_int(ip, '1.3.6.1.4.1.42138.4.20', val)
  end
  
  def self.write_snmp_oid(ip, oid, val, value_type)
    begin
      puts "Writing value " + val.to_s + " to " + oid + " on " + ip
      SNMP::Manager.open(:host => ip) do |manager|
        varbind = SNMP::VarBind.new(oid, value_type.new(val))
        manager.set(varbind)
      end
    rescue
    end
  end
  
  def self.write_snmp_octet_string (ip, oid, val)
    write_snmp_oid(ip, oid, val, SNMP::OctetString)
  end
  
  def self.write_snmp_int (ip, oid, val)
    write_snmp_oid(ip, oid, val, SNMP::Integer)
  end
  
  def self.read_snmp_oid
    
  end
  
end
