class CfObsBinaryBuilder::RubyBuildpack < CfObsBinaryBuilder::BaseBuildpack
  def initialize(upstream_version, revision)
    super("php", upstream_version, revision)
  end
end