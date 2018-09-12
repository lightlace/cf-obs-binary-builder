class CfObsBinaryBuilder::Php < CfObsBinaryBuilder::BaseDependency
  attr_reader :major_version
  
  def initialize(version) 
    @major_version = version[/^(\d).*/,1]
    super(
      "php",
      version,
      "https://php.net/distributions/php-#{version}.tar.gz"
    )
  end

  def render_spec_template
    spec_template = File.read(
      File.expand_path(File.dirname(__FILE__) + "/../templates/php#{@major_version}.spec.erb"))
    ERB.new(spec_template).result(binding)
  end
end
