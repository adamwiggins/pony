require 'rubygems'
require 'net/smtp'
require 'tmail'

module Pony
	def self.mail(options)
		raise(ArgumentError, ":to is required") unless options[:to]
		transport build_tmail(options)
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
		"/usr/sbin/sendmail"
	end

	def self.transport(tmail)
		if File.exists? sendmail_binary
			transport_via_sendmail(tmail)
		else
			transport_via_smtp(tmail)
		end
	end

	def self.transport_via_sendmail(tmail)
		IO.popen("#{sendmail_binary} #{tmail.to}", "w") do |pipe|
			pipe.write tmail.to_s
		end
	end

	def self.transport_via_smtp(tmail)
		Net::SMTP.start('localhost') do |smtp|
			smtp.sendmail(tmail.to_s, tmail.from, tmail.to)
		end
	end
end
