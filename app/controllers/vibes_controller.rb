# There are in total three routes.
# immediate/search is to fetch an immediate result from watson. It gets only
# stored in the Cache table temporary for aggregation purposes and are discarded
# thereafter.
# cached/search is to fetch a query solely from the database directly.
#
# In between these two is a third route:
# gradual/search which figures out what is already encompassed by the databse
# in the query so as to only retrieve whatever is relevant from Watson
# It schedules background workers for the retrieval so that the Tweet table
# gets populated in the background.
# In the meanwhile, the client should continue quering the database directly
# through the route cached/search... until all background job results have
# been committed to the database.
#
class VibesController < ApplicationController
  include Timestamp

  def immediate
    q_parser = QueryParser.new(check_params)
    if q_parser.errors?
      render json: handle_jsonp({ errors: q_parser.errors, params: params })
    else
      api = WatsonTwitterInsightsApi.new(q_parser.query)
      assembler = JsonAssembler.new(api.get, q_parser)
      render json: handle_jsonp(assembler.json)
    end
  end

  def gradual
    q_parser = QueryParser.new(check_params)
    if q_parser.errors?
      render json: handle_jsonp({ errors: q_parser.errors, params: params })
    else
      BackgroundJobsController.run(q_parser)
      assembler = JsonAssembler.new({}, q_parser)
      render json: handle_jsonp(assembler.json)
   end
  end

  def cached
    q_parser = QueryParser.new(check_params)
    if q_parser.errors?
      render json: handle_jsonp({ errors: q_parser.errors, params: params })
    else
      assembler = JsonAssembler.new({}, q_parser)
      render json: handle_jsonp(assembler.json)
    end
  end

  private
    def check_params
      params.permit(:q, :range,
                    :seconds, :minutes, :hours, :days, :weeks, :months, :years,
                    :location, :stats, :since, :from,
                    :action)
    end

    def handle_jsonp(data)
      cb = params['callback']
      if cb
        cb + '(' + data.to_json + ');'
      else
        data
      end
    end
end