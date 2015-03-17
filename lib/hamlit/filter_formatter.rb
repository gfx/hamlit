require 'hamlit/filter'

module Hamlit
  class FilterFormatter < Hamlit::Filter
    BASE_DEPTH      = 2
    IGNORED_FILTERS = %w[ruby].freeze

    def on_haml_filter(name, lines)
      return [:haml, :filter, name, lines] if IGNORED_FILTERS.include?(name)

      lines = [''] if lines.empty?
      lines = unindent_lines(lines)

      multi = [:multi, [:static, "\n"], *wrap_newlines(lines)]
      [:haml, :filter, name, multi]
    end

    private

    def unindent_lines(lines)
      base = lines.first.index(/[^\s]/) || 0
      lines.map do |line|
        change_indent(line, BASE_DEPTH - base)
      end
    end

    def change_indent(line, diff)
      if diff >= 0
        ((' ' * diff) + line).gsub(/ *\Z/, '')
      else
        line.gsub(/^[[:blank:]]{#{-1 * diff}}/, '')
      end
    end

    def wrap_newlines(lines)
      ast = []
      lines.each do |line|
        ast << [:haml, :text, line]
        ast << [:static, "\n"]
      end
      ast
    end
  end
end
