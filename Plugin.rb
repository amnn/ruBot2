# Plugin Class
# 
# Used to add functionality to bot
# through methods called by events
# managed by the event manager cl-
# -ass.

class Plugin

	attr_reader :name, :version, :desc

	def initialize name, version, desc

		@name 		 = name
		@version 	 = version
		@description = desc

	end

	def init_proc &body
		@init_proc = body
	end

	def loaded
		@init_proc[self]
	end

end

rbp_test_plugin = Plugin.new(
 "Test Plugin", "1.0",
 "A Test Plugin to make sure the plugin
\ class works")

rbp_test_plugin.init_proc { |plugin|
	EventManager.add_registrar(plugin,
	"bot->received_packet")
}
