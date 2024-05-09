class Group
  attr_accessor :name
  attr_accessor :pipelines

  def initialize(name, pipelines)
    @name = name
    @pipelines = pipelines
  end
end