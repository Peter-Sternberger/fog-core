module Fog
  class Logger
    @channels = {
      :deprecation  => ::STDERR,
      :warning      => ::STDERR
    }

    @channels[:debug] = ::STDERR if ENV["DEBUG"]
    # We cannot necessarily set the DEBUG environment variable for fog-azure-rm because
    # that would log the complete HTTP body since this variable is also used by the Azure storage SDK.
    # Instead let's offer another way to enable fog-azure-rm debug logging
    @channels[:debug] = ::STDERR if ENV["FOG_DEBUG"]

    def self.[](channel)
      @channels[channel]
    end

    def self.[]=(channel, value)
      @channels[channel] = value
    end

    def self.debug(message)
      write(:debug, "[light_black][fog][DEBUG] #{message}[/]\n")
    end

    def self.deprecation(message)
      write(:deprecation, "[yellow][fog][DEPRECATION] #{message}[/]\n")
    end

    def self.warning(message)
      write(:warning, "[yellow][fog][WARNING] #{message}[/]\n")
    end

    def self.write(key, value)
      channel = @channels[key]
      if channel
        message = if channel.tty?
                    value.gsub(Fog::Formatador::PARSE_REGEX) { "\e[#{Fog::Formatador::STYLES[$1.to_sym]}m" }.gsub(Fog::Formatador::INDENT_REGEX, "")
                  else
                    value.gsub(Fog::Formatador::PARSE_REGEX, "").gsub(Fog::Formatador::INDENT_REGEX, "")
                  end
        channel.write(message)
      end
      nil
    end
  end
end
