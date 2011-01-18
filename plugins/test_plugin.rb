# require "../Plugin.rb"
# require "../em/EventManager.rb"

module RBP_TestPlugin						# Put all methods of the plugin in here
											# Name should be "RBP_" followed by filename,
											# without the extension, and in camel-case.
	def self.extended( by )					# Put all variables used by plugin into here
	end										# to initialise them

	def received_packet						# E.g. event notification responders
		
		puts "Event Working"

	end
end

$rbp_test_plugin = Plugin.new(				# Initialise plugin itself
"Test Plugin", "1.0",						# with a name, version and description
"Plugin to test the functionality\
 of the plugin architecture")				# Variable name should be "rbp_" followed by the
											# file name, without the file extension
$rbp_test_plugin.init_proc { |_self|			# Use init_proc to register to relevant events
	EventManager.add_registrar(_self,
	"bot->received_packet")
}

$rbp_test_plugin.extend( RBP_TestPlugin )	# Include the previously defined methods to the plugin
