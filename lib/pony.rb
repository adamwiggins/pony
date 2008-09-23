require 'net/smtp'

module Pony
	def self.mail(to, body)
		mail_via_smtp(:to => to, :body => body)
	end

	def self.mail_via_smtp(options={})
		Net::SMTP.start('localhost') do |smtp|
			smtp.sendmail(options[:body], options[:from] || 'pony@unknown', [ options[:to] ])
		end
	end
end
