module RBP_UserInput

=begin

Put all methods of the plugin in here,
i.e. Event notification responders

Name should be "RBP_" followed by filename,
without the extension, and in camelcase.

=end
     def user_input input
        case input
        when /^!([a-zA-Z0-9_]+)\s(.+)$/i
            case $1
            when "me"
                @bot.send_action @bot.p["chan"], $2
            when "quit"
                @bot.quit $2
            when "raw"
                @bot.send $2
            when "debug"
                puts "?        #{ eval( $2 ).inspect }"
            end
        else

            @bot.send_privmsg @bot.p["chan"], input

        end
    end

    def self.extended( by )

=begin
        Put all variables used by plugin into here
        to initialise them.
=end

    end

end

# Initialise Plugin itself
$rbp_user_input = Plugin.new(
"User Input", "1.0",
'Deals with the user input '\
'from the user_input event.'
)

=begin

Use init_proc to perform parts of the plugin
initialisation that require the bot to be
initialised itself, i.e, registering to
relevant events.

=end

$rbp_user_input.init_proc { |_self|

    EventManager.add_registrar(_self,
    "bot->user_input")

    _self.load_config( "./config/user_input.conf" )
}

# Include the previously defined methods to the plugin.
$rbp_user_input.extend( RBP_UserInput )
