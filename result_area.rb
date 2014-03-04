require 'snmp'
require 'Qt'
require './snmp_extension.rb'

class ResultArea < Qt::Widget
	signals 'angleChanged(int)'
	slots 'resultAddLine(QString)'
	slots 'resultClear(void)'
	
	def initialize(parent = nil)
		super
		@result_area = Qt::TextEdit.new(self)
		@result_area.readOnly = true
		
		
		layout = Qt::GridLayout.new
		
		layout.addWidget(@result_area, 0,0)
		
		setLayout(layout)
			
	end

	def resultAddLine(line)
          @result_area.append(line)
	end
	
	def resultClear
	  @result_area.clear
	end
	

end
