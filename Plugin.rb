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
		raise ArgumentError, "\'init_proc\' Must Accept 1 Argument" if body.arity != 1
		@init_proc = body
	end

	def loaded
		@init_proc[self]
	end

end
