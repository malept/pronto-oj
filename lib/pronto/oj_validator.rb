require 'oj'
require 'pronto'

module Pronto
  class OjValidator < Runner
    def run(patches, _)
      return [] unless patches

      patches.select { |patch| patch.additions > 0 && json_file?(patch.new_file_full_path) }
             .map    { |patch| inspect(patch) }
             .flatten.compact
    end

    def inspect(patch)
      begin
        Oj.load_file(patch.new_file_full_path.to_s)
      rescue Oj::ParseError => e
        match = /^(.* at) line (\d+), (column \d+)/.match(e.message)
        raise unless match
        msg_prefix = match[1]
        line_numbers = [match[2].to_i]
        line_numbers << line_numbers[0] - 1 if msg_prefix.end_with?('not terminated at')
        line = patch.added_lines.detect { |added_line| line_numbers.include?(added_line.new_lineno) }
        return [new_message("#{msg_prefix} #{match[3]}", line)] if line
      end
      []
    end

    def new_message(offence, line)
      path = line.patch.delta.new_file[:path]
      level = :error

      Message.new(path, line, level, offence)
    end

    def json_file?(path)
      File.extname(path) == '.json'
    end
  end
end
