require "job_helper"
require "mail"

describe Jobs::Mailer do
  before :all do
    Mail.defaults do
      delivery_method :test
    end
  end

  it "sends an email" do
    Jobs::Mailer.perform({"from" => "foo@zapfol.io", "to" => "bar@zapfol.io", "fields" => {"a" => "<b>Foo Bar</b>"}})

    message = Mail::TestMailer.deliveries.first
    message.should_not be_nil

    message.to.should == ["bar@zapfol.io"]
    message.reply_to.should == ["foo@zapfol.io"]

    message.text_part.body.should =~ /foo@zapfol\.io/
    message.text_part.body.should =~ /a: &lt;b&gt;Foo Bar&lt;\/b&gt;/

    message.html_part.body.should =~ /foo@zapfol\.io/
    message.html_part.body.should =~ /<b>a:<\/b> &lt;b&gt;Foo Bar&lt;\/b&gt;/
  end
end