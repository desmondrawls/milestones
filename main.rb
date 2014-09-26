require 'sinatra'
require 'haml'
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Milestone
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String, :required => true
  property :reached_at,   DateTime
  belongs_to :baby
end

class Baby
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String, :required => true
  property :birthdate,    Date
  has n, :milestones, :constraint => :destroy
end
DataMapper.finalize

get '/' do
  @babies = Baby.all
  haml :index
end
 
get '/baby/:id' do
  @baby = Baby.get(params[:id])
  @milestones = @baby.milestones.all
  haml :baby
end

post '/baby/:id/milestones' do
  Baby.get(params[:id]).milestones.create params['milestone']
  redirect to("baby/#{params[:id]}")
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
  redirect to("/baby/#{milestone.baby.id}")
end

post '/new/baby' do
  Baby.create params['baby']
  redirect to('/')
end

delete '/baby/:id' do
  Baby.get(params[:id]).destroy
  redirect to('/')
end
 