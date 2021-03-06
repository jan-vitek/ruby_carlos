#!/usr/bin/env ruby
$:.unshift File.dirname($0)
#$VERBOSE = true;

require 'thread'
require 'Qt'
require './connection_box.rb'
require './scan_and_save.rb'
require './result_area.rb'
require './json_box.rb'

class MyWidget < Qt::Widget
    def initialize(parent = nil)
        super
        quit = Qt::PushButton.new('Save JSON')
        quit.setFont(Qt::Font.new('Times', 18, Qt::Font::Bold))
    
#         connect(quit, SIGNAL('clicked()'), $qApp, SLOT('quit()'))
	
    
        connection_box = ConnectionBox.new( self )
	
	reload_box = ScanAndSave.new( self )
	
	result_area = ResultArea.new( self )
	
	json_box = JsonBox.new( self )
	json_scroll = Qt::ScrollArea.new( self )
	json_scroll.setWidget( json_box )
 	json_scroll.setWidgetResizable( true )
	
	connect( connection_box, SIGNAL('ipChanged(QString)'), connection_box, SLOT('setConnected(QString)') )
    connect( connection_box, SIGNAL('connectionFailed(void)'), connection_box, SLOT('connectionFailed(void)') )
    connect( connection_box, SIGNAL('newIpSet(void)'), connection_box, SLOT('newIpSet(void)') )
    connect( connection_box, SIGNAL('newIpFailed(void)'), connection_box, SLOT('newIpFailed(void)') )
    connect( connection_box, SIGNAL('ipChanged(QString)'), reload_box, SLOT('setIp(QString)') )
	connect( connection_box, SIGNAL('ipChanged(QString)'), json_box, SLOT('setIp(QString)') )
    
	connect( reload_box, SIGNAL('addLineToResult(QString)'), result_area, SLOT('resultAddLine(QString)'))
	connect( reload_box, SIGNAL('clearResult(void)'), result_area, SLOT('resultClear(void)'))
    connect( reload_box, SIGNAL('calibrationOK(int)'), reload_box, SLOT('calibrationOK(int)'))
    connect( reload_box, SIGNAL('calibrationFailed(int)'), reload_box, SLOT('calibrationFailed(int)'))
    connect( reload_box, SIGNAL('setDHCP(int)'), reload_box, SLOT('setDHCP(int)'))
    connect( reload_box, SIGNAL('scanningFailed(void)'), reload_box, SLOT('scanningFailed(void)'))
    connect( reload_box, SIGNAL('scanningFinished(void)'), reload_box, SLOT('scanningFinished(void)'))
	connect( connection_box, SIGNAL('clearResult(void)'), result_area, SLOT('resultClear(void)'))
	connect( reload_box, SIGNAL('addressesLoaded(QStringList,int)'), json_box, SLOT('updateAddresses(QStringList,int)'))
	connect( quit, SIGNAL('clicked()'), json_box, SLOT('saveJson()'))
	connect( reload_box, SIGNAL('clearResult(void)'), json_box, SLOT('clearBox(void)'))

#         cannonField = CannonField.new( self )

#         connect( angle, SIGNAL('valueChanged(int)'),
#                 cannonField, SLOT('setAngle(int)') )
#         connect( cannonField, SIGNAL('angleChanged(int)'),
#                 angle, SLOT('setValue(int)') )

        layout = Qt::VBoxLayout.new
        
        layout.addWidget( connection_box )
	layout.addWidget( reload_box )
	layout.addWidget( result_area )
	layout.addWidget( json_scroll ) 
        layout.addWidget( quit )
	
	setLayout( layout )

    end
end    

a = Qt::Application.new(ARGV)

w = MyWidget.new
w.setGeometry( 100, 100, 500, 355 )
w.show
a.exec
