class LocationsController < ApplicationController
  def browse
    # @data = YelpRequester.request(session[:user_lat], session[:user_long])
    # Location.record_from_yelp(@data)
    @photo_hash= InstagramRequester.photos_by_user_location(session[:user_lat], session[:user_long])

    # scroll through photos loaded by db/api, javascript interactive
  end

  def show
    # this will be the location detail page with button to navigate here
  end

  def index
    # this could be an admin oriented feature that lists all locations
  end
end
