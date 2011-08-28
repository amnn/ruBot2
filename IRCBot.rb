require "./Plugin.rb"
require "./em/EventManager.rb"

class IRCBot



	def initialize
		@plugins = []
		EventManager.add_sender(:bot, self)
		EventManager.add_event(:bot, :received_packet)
	end


	def load_plugin filename
		raise ArgumentError, "No Such Plugin" if !File.exists? filename
		
		if filename =~ /^(?:.+\/)?([a-zA-Z0-9_]+)\.rb$/i
			var_name = "$rbp_" + $1
		else
			raise ArgumentError, "Plugin name in incorrect format, \'#{ filename }\'"
		end
		
		require filename
		if eval( "defined? #{var_name}" ).nil?
			raise ArgumentError, "Plugin variable not defined in correct format: \'#{var_name}\'"
		end

		plugin = eval( var_name )
		plugin.loaded

		@plugins = @plugins | [plugin]
	end

end

bot = IRCBot.new
bot.load_plugin("./plugins/test_plugin.rb")
