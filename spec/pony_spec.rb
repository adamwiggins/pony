require File.dirname(__FILE__) + '/base'

describe Pony do
	it "transports mail via Net::SMTP connecting to localhost" do
		smtp = mock('net::smtp object')
		Net::SMTP.should_receive(:start).with('localhost').and_yield(smtp)
		smtp.should_receive(:sendmail).with('Hello, Joe!', 'spec@pony', [ 'joe@example.com' ])
		Pony.mail_via_smtp(:to => 'joe@example.com', :from => 'spec@pony', :body => "Hello, Joe!")
	end

	it "simplest possible syntax: mail(to, body)" do
		Pony.should_receive(:mail_via_smtp).with(:to => 'joe@example.com', :body => 'Hello, Joe!')
		Pony.mail('joe@example.com', 'Hello, Joe!')
	end
end
