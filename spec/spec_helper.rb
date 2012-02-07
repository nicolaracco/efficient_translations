# Load the Sinatra app
require File.dirname(__FILE__) + '/../lib/efficient_translations'

require 'rspec'

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

RSpec.configure do |conf|
  conf.before :suite do
    ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => ':memory:')
    require File.join(File.dirname(__FILE__), 'fixtures', 'schema.rb')
  end
end
