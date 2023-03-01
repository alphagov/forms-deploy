# frozen_string_literal: true

require 'colorize'

# Prints a list of hashes into a dynamic colum width table
class Printer
  def print_table(title, contents)
    puts "\n#{title}\n".blue.bold

    unless contents.any?
      puts 'No Data'
      return
    end

    column_widths = calculate_column_widths contents

    # Print column headings
    print_table_row(contents[0].keys, column_widths)

    # Print service details
    contents.each do |service|
      print_table_row(service.values, column_widths)
    end
  end

  private

  def print_table_row(row, column_widths)
    puts row.each_with_index
            .map { |s, i| s.to_s.ljust(column_widths[i]) }
            .join('  ')
  end

  def calculate_column_widths(contents)
    column_headings = contents[0].keys
    column_widths = Array.new(column_headings.length, 0)
    column_headings.each_with_index do |heading, i|
      contents.each do |service|
        column_widths[i] = [
          column_widths[i],
          heading.length,
          service[heading].to_s.length
        ].max
      end
    end
    column_widths
  end
end
