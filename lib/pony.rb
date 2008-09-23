require 'rubygems'
require 'net/smtp'
require 'tmail'

module Pony
	def self.mail(to, body)
		mail_inner(:to => to, :body => body)
	end

	####################

	def self.mail_inner(options)
		send_tmail build_tmail(options)
	end

	def self.build_tmail(options)
		mail = TMail::Mail.new
		mail.to = options[:to]
		mail.from = options[:from] || 'pony@unknown'
		mail.subject = options[:subject]
		mail.body = options[:body] || ""
		mail
	end

	def self.send_tmail(tmail)
		Net::SMTP.start('localhost') do |smtp|
			smtp.sendmail(tmail.to_s, tmail.from, tmail.to)
		end
	end
end
