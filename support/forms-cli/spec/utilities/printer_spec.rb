# frozen_string_literal: true

require "utilities/printer"

describe Printer do
  let(:data) do
    [{
      column_one: 1,
      column_two: 2,
      column_three: 3,
    },
     {
       column_one: 4,
       column_two: 5,
       column_three: 6,
     }]
  end

  it "prints a list of hashes as a table" do
    expected =  "\e[1;34;49m\nTesting table\n\e[0m\n" \
                "column_one  column_two  column_three\n" \
                "1           2           3           \n" \
                "4           5           6           \n"

    expect { described_class.new.print_table "Testing table", data }.to output(expected).to_stdout
  end

  it 'prints "No Data" when there is no data' do
    expect { described_class.new.print_table "Testing", [] }.to output(/No Data/).to_stdout
  end
end
