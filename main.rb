require 'sinatra'
require 'haml'
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Milestone
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String, :required => true
  property :reached_at,   DateTime
end
DataMapper.finalize
 
get '/' do
  @milestones = Milestone.all
  haml :index
end

get '/:milestone' do
  @milestone = params[:milestone].split('-').join(' ').capitalize
  haml :milestone
end

post '/' do
  Milestone.create params[:milestone]
  redirect to('/')
end

delete '/milestone/:id' do
  Milestone.get(params[:id]).destroy
  redirect to('/')
end

put '/milestone/:id' do
  milestone = Milestone.get params[:id]
  milestone.reached_at = milestone.reached_at.nil? ? Time.now : nil
  milestone.save
  redirect to('/')
end
 