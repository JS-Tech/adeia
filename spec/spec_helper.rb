require 'factory_girl_rails'
require 'rspec/active_model/mocks'

FactoryGirl.definition_file_paths = [ File.join(File.dirname(__FILE__), '../spec/factories') ]
FactoryGirl.find_definitions

RSpec.configure do |config|
  
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.include FactoryGirl::Syntax::Methods

end