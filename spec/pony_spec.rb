require File.dirname(__FILE__) + '/base'

describe Pony do
	it "sends mail" do
		Pony.should_receive(:transport) do |tmail|
			tmail.to.should == [ 'joe@example.com' ]
			tmail.from.should == [ 'sender@example.com' ]
			tmail.subject.should == 'hi'
			tmail.body.should == 'Hello, Joe.'
		end
		Pony.mail(:to => 'joe@example.com', :from => 'sender@example.com', :subject => 'hi', :body => 'Hello, Joe.')
	end

	it "requires :to param" do
		Pony.stub!(:transport)
		lambda { Pony.mail({}) }.should raise_error(ArgumentError)
	end

	it "doesn't require any other param" do
		Pony.stub!(:transport)
		lambda { Pony.mail(:to => 'joe@example.com') }.should_not raise_error
	end

	####################

	describe "builds a TMail object with field:" do
		it "to" do
			Pony.build_tmail(:to => 'joe@example.com').to.should == [ 'joe@example.com' ]
		end

		it "from" do
			Pony.build_tmail(:from => 'joe@example.com').from.should == [ 'joe@example.com' ]
		end

		it "from (default)" do
			Pony.build_tmail({}).from.should == [ 'pony@unknown' ]
		end

		it "subject" do
			Pony.build_tmail(:subject => 'hello').subject.should == 'hello'
		end

		it "body" do
			Pony.build_tmail(:body => 'What do you know, Joe?').body.should == 'What do you know, Joe?'
		end
	end

	describe "transport" do
		it "transports via the sendmail binary if it exists" do
			Pony.stub!(:sendmail_binary).and_return(__FILE__)
			Pony.should_receive(:transport_via_sendmail).with(:tmail)
			Pony.transport(:tmail)
		end

		it "transports via smtp if no sendmail binary" do
			Pony.stub!(:sendmail_binary).and_return('/does/not/exist')
			Pony.should_receive(:transport_via_smtp).with(:tmail)
			Pony.transport(:tmail)
		end

		it "transports mail via /usr/sbin/sendmail binary" do
			pipe = mock('sendmail pipe')
			IO.should_receive(:popen).with('-').and_yield(pipe)
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
	
	describe ":via option should over-ride the default transport mechanism" do
		it "should send via sendmail if :via => sendmail" do
			Pony.should_receive(:transport_via_sendmail)
			Pony.mail(:to => 'joe@example.com', :via => :sendmail)
		end

		it "should send via smtp if :via => smtp" do
			Pony.should_receive(:transport_via_smtp)
			Pony.mail(:to => 'joe@example.com', :via => :smtp)
		end
		
		it "should raise an error if via is neither smtp nor sendmail" do
			lambda { Pony.mail(:to => 'joe@plumber.com', :via => :pigeon) }.should raise_error(ArgumentError)
		end
	end
	
end
