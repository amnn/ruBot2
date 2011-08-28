require "./Configurable.rb"

=begin

Plugin Class
 
Used to add functionality to bot
through methods called by events
managed by the event manager cl-
-ass.

=end

# TODO: plugin template generator method

class Plugin
include Configurable

	attr_reader :_name, :_version, :_desc
	attr_accessor :bot, :p

	def initialize name, version, desc

		@_name 		  = name
		@_version 	  = version
		@_description = desc
		
		# Configurable Dependencies
		@bot		  = {}
		@p			  = {}
		
	end

	def init_proc &body
		if body.arity != 1
			raise ArgumentError, "\'init_proc\' Must Accept 1 Argument" 
		end
		
		@init_proc = body
	end

	def loaded
		@init_proc[self]
	end

	class << self
		def new_plugin name
			file_name	= name.downcase.tr(" ", "_")
			
			file_loc	= "./plugins/" + file_name + ".rb"
			conf_loc	= "./config/" + file_name + ".conf"
			
			module_name	= "RBP_" + name.split(" ").each { |w|
															w.capitalize
														}.join("")
			
			var_name	= "$rbp_" + file_name
			
			if File.exists? ( file_loc )
			 raise ArgumentError, "Plugin Already Exists!" 
			end
			
			file_contents = %[
module #{module_name}

=begin

Put all methods of the plugin in here,
i.e. Event notification responders

Name should be "RBP_" followed by filename,
without the extension, and in camelcase.

=end	

	def self.extended( by )
	
=begin
		Put all variables used by plugin into here
		to initialise them.
=end
	
	end

end

# Initialise Plugin itself
#{var_name} = Plugin.new(
"#{name}", :PLUGIN_VERSION,
:PLUGIN_DESCRIPTION)

=begin

Use init_proc to perform parts of the plugin
initialisation that require the bot to be 
initialised itself, i.e, registering to
relevant events.

=end

#{var_name}.init_proc { |_self|
	
	_self.load_config( "#{conf_loc}" )
}

# Include the previously defined methods to the plugin.
#{var_name}.extend( #{module_name} )
]
			
			puts "Writing Plugin file to: #{file_loc}"
			File.open( file_loc, "w" ) { |f| f.puts file_contents }
			
			puts "Writing Configuration file to: #{conf_loc}"
			File.open( conf_loc, "w" ) do |c|
				c.puts "  #{name} Configuration File"
			end
			
		end
	end

end

if $0 == "Plugin.rb"	# If Plugin was called of its own accord
	name = ARGV[0]
	Plugin.new_plugin name
end

