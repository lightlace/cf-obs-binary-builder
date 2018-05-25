class CfObsBinaryBuilder::Dependency
  attr_reader :version, :checksum, :dependency, :package_name, :source, :obs_package

  def initialize(dependency, version, source = nil, checksum = nil)
    @dependency = dependency
    @version = version
    @source = source
    @checksum = checksum
    @package_name = "#{dependency}-#{version}"
    @obs_package = CfObsBinaryBuilder::ObsPackage.new(package_name)
  end

  def run
    obs_package.create
    obs_package.checkout do
      render_spec_template
      prepare_sources
      validate_checksum
      write_sources_yaml
      obs_package.commit
    end
    log 'Done!'
  end

  def write_sources_yaml
    File.write("sources.yml", self.to_yaml)
  end

  def render_spec_template
    log 'Render the spec template and put it in the package dir'
    spec_template = File.read(
      File.expand_path(File.dirname(__FILE__) + "/templates/#{dependency}.spec.erb"))
    File.write("#{dependency}.spec", ERB.new(spec_template).result(binding))
  end

  def prepare_sources
    log 'Downloading the sources in the package directory...'
    File.write(File.basename(source), open(source).read)
  end

  def validate_checksum
    sha256 = Digest::SHA256.file File.basename(source)
    actual_checksum = sha256.hexdigest

    if actual_checksum != checksum
      raise "Checksum mismatch #{actual_checksum} vs. #{checksum}"
    end
  end

  def to_yaml
    [
      {
        'url'    => @source,
        'sha256' => @checksum
      }
    ].to_yaml
  end
end
