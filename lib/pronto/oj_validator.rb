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
        Oj.load_file(patch.new_file_full_path)
      rescue Oj::ParseError => e
        match = /^(.* at) line (\d+), (column \d+)/.match(e.message)
        raise unless match
        line_number = match[2]
        line = patch.added_lines.detect { |added_line| added_line.new_line_no == line_number }
        return [new_message("#{match[1]} #{match[3]}", line)] if line
      end
      []
    end

    def new_message(offence, line)
      path = line.patch.delta.new_file[:path]
      level = :error

      Message.new(path, line, level, offence['reason'])
    end

    def json_file?(path)
      File.extname(path) == '.json'
    end
  end
end
