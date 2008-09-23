require 'net/smtp'

module Pony
	def self.mail(to, body)
		Net::SMTP.start('localhost') do |smtp|
			smtp.sendmail(body, 'pony@unknown', [ to ])
		end
	end
end
