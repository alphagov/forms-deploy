require_relative "../../../lib/models/artifact_revision"
require "aws-sdk-codepipeline"
require "aws-sdk-codepipeline/types"

describe ArtifactRevision do
  subject do
    ArtifactRevision.new(artifact)
  end

  let(:artifact) do
    Aws::CodePipeline::Types::ArtifactRevision.new(
      name: "get-source",
      revision_id: "012abc",
      revision_summary: '{"ProviderType": "GitHub", "CommitMessage": "Some headline text"}',
    )
  end

  it "name comes from the artifact name" do
    expect(subject.name).to eq "get-source"
  end

  it "revision id comes from the artifact's revision id" do
    expect(subject.revision_id).to eq "012abc"
  end

  describe "when the artifact summary does not begin with '{'" do
    it "treats the summary as plain text" do
      artifact.revision_summary = "plain text"
      subject = ArtifactRevision.new(artifact)
      expect(subject.revision_summary).to eq "plain text"
    end
  end

  describe "when the artifact summary begins with '{' it assumes it as a known JSON structure for Git sources and" do
    %w[GitHub CodeCommit].each do |provider|
      context "when the 'ProviderType' is '#{provider}'" do
        it "the revision summary is the commit message" do
          summary = {
            "ProviderType" => provider,
            "CommitMessage" => "a commit message",
          }

          artifact.revision_summary = summary.to_json
          subject = ArtifactRevision.new(artifact)

          expect(subject.revision_summary).to eq "a commit message"
        end
      end
    end

    context "when the 'ProviderType' is not a known value" do
      it "the revision summary contains some error message" do
        summary = {
          "ProviderType" => "unknown",
          "CommitMessage" => "a commit message",
        }

        artifact.revision_summary = summary.to_json
        subject = ArtifactRevision.new(artifact)

        expect(subject.revision_summary).to eq "Error: Unknown provider type"
      end
    end
  end
end
