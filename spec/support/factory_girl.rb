RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  # FactoryGirl.lint creates each factory and catches any exceptions
  config.before(:suite) do
    begin
      DatabaseCleaner.start
      FactoryGirl.lint
    ensure
      DatabaseCleaner.clean
    end
  end
end
