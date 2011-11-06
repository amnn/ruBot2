# ruBot2

ruBot2 is a completely modular IRC robot, written in ruby.
All of ruBot's functionality is written in its plugins.

## Features

* Plugin and configuration loading.
* Connecting and Maintaining a Connection.
* SSL support.
* Keeping track of users and their privileges.

## To Be Implemented

* Admin Plugin
  * Register/Identify with NickServ.
  * Kick/Ban/Unban/Tempban
  * Topic/AppendTopic
* Logging Plugin
* Anti-Flooding Plugin
* Banned Phrases Plugin w/Regexp Support

## Usage

To download and start the bot for the first time:

1. Download the latest version from above.
2. Save to any directory. (In this example I chose `~/ruBot2/`)
3. Browse to the directory, open the `config` directory within,
   and open the `bot.conf` file, in your favourite editor: 
   `emacs bot.conf`.
4. The configuration file should be self-explanatory, if it isn't,
   here's an explanation:
     * `@@ ssl` is a true/false value, it tells the bot whether or not
	   you want to connect with SSL.
	 * `@@ addr` is the address of the server, (i.e. for Freenode, it
	   would be "irc.freenode.net")
	 * `@@ port` is the port that you're connecting on, default for
	   IRC is 6667, or 7000 if it is with SSL.
	 * `@@ nick` is the nickname of the bot, and what will show up in
	   the IRC channel.
	 * `@@ realname` is the "name" of the bot that will be given if
	   somebody performs a WHOIS request on the bot.
	 * `@@ chan` is the channel that the bot will join once it connects
	   to the server.
	 * `@@ nick_email` and `@@ nick_pass` are for identifying the bot
	   with nickserv.
   Those are all the properties. Everything below that, is for plugins,
   which will be covered later. There are also other configuration files,
   for the various modules, but they do not need to be modified before
   first connecting the bot.
5. Once you have configured the bot, you can connect to your server.
6. First, open terminal, and type `cd ~/ruBot2/`. (Or the directory 
   you chose when you downloaded it).
7. The command to start the bot is `ruby IRCBot.rb`. If all goes well,
   the following should appear on your screen:

> --\> NICK sQBot
> --\> USER sQBot 0 * :Squirrel Bot
> -         irc.ctrlalttroll.com
> --\> PONG :irc.ctrlalttroll.com
> --\> JOIN #lobby
> \>        sQBot

   Where "sQBot", "Squirrel Bot", "irc.ctrlalttroll.com" and "#lobby"
   are replaced with what you put in to the configuration file.
 
Once you have started the bot up, there are various commands that can be
run from the terminal:

* `!me <ACTION>` will send a CTCP ACTION to the channel
* `!quit <QUIT_MSG>` will disconnect the bot from the server, with the
  given quit message.
* `!raw <PACKET>` will send the assigned string to the server as a packet
  (Mainly for debugging purposes).
* `!debug <EXPR>` will run the given ruby expression, inside the bot's
  environment, and will print the result. (Mainly for debugging purposes).
* `<MSG>` will send a message to the channel, from the bot.

## Plugins

Functionality is added by installing plugins. By default, if you create
a plugin, it will be put in to the /plugins/ directory. Creating a new
plugin is a simple process:

1. Browse to the root directory of the bot in a terminal session.
2. Type `ruby Plugin.rb <PLUGIN_NAME>`.

If the request was successful, the script will say that it has written
the plugin file and the configuration file, in the appropriate directories.

The "bot.conf" file explains how to write a configuration file, and the
newly created plugin file will have all the details about creating a
plugin. If you need more assistance, you can look at the already provided
plugins, (Base, UserInput and Roster), or check the Further Questions
section of this README.

Once you have created a plugin, or if you have a plugin already, that you
would like to install, you can install it by putting its config file in
the "./config/" folder, the plugin itself in the "./plugins/" folder and
then finally, by adding the line `+  ./plugins/plugin_name.rb` in to the
bot.conf file, so that it will be loaded when the bot starts.

## Configuration

The syntax for the config files is a new one, but it is relatively easy to
understand.

* Any line that begins with a space, is a comment
* A line begining with `+` followed by a file location will load the plugin
  found at that location. This command is available from any configuration
  file (The bot's configuration file, or plugin specific ones), but it will
  always load the plugin in the bot's environment. This facilitates plugins
  that are dependant on others (i.e. All plugins are dependant on the base
  plugin, so as a matter of good practise, they should all attempt to load
  it when they start). Loading the same plugin multiple times is not an
  issue, it will only be loaded once in to the environment.
* A line beginning with `*` followed by a file location, loads another
  configuration file. This file location must be relative to the bot, and
  not the configuration file.
* `@@` at the beginning of the line is used for a bot property. The format
  is the same as for the plugin property, detailed below. However, this
  form of property should only be used to add properties that are needed
  across multiple plugins, or by the bot in particular (i.e. the address,
  nickname, port and channel, as found in the bot.conf file).
* A single `@` at the beginning of a line signifies a plugin property. All
  plugins have a 'sandbox' where all their properties are held. this command
  will add a variable to that sandbox. this line always follows the same
  syntax: `@ identifier = expression` will evaluate the expression, and then
  assign it to the identifier, in the sandbox. It is recommended that for
  plugin properties, this method of adding a property is used, rather than
  adding and accessing properties from the bot's property sandbox (to
  prevent cluttering and namespace issues).

## Further Questions

If you have any further questions, you can visit me at the IRC server and
channel that were put in to the config/bot.conf file: #lobby on
irc.ctrlalttroll.com/+6697 and ask for 'asQuirreL'.

## Copyright Notice

There is none! :D You can do almost anything you want with ruBot2. Use it, 
modify it, redistribute it, print it out and wallpaper your room with it. 
If you're feeling particularly generous, you could credit me (asQuirreL) 
for it, just don't try and sell it, and if you do wallpaper your room with
it, send me a picture.
