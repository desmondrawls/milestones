require 'sinatra'
require 'haml'
 
get '/' do
  haml :index
end

get '/:milestone' do
  @milestone = params[:milestone].split('-').join(' ').capitalize
  haml :milestone
end

post '/' do
  @milestone = params[:milestone]
  haml :milestone
end
 