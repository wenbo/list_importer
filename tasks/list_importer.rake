gem 'test-unit', '1.2.3' if RUBY_VERSION.to_f >= 1.9

namespace :spec do

  desc "Run specs related to importers(Ebay, Ioffer)"
  Spec::Rake::SpecTask.new(:importer) do |t|
    t.spec_opts = ['--options', "\"#{RAILS_ROOT}/spec/spec.opts\""]
    t.spec_files = FileList['spec/lib/**/*_spec.rb']
  end

end

