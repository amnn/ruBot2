require "./Plugin.rb"
require "./em/EventManager.rb"
require "./Configurable.rb"

class IRCBot
	include Configurable

	def initialize
		@plugins = []
		@bot	 = self
		
		EventManager.add_sender(:bot, self)
		EventManager.add_event(:bot, :received_packet)
	end

end

bot = IRCBot.new
bot.load_plugin("./plugins/test_plugin.rb")
