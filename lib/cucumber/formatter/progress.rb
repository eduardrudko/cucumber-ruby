require 'cucumber/formatter/console'

module Cucumber
  module Formatter
    class Progress < Ast::Visitor
      include Console

      def initialize(step_mother, io, options)
        super(step_mother)
        @io = (io == STDOUT) ? Kernel : io
        @flushable = @io.respond_to?(:flush) ? @io : STDOUT
        @options = options
      end

      def visit_features(features)
        super
        @io.puts
        @io.puts
        print_summary(@io, features)
      end

      def visit_multiline_arg(multiline_arg, status)
        @multiline_arg = true
        super
        @multiline_arg = false
      end

      def visit_feature_element(feature_element)
        progress(:undefined) if feature_element.undefined?
        super
      end

      def visit_step_name(keyword, step_name, status, step_definition, source_indent)
        progress(status) unless status == :outline
      end

      def visit_table_cell_value(value, width, status)
        progress(status) if (status != :thead) && !@multiline_arg
      end
      
      private

      def print_summary(io, features)
        print_steps(io, features, :undefined)
        print_steps(io, features, :pending)
        print_steps(io, features, :failed)
        print_counts(io, features)
      end

      CHARS = {
        :passed    => '.',
        :failed    => 'F',
        :undefined => 'U',
        :pending   => 'P',
        :skipped   => 'S'
      }

      def progress(status)
        char = CHARS[status]
        @io.print(format_string(char, status))
        @flushable.flush
      end
      
    end
  end
end