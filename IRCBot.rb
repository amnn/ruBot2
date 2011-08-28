require "./Plugin.rb"
require "./em/EventManager.rb"
require "./Configurable.rb"

=begin

IRCBot class

Main class for ruBot2, handles socket io
and sends events through event manager
class.

=end

class IRCBot
	include Configurable

	attr_accessor :plugins, :bot, :p
	
	def initialize
		@plugins = []
		@bot	 = self
		@p		 = {} # Config Sandbox
		EventManager.add_sender(:bot, self)
		EventManager.add_event(:bot, :received_packet)
	end
	
	def connect
	
	end
	
	def start
	
	end
	
	def send msg
	
	end
	
	def send_privmsg to, msg
	
	end
	
	def send_action to, action
	
	end

	def part msg
	
	end
	
	def quit msg
	
	end
	
end

bot = IRCBot.new
bot.load_config "./config"

