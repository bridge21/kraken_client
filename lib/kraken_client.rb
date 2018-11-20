ruby_project_files = Dir[File.join(File.dirname(__FILE__), '**', '*.rb')]

ruby_project_files.sort_by!{ |file_name| file_name.downcase }.each do |path|
  require_relative path
end

module KrakenClient
  extend KrakenClient::Configurable

  def self.root
    File.expand_path('..', __FILE__)
  end

  def self.load(params = {})
    KrakenClient::Application.new(params)
  end

  class << self
    attr_writer :logger

    def logger
      @logger ||= Logger.new($stdout).tap do |log|
        log.progname = self.name
      end
    end
  end

end
