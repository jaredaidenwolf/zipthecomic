# frozen_string_literal: true

require "logger"

module Zipthecomic
  # Creates a logger that writes to both file and STDOUT
  #
  # @param log_file [String] the path to the log file
  # @return [Logger] the configured logger
  def self.setup_logger(log_file)
    # Ensure the log directory exists
    FileUtils.mkdir_p(File.dirname(log_file))

    file_logger = Logger.new(log_file)
    file_logger.level = Logger::INFO

    stdout_logger = Logger.new($stdout)
    stdout_logger.level = Logger::INFO

    # Custom formatter for both
    formatter = proc do |severity, datetime, _progname, msg|
      "[#{datetime.strftime("%Y-%m-%d %H:%M:%S")}] #{severity}: #{msg}\n"
    end

    file_logger.formatter = formatter
    stdout_logger.formatter = formatter

    # Return a proxy logger that sends to both
    MultiLogger.new(file_logger, stdout_logger)
  end

  # A logger that writes to multiple outputs
  class MultiLogger
    def initialize(*targets)
      @targets = targets
    end

    Logger::Severity.constants.each do |severity|
      define_method(severity.downcase) do |*args, &block|
        @targets.each { |logger| logger.send(severity.downcase, *args, &block) }
      end
    end
  end
end
