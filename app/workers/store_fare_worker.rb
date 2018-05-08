class StoreFareWorker
	include HTTParty
	include Sidekiq::Worker
	def perform(route,day)
		route_data  = KsaRoute.find(route) 
		if route_data.present?
			source = route_data.source
			destination = route_data.destination
			day = Date.parse(day) unless day.class.to_s == "Date"
			starting_time = Time.now
			api_call(source,destination,day)
			ending_time = Time.now
			elapsed = ending_time - starting_time
			waiting = API_WAITING_TIME-elapsed
			sleep(waiting) if waiting>0
		end
	end

	def api_call(source,destination,day)
		dep_date = day.strftime('%Y-%m-%d')
		url  = "https://api.cleartrip.com/air/1.0/search?from=#{source}&to=#{destination}&depart-date=#{dep_date}&adults=1&children=0&infants=0&jsonVersion=1.0&currency=SAR"
		res = HTTParty.get(url,headers:{'X-CT-API-KEY': 'c54db399993cbc0a70b425d963afdab6','X-CT-SOURCETYPE': 'B2C','Accept-encoding': 'gzip'})
		resp_json = JSON.parse(res.body)
		fare_values = []
		currency =""
		if resp_json["jsons"].present?
			if resp_json["jsons"]["searchType"].present?
				if resp_json["jsons"]["searchType"]["sellCurr"].present?
					currency = resp_json["jsons"]["searchType"]["sellCurr"]
				end
			end
		end
		if resp_json["fare"].present?
			resp_json["fare"].each do |key,fdata|
				if  fdata["HBAG"].present?
					fdata = fdata["HBAG"]
				end
				if fdata["dfd"] == "R"
					data = fdata["R"]
					refundable = true
				else
					data = fdata["N"]
					refundable =false
				end
				if data["pr"] > 0
					fare_values.push(data["pr"])
				end
			end
			min_val = fare_values.min rescue 0
			store_data(min_val,source,destination,day,currency)
		end
		sleep 3
	end

	def store_data(min_val,source,destination,day,currency)
		price = min_val
		if price.present? && price > 0
			StoreSaFare.create(source:source,destination:destination,dep_date: day,currency:currency,fare:price)
			p "created #{source} #{destination}"
		end
	end
end
