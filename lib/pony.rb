require 'rubygems'
require 'net/smtp'
begin
	require 'tmail'
rescue LoadError
	require 'actionmailer'
end

module Pony
	def self.mail(options)
		raise(ArgumentError, ":to is required") unless options[:to]

		via = options.delete(:via)
		if via.nil?
			transport build_tmail(options)
		else
			if via_options.include?(via.to_s)
				send("transport_via_#{via}", build_tmail(options))
			else
				raise(ArgumentError, ":via must be either smtp or sendmail")
			end
		end
	end

	def self.build_tmail(options)
		mail = TMail::Mail.new
		mail.to = options[:to]
		mail.from = options[:from] || 'pony@unknown'
		mail.subject = options[:subject]
		mail.body = options[:body] || ""
		mail
	end

	def self.sendmail_binary
		@sendmail_binary ||= `which sendmail`.chomp
	end

	def self.transport(tmail)
		if File.executable? sendmail_binary
			transport_via_sendmail(tmail)
		else
			transport_via_smtp(tmail)
		end
	end

	def self.via_options
		%w(sendmail smtp)
	end

	def self.transport_via_sendmail(tmail)
		IO.popen('-') do |pipe|
			if pipe
				pipe.write(tmail.to_s)
			else
				exec(sendmail_binary, tmail.to)
			end
		end
	end

	def self.transport_via_smtp(tmail)
		Net::SMTP.start('localhost') do |smtp|
			smtp.sendmail(tmail.to_s, tmail.from, tmail.to)
		end
	end
end
