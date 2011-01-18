require "./EM/eventmanager.rb"

class IRCBot

	def load_plugin filename
		raise ArgumentError, "No Such Plugin" if !File.exists? filename
		
		if filename =~ /^(?:.+\/)?(.+)\.rb$/i
			var_name = "rbp_" + $1
			mod_name = "RBP_" + var_name.split("_").map { |s| s.capitalize }.join("")
		else
			raise ArgumentError, "Plugin name in incorrect format, \'#{ filename }\'"
		end
	end

end
