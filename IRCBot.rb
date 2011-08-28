require "openssl"
require "socket"

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
		EventManager.add_event(:bot, :user_input)
		
	end
	
	def connect
		
		mandatory = ["addr", "port", "nick", "realname", "chan"]
		raises = mandatory.inject(false){ |bl,arg| bl || !@p.key?(arg) }
	
		if raises
			raise ArgumentError, 'Missing mandatory bot property, one '\
			'of: addr, port, nick, chan, realname. In provided '\
			'configuration file'
		end
		
		_sock	= TCPSocket.new @p["addr"], @p["port"]
		
		if @p["ssl"]
			ctx		= OpenSSL::SSL::SSLContext.new
			@sock 	= OpenSSL::SSL::SSLSocket.new _sock, ctx
			@sock.connect
		else
			@sock	= _sock
		end
		
		send "NICK #{ @p['nick'] }"
		send "USER #{ @p['nick'] } 0 * :#{ @p['realname'] }"
		
	end
	
	def start
		connect
		loop do
			
			reqs	= select([@sock,$stdin], nil, nil, nil)
			next unless reqs
			
			for r in reqs[0]
				if		r == $stdin
					return if $stdin.eof?
					r 	  = $stdin.gets
					
					EventManager.broadcast(:user_input, self, r)
				elsif	r == @sock
					return if @sock.eof?
					r = @sock.gets
					
					EventManager.broadcast(:received_packet, self, r)
				end
			end
		
		end
	end
	
	def send packet
	
		puts "--> #{ packet }"
		@sock.puts packet
	
	end
	
	def send_privmsg to, msg
		
		send "PRIVMSG #{ to } :#{ msg }"
	
	end
	
	def send_action to, action
		send_privmsg to, "\u0001"+"ACTION #{ action }"
	end

	def quit msg
	
		msg ||= "Session closed"
		send "PART #{ @p['chan'] } :#{ msg }"
		send "QUIT"
		
		Kernel.exit
		
	end
	
end

bot = IRCBot.new
bot.load_config "./config/bot.conf"
bot.start
