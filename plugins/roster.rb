
module RBP_Roster

=begin

Put all methods of the plugin in here,
i.e. Event notification responders

Name should be "RBP_" followed by filename,
without the extension, and in camelcase.

=end

    def join user
    
        @bot.p["roster"][user]    = 0
        EventManager.broadcast( :joined_channel, self, user )
        @bot.send "WHOIS #{ user }"
        
    end
    
    def part user
    
        EventManager.broadcast( :parted_channel, self, user )
        @bot.p["roster"].delete user
    
    end
    
    def quit user
    
        EventManager.broadcast( :parted_channel, self, user )
        @bot.p["roster"].delete user
    
    end
    
    def mode user, direction, flag
    
        @bot.send "WHOIS #{ user }"
    
    end
    
    def nick from, to
    
        @bot.p["roster"][to] = @bot.p["roster"][from]
        @bot.p["roster"].delete from
    
    end
    
    def process_name name
        
        if @levels.key? name[0...1]
            @bot.p["roster"][name[1..-1]] = @levels[name[0...1]]
            @bot.send "WHO #{ name[1..-1] }"
        else
            @bot.p["roster"][name]        = 0
            @bot.send "WHO #{ name }"
        end
        
    end
    
    def received_packet p
        
        case p
        when /353.*#{ @bot.p['chan'] }\s:(.+)$/i # NAMES
            names = $1.split " "
            
            names.each { |name| process_name name }
            
        when /352\s(?:\S+\s){5}(\S+)\s(?:H|G)(r?)/i # WHO
            name    = $1
            r       = $2
            
            if (@bot.p["roster"][name] == 0) || @bot.p["roster"][name].nil?
                @bot.p["roster"][name] = 0
                @bot.p["roster"][name] = 1 if r == "r"
                EventManager.broadcast(:registered_user, self, name) if r == "r"
            end
            
        when /319\s\S+\s(\S+)\s:.*((?:~|&|@|%|\+)?)#{ @bot.p['chan'] }\s/i # WHOIS
        
            name    = $1
            flag    = $2
            
            process_name (flag + name)
            
        end
    end
    
	def self.extended( by )
	
=begin
		Put all variables used by plugin into here
		to initialise them.
=end
        
        by.instance_variable_set(   :@levels, 
                                    {   "~" =>  10, "&" =>  8, 
                                        "@" =>  5,  "%" =>  4,
                                        "+" =>  3
                                    }
                                )
	
	end

end

# Initialise Plugin itself
$rbp_roster = Plugin.new(
"Roster", "1.0",
'Plugin to keep track of '\
'all users in the channel, '\
'and their permissions.')

=begin

Use init_proc to perform parts of the plugin
initialisation that require the bot to be 
initialised itself, i.e, registering to
relevant events.

=end

$rbp_roster.init_proc { |_self|
	
	_self.bot.p["roster"]   = {}
	
	EventManager.add_sender( :roster, _self )
	EventManager.add_event( :roster, :joined_channel )
	EventManager.add_event( :roster, :registered_user )
	EventManager.add_event( :roster, :parted_channel )
	
	EventManager.add_registrar( _self,
	"base->join" ,
	"base->part" ,
	"base->quit" ,
	"base->mode" ,
	"base->nick" ,
	"bot->received_packet" )
	
	_self.load_config( "./config/roster.conf" )
}

# Include the previously defined methods to the plugin.
$rbp_roster.extend( RBP_Roster )
