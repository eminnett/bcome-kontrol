lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

Gem::Specification.new do |spec|
  spec.name          = 'bcome'
  spec.version       = '1.1.2'
  spec.authors       = ['Guillaume Roderick (Webzakimbo)']
  spec.email         = ['guillaume@webzakimbo.com']

  spec.summary       = 'Automation and real-time orchestration toolkit'
  spec.description   = "Automation and real-time orchestration toolkit:  no more re-inventing the wheel for common & basic dev ops tasks.  Network discovery / access machines by SSH / deploy applications / apply orchestration / enable automation.  Amazon EC2 integration"
  spec.homepage      = 'https://github.com/webzakimbo/bcome-kontrol'
  spec.license       = 'GPL-3.0'
  spec.files = Dir.glob('{bin,lib,filters,patches}/**/*')
  spec.bindir = 'bin'
  spec.executables = ['bcome']
  spec.require_paths = ['lib']
  spec.add_dependency 'activesupport', '5.1'
  spec.add_dependency 'awesome_print', '1.8.0'
  spec.add_dependency 'fog-aws', '~> 0.12.0'
  spec.add_dependency 'net-scp', '~> 1.2', '>= 1.2.1'
  spec.add_dependency 'net-ssh', '4.1.0'
  spec.add_dependency 'pmap', '1.1.1'
  spec.add_dependency 'rainbow', '~> 2.2.1'
  spec.add_dependency 'require_all', '1.3.3'
  spec.add_dependency 'rsync', '~> 1.0'
end
