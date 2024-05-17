class ArtifactRevision
  attr_accessor :name
  attr_accessor :revision_id
  attr_accessor :revision_summary

  # @param [Aws::CodePipeline::Types::ArtifactRevision] artifact
  def initialize(artifact)
    @name = artifact.name
    @revision_id = artifact.revision_id

    if artifact.revision_summary.start_with? "{"
      summary_json = JSON.parse(artifact.revision_summary)

      summary_text = ""
      case summary_json["ProviderType"]
      when "GitHub", "CodeCommit"
        @revision_summary = summary_json["CommitMessage"]
      else
        @revision_summary = "Error: Unknown provider type"
      end
    else
      @revision_summary = artifact.revision_summary
    end
  end
end