RSpec.configure do |config|
  RSpec::Matchers.define :include_one_of do |*elements|
    match do |actual|
      @included = []
      elements.flatten.each do |e|
        @included << e if actual.include?(e)
      end
      @included.count == 1
    end

    failure_message do |actual|
      "expected \n\"#{actual}\"\nto include 1 of \n\"#{expected.join("\"\n\"")}\""
    end
  end

  RSpec::Matchers.define :be_one_of do |*elements|
    match do |actual|
      @included = []
      elements.flatten.each do |e|
        @included << e if actual.eql?(e)
      end
      @included.count == 1
    end

    failure_message do |actual|
      "expected \n\"#{actual}\"\nto include 1 of\n\"#{expected.join("\"\n\"")}\""
    end
  end
end