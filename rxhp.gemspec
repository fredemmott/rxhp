Gem::Specification.new do |s|
  s.name = 'rxhp'
  s.version = '0.3.0'
  s.platform = Gem::Platform::RUBY
  s.authors = `git shortlog -s | sort -r | cut -f2`.split($/)
  s.email = ['rxhp-gem@fredemmott.co.uk']
  s.homepage = 'https://github.com/fredemmott/rxhp'
  s.summary = %q<An object-oriented validating HTML template system>
  s.description = %q<An object-oriented validating HTML template system>
  s.require_paths = ['lib']
  s.files = Dir['lib/**/*']
end
