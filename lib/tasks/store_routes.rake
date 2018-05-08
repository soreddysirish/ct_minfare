	require 'sidekiq'
	require 'sidekiq-scheduler'
	require 'rubygems'
	namespace :store_routes_data do 
		require 'simple-spreadsheet'
		desc "store routes data"
		task create_routes: :environment do 
			s = SimpleSpreadsheet::Workbook.read('ksa_new_routes.xlsx')
			s.selected_sheet  = s.sheets.first
			s.first_row.upto(s.last_row-1) do |line|
				if s.cell(line,1) != "Origin" 
					source = s.cell(line,1)
					destination = s.cell(line,2)
					if source.present? && destination.present?
						if source.scan(/\w/).size != 2 && destination.scan(/\w/).size != 2
							KsaRoute.create(source:source,destination:destination)
							p "#{source} => #{destination}"
						end
					end
				end
			end
		end


		task get_fares: :environment do
			StoreSaFare.delete_all
			@routes =  KsaRoute.all
			@routes.each do |route|
				if route.present? && route.source.present? && route.destination.present?
					# MinFareWorker.new.perform(route.id)
				MinFareWorker.perform_async(route.id)
			end
		end
	end

	task generate_csv: :environment do 
		@fare_data  =  StoreSaFare.all.group_by{|x| [x.source,x.destination]}
		attributes = %w{source destination departure_date min_price_60_days currency}
		CSV.open("sa_min_fares.csv","wb") do |csv|
			csv << attributes
			@fare_data.each do |key,val|
				min_price =  val.min {|a,b| a.fare <=> b.fare}
				source = min_price[:source]
				destination = min_price[:destination]
				fare = min_price[:fare]
				currency = min_price[:currency]
				dep_date = min_price[:dep_date].strftime("%Y-%m-%d")
				csv << [source,destination,dep_date,fare,currency]
			end
		end
	end
end


