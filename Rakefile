# frozen_string_literal: true

require "bundler/gem_tasks"

require "minitest/test_task"
Minitest::TestTask.create do |t|
  t.libs << "test"
  t.test_globs = ["test/**/*_test.rb"]
  t.framework = 'require "test_helper"'
end

require "rubocop/rake_task"
RuboCop::RakeTask.new

require "yardstick/rake/measurement"
Yardstick::Rake::Measurement.new do |measurement|
  measurement.output = "measurement/report.txt"
end

require "yardstick/rake/verify"
Yardstick::Rake::Verify.new do |verify|
  verify.require_exact_threshold = false
  verify.threshold = 100
end

desc "Type check with Steep"
task :steep do
  require "steep"
  require "steep/cli"
  exit Steep::CLI.new(argv: ["check", "--log-level=fatal"], stdout: $stdout, stderr: $stderr, stdin: $stdin).run
end

desc "Run mutation testing with Mutant"
task :mutant do
  system("bundle exec mutant run") || abort("Mutant failed!")
end

task default: %i[test rubocop verify_measurements steep]
