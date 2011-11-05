=begin

Configurable module

adds ability to load plugins
and read config files.

=end

module Configurable

=begin

Dependencies:

Instances extended by this module must have an @bot instance variable.
Instances extended by this module must also have a @p hash

=end

    def load_plugin filename
        raise ArgumentError, "No Such Plugin" if !File.exists? filename

        if filename =~ /([a-zA-Z0-9_]+)\.rb$/i
            var_name = "$rbp_" + $1
        else
            raise ArgumentError, 'Plugin name in incorrect ' \
                                 'format, \'#{ filename }\''
        end

        require filename
        if eval( "defined? #{var_name}" ).nil?
            raise ArgumentError, 'Plugin variable not defined ' \
                                 'in correct format: \'#{var_name}\''
        end

        plugin = eval( var_name )

        if !(@bot.plugins.include? plugin)
            plugin.bot = @bot
            plugin.loaded
        end

        @bot.plugins = @bot.plugins | [plugin]
    end

    def parse_config_line line

        case line
        when /^\+\s*(.+)/i # Load Plugin
            load_plugin $1
        when /^\*\s*(.+)/i # Load Config
            load_config $1
        when /^\@\s*([a-zA-Z0-9_]+)\s*\=\s*(.+)/i   # Set Local Property
            @p[$1]     = eval $2
        when /^\@\@\s*([a-zA-Z0-9_]+)\s*\=\s*(.+)/i # Set Bot Property
            @bot.p[$1] = eval $2
        end

    end

    def load_config filename
        raise ArgumentError, "No Such Config" if !File.exists? filename

        File.open( filename ) do |f|
            f.each_line { |l| parse_config_line l }
        end

    end

end
