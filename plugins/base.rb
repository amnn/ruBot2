
module RBP_Base

=begin

Put all methods of the plugin in here,
i.e. Event notification responders

Name should be "RBP_" followed by filename,
without the extension, and in camelcase.

=end	

	def received_packet p
		case p
		when /^PING :(.+)$/i												# ping
			
			puts "-         #{$1}"
			@bot.send "PONG :#{$1}"
		
			@bot.send "JOIN #{ @bot.p['chan'] }" if @first_ping
			@first_ping	= false
			
		when /^:(.+)!.*\sPRIVMSG\s(.+)\s:(.+)/i								# privmsg
			
			msg			= $3
			dest		= $2
			user		= $1
			
			isCommand 	= msg =~ /^!([a-zA-Z0-9_]+)\s(.+)?/i 
			
			if isCommand
				cmd		= $1
				args	= dest == $2 ? nil : $2
				events	= [:public_command, :private_command]
				params	= [ user, cmd, args]
			else
				events	= [:public_privmsg, :private_privmsg]
				params	= [user, msg]
			end
			
			if 		dest == @bot.p["chan"] 	# public
			
				if isCommand
					puts "!        [#{ user }]\t#{ cmd }( #{ args } )"
				else
					puts "*        (#{ user })\t#{ msg }"
				end
				
				EventManager.broadcast( events[0], 
										self, *params 
									  )
				
			elsif 	dest == @bot.p["nick"]	# private
			
				if isCommand
					puts "\n!!       [#{ user }]\t#{ cmd }( #{ args } )\n\n"
				else
					puts "\n%        #{ user }:\t#{ msg }\n\n"
				end
			
				EventManager.broadcast( events[0], 
										self, *params 
									  )
				
			end	
			
		when /^:(.+)!.*\sJOIN/i												# join
			
			puts ">        #{ $1 }"
			EventManager.broadcast( :join, self, $1 )
			
		when /^:(.+)!.*\sPART/i												# part
		
			puts "<        #{ $1 }"
			EventManager.broadcast( :part, self, $1 )
		
		when /^:(.+)!.*\sQUIT/i												# quit
		
			puts "<<       #{ $1 }"
			EventManager.broadcast( :quit, self, $1 )
		
		when /^:.+!.*\sMODE\s#{ @bot.p["chan"] }\s(\+|-)(q|a|o|h|v)\s(.+)$/i	# mode
		
			puts "#{ $1 }#{ $2 }       #{ $3 }"
			EventManager.broadcast( :mode, self, $3, $1, $2 )
		
		when /^:(.+)!.*\sNICK\s:(.+)$/i										# nick
		
			puts "-        #{ $1 } --> #{ $2 }"
			EventManager.broadcast( :nick, self, $1, $2 )
		
		end
	end

	def self.extended( by )
	
=begin
		Put all variables used by plugin into here
		to initialise them.
=end
	
		by.instance_variable_set(:@first_ping, true)
	
	end

end

# Initialise Plugin itself
$rbp_base = Plugin.new(
"Base", "1.0",
'This module handles all basic '\
'IRCBot features including: PING, '\
'PRIVMSG (public and private), '\
'JOIN, PART, QUIT, MODE, NICK, '\
'and commands.')

=begin

Use init_proc to perform parts of the plugin
initialisation that require the bot to be 
initialised itself, i.e, registering to
relevant events.

=end

$rbp_base.init_proc { |_self|

	EventManager.add_sender( :base, _self )
	EventManager.add_event( :base, :public_privmsg )
	EventManager.add_event( :base, :private_privmsg )
	EventManager.add_event( :base, :public_command )
	EventManager.add_event( :base, :private_command )
	EventManager.add_event( :base, :join )
	EventManager.add_event( :base, :part )
	EventManager.add_event( :base, :quit )
	EventManager.add_event( :base, :mode )
	EventManager.add_event( :base, :nick )

	EventManager.add_registrar( _self,
	"bot->received_packet" )
	
	_self.load_config( "./config/base.conf" )
}

# Include the previously defined methods to the plugin.
$rbp_base.extend( RBP_Base )
