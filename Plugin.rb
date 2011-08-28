require "./Configurable.rb"

=begin

Plugin Class
 
Used to add functionality to bot
through methods called by events
managed by the event manager cl-
-ass.

=end

class Plugin
include Configurable

	attr_reader :_name, :_version, :_desc

	def initialize name, version, desc

		@_name 		  = name
		@_version 	  = version
		@_description = desc

	end

	def init_proc &body
		raise ArgumentError, "\'init_proc\' Must Accept 1 Argument" if body.arity != 1
		@init_proc = body
	end

	def loaded
		@init_proc[self]
	end

end
