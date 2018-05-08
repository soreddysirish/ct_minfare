class MinFareWorker
	include HTTParty
	include Sidekiq::Worker
	def perform(route)
		(Date.today()+7.days).upto(Date.today()+90.days).each do |day|
			day = Date.parse(day) unless day.class.to_s == "Date"
			# StoreFareWorker.new.perform(route,day)
			StoreFareWorker.perform_async(route,day)
		end
	end
end
