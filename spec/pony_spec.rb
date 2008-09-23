require File.dirname(__FILE__) + '/base'

describe Pony do
	it "sends an email via Net::SMTP" do
		smtp = mock('net::smtp object')
		Net::SMTP.should_receive(:start).with('localhost').and_yield(smtp)
		smtp.should_receive(:sendmail).with('Hello, Joe!', 'pony@unknown', [ 'joe@example.com' ])
		Pony.mail('joe@example.com', 'Hello, Joe!')
	end
end
