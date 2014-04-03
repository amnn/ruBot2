module RBP_Topic

=begin

Put all methods of the plugin in here,
i.e. Event notification responders

Name should be "RBP_" followed by filename,
without the extension, and in camelcase.

=end

    def public_command user, name, args

        if name == "topic"
            @bot.send "TOPIC #{ @bot.p['chan'] } :#{ args }"
        end

=begin
        Put all variables used by plugin into here
        to initialise them.
=end

    end

end

# Initialise Plugin itself
$rbp_topic = Plugin.new(
"Topic", :PLUGIN_VERSION,
:PLUGIN_DESCRIPTION)

=begin

Use init_proc to perform parts of the plugin

initialisation that require the bot to be
initialised itself, i.e, registering to
relevant events.

=end

$rbp_topic.init_proc { |_self|
    
    EventManager.add_registrar(_self, "base->public_command")
    
}

# Include the previously defined methods to the plugin.
$rbp_topic.extend( RBP_Topic )
