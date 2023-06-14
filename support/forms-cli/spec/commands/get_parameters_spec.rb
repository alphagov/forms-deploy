# frozen_string_literal: true

require "commands/get_parameters"
require_relative "../fixtures/ssm"

describe GetParameters do
  context "when not authenticated" do
    it "prompts the user to authenticate" do
      expect { GetParameters.new.run }.to output(/You must be authenticated/).to_stdout
    end
  end

  context "when authenticated" do
    let(:ssm_mock) do
      ssm = instance_double(Aws::SSM::Client)

      allow(ssm)
        .to receive(:get_parameters_by_path)
        .and_return(SsmFixtures.get_parameters_by_path)

      ssm
    end

    let(:printer_mock) do
      printer_mock = instance_double(Printer)

      allow(printer_mock)
        .to receive(:print_table)

      printer_mock
    end

    before do
      allow(Printer)
        .to receive(:new)
        .and_return(printer_mock)

      allow_any_instance_of(Helpers)
        .to receive(:aws_authenticated?)
        .and_return(true)

      allow(Aws::SSM::Client)
        .to receive(:new)
        .and_return(ssm_mock)
    end

    it "prints the parameters" do
      GetParameters.new.run

      expect(printer_mock)
        .to have_received(:print_table)
        .with(
          "Parameters",
          [{ name: "/some/parameters/path/one", value: "********" },
           { name: "/some/parameters/path/two", value: "********" }],
        )
    end

    describe "the decrypt option -d --decrypt" do
      it "defaults to false" do
        GetParameters.new.run

        expect(ssm_mock)
          .to have_received(:get_parameters_by_path)
          .with(hash_including(with_decryption: false))
      end

      it "is passed to SSM when set" do
        stub_const("ARGV", ["--decrypt"])
        GetParameters.new.run

        expect(ssm_mock)
          .to have_received(:get_parameters_by_path)
          .with(hash_including(with_decryption: true))
      end
    end

    describe "path option -p --path" do
      it "the path is provided to SSM" do
        stub_const("ARGV", ["--path", "/option_set_path"])
        GetParameters.new.run

        expect(ssm_mock)
          .to have_received(:get_parameters_by_path)
          .with(hash_including(path: "/option_set_path"))
      end

      it 'checks it begins with a "/"' do
        stub_const("ARGV", ["--path", "no-leading-slash"])

        expect { GetParameters.new.run }
          .to output(/--path must begin with/).to_stdout
      end
    end
  end
end
