class GoogleRequester

# if there is never a place_id found then
  def self.check_for_updates(location)
    if location.hours_updated_at < Time.now - 2.weeks
      if location.place_id == nil || location.has_hours == false
        request(location)
      else
        get_hours(location)
      end
    end
  end

  def self.request(location)
    @@client = GooglePlaces::Client.new(ENV["GOOGLE_PLACE_KEY"])
    loc_arry = @@client.spots(location.lat, location.long, :name => location.name)
      # add second search if first returns nothing using spots_by_query and city name
    if loc_arry.empty? then loc_arry = @@client.spots_by_query("#{location.name} in #{location.city}") end
    if loc_arry.empty?
      location.update( active: false, hours_updated_at: Time.now )
    else
      # save google place ID
      location.update(place_id: loc_arry[0].place_id)
      #save hours in association with location
      if loc_arry[0].opening_hours == nil
        location.updated(has_hours: false, hours_updated_at: Time.now )
      else
        get_hours(location)
      end
    end
  end

  def self.get_hours(location)
    hours = @@client.spot(location.place_id).opening_hours["periods"]
    # clear out any old windows before building new ones
    locations.window.destroy_all
    hours.each do |day_hash|
      Window.create(location_id: location.id, open_day: day_hash["open"]["day"],
                    open_time: day_hash["open"]["time"], close_day: day_hash["close"]["day"],
                    close_time: day_hash["close"]["time"])
    end
    location.update(hours_updated_at: Time.now)
  end

end
