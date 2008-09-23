require File.dirname(__FILE__) + '/base'

describe Pony do
	describe "API" do
		it "simplest possible syntax: mail(to, body)" do
			Pony.should_receive(:mail_inner).with(:to => 'joe@example.com', :body => 'Hello, Joe!')
			Pony.mail('joe@example.com', 'Hello, Joe!')
		end
	end

	####################

	describe "builds a TMail object with field:" do
		it "to" do
			Pony.build_tmail(:to => 'joe@example.com').to.should == [ 'joe@example.com' ]
		end

		it "from" do
			Pony.build_tmail(:from => 'joe@example.com').from.should == [ 'joe@example.com' ]
		end

		it "subject" do
			Pony.build_tmail(:subject => 'hello').subject.should == 'hello'
		end

		it "body" do
			Pony.build_tmail(:body => 'What do you know, Joe?').body.should == 'What do you know, Joe?'
		end
	end

	describe "transports" do
		it "transports mail via /usr/sbin/sendmail binary" do
			pipe = mock('sendmail pipe')
			IO.should_receive(:popen).with('/usr/sbin/sendmail to', 'w').and_yield(pipe)
			pipe.should_receive(:write).with('message')
			Pony.transport_via_sendmail(mock('tmail', :to => 'to', :from => 'from', :to_s => 'message'))
		end

		it "transports mail via Net::SMTP connecting to localhost" do
			smtp = mock('net::smtp object')
			Net::SMTP.should_receive(:start).with('localhost').and_yield(smtp)
			smtp.should_receive(:sendmail).with('message', 'from', 'to')
			Pony.transport_via_smtp(mock('tmail', :to => 'to', :from => 'from', :to_s => 'message'))
		end
	end
end
