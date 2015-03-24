require 'oj'
require 'pronto'

module Pronto
  class OjValidator < Runner
    MSG_REGEX = /^(?<msg_prefix>.* at) line (?<line_number>\d+), (?<msg_suffix>column \d+)/

    def run(patches, _)
      return [] unless patches

      patches.select { |patch| patch.additions > 0 && json_file?(patch.new_file_full_path) }
             .map    { |patch| inspect(patch) }
             .flatten.compact
    end

    def inspect(patch)
      messages = []

      begin
        Oj.load_file(patch.new_file_full_path.to_s)
      rescue Oj::ParseError => e
        @match = MSG_REGEX.match(e.message)
        raise unless @match

        line = patch.added_lines.detect { |added| line_numbers.include?(added.new_lineno) }
        messages << new_message("#{@match[:msg_prefix]} #{@match[:msg_suffix]}", line) if line
      end

      messages
    end

    def line_numbers
      unless @line_numbers
        @line_numbers = [@match[:line_number].to_i]
        @line_numbers << @line_numbers[0] - 1 if @match[:msg_prefix].end_with?('not terminated at')
      end

      @line_numbers
    end

    def new_message(offense, line)
      path = line.patch.delta.new_file[:path]
      level = :error

      Message.new(path, line, level, offense)
    end

    def json_file?(path)
      File.extname(path) == '.json'
    end
  end
end
