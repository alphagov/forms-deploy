# frozen_string_literal: true

require_relative "../utilities/bastion"
require_relative "../utilities/helpers"

class BastionExec
  def run
    @environment = fetch_environment
    @options = {}
    @subcommand = :run

    @bastion = Bastion.new(@environment)

    parse_options!

    if @subcommand == :run
      @bastion.run(**@options)
    else
      send @subcommand
    end
  end

  def setup
    @bastion.setup(container_image: @options[:image])
    puts "Applied bastion configuration to #{@environment}"
  end

  def teardown
    @bastion.teardown(**@options)
    puts "Deleted bastion configuration from #{@environment}"
  end

private

  include Helpers

  def parse_options!
    OptionParser.new do |opts|
      opts.on("--setup")

      opts.on("--teardown")

      opts.on("-iIMAGE", "--image=image", "The image to use for the bastion task")

      opts.on("-cCOMMAND", "--command=command", "The command to run on the bastion container")
    end.parse!(into: @options)

    @subcommand = :setup if @options.delete(:setup)
    @subcommand = :teardown if @options.delete(:setup)

    case @subcommand
    when :setup
      raise "Option command is not allowed with --setup" if @options[:command]
    when :teardown
      raise "Option command is not allowed with --teardown" if @options[:command]
      raise "Option image is not allowed with --teardown" if @options[:image]
    when :run
      raise "Option image is only allowed with --setup" if @options[:image]
    end

    @options
  end
end
