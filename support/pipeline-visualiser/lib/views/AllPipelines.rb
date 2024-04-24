class AllPipelinesView
  attr_accessor :pipeline_groups
  def initialize(pipeline_groups)
    @pipeline_groups = pipeline_groups
  end

  def running_pipelines
    @pipeline_groups
      .collect{ |group| group.pipelines }
      .flatten
      .filter {|pipeline| pipeline.is_running? }
  end

  def failing_pipelines
    @pipeline_groups
      .collect{ |group| group.pipelines }
      .flatten
      .filter {|pipeline| pipeline.status == "Failed" }
  end
end