class CfObsBinaryBuilder::Dependency
  attr_reader :version, :checksum, :dependency, :package_name, :source

  def initialize(dependency, version, source, checksum)
    @dependency = dependency
    @version = version
    @source = source
    @checksum = checksum
    @package_name = "#{dependency}-#{version}"
  end

  def run
    create_obs_package
    checkout_obs_package
    Dir.chdir("#{obs_project}/#{package_name}")
    prepare_files
    validate_checksum
    commit_obs_package
    log 'Done!'
  end

  def render_spec_template
    spec_template = File.read(
      File.expand_path(File.dirname(__FILE__) + "/templates/#{dependency}.spec.erb"))
    ERB.new(spec_template).result(binding)
  end

  def validate_checksum
    sha256 = Digest::SHA256.file File.basename(source)
    actual_checksum = sha256.hexdigest

    if actual_checksum != checksum
      raise "Checksum mismatch #{actual_checksum} vs. #{checksum}"
    end
  end

  def create_obs_package
    log 'Creating the package on OBS using "osc"...'

    package_meta_template = <<EOF
<package project="#{obs_project}" name="#{package_name}">
  <title>#{package_name}</title>
  <description>
    Automatic build of #{package_name} for the use in buildpacks in SCF.
  </description>
</package>
EOF

    Tempfile.open("package_meta_template") do |file|
      file.write(package_meta_template)
      file.close

      `osc meta pkg #{obs_project} #{package_name} -F #{file.path}`
    end
  end

  def checkout_obs_package
    log 'Checking out the package with osc...'
    `osc checkout #{obs_project}/#{package_name}`
  end

  def commit_obs_package
    log 'Commit the changes on OBS'
    log `osc addremove`
    log `osc commit -m "Commiting files"`
  end

  def obs_project
    ENV["OBS_PROJECT"] || raise("no OBS_PROJECT environment variable set")
  end

  def log(*args)
    CfObsBinaryBuilder::log(*args)
  end
end
