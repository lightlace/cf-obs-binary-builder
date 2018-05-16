class CfObsBinaryBuilder::NonBuildDependency < CfObsBinaryBuilder::Dependency
  attr_reader :license

  def initialize(dependency, version, source, checksum, license)
    @license = license

    super(dependency, version, source, checksum)
  end

  def prepare_files
    File.write(File.basename(source), open(source).read)
    File.write("#{dependency}.spec", render_spec_template)
  end

  def render_spec_template
    spec_template = File.read(
      File.expand_path(File.dirname(__FILE__) + "/templates/non-build-dependency.spec.erb"))
    ERB.new(spec_template).result(binding)
  end
end
