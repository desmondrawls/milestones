require 'sinatra'
require 'haml'
require 'data_mapper'

DataMapper.setup(:default, ENV['DATABASE_URL'] || "sqlite3://#{Dir.pwd}/development.db")

class Milestone
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String, :required => true
  has n, :babies, :through => :achievements
  has n, :achievements, :constraint => :destroy
end

class Baby
  include DataMapper::Resource
  property :id,           Serial
  property :name,         String, :required => true
  property :birthdate,    Date, :required => true
  property :gender,       String
  has n, :milestones, :through => :achievements
  has n, :achievements, :constraint => :destroy
end

class Achievement
  include DataMapper::Resource
  property :id,           Serial
  property :reached_at,   DateTime
  belongs_to :baby
  belongs_to :milestone
end
DataMapper.finalize


get '/' do
  @babies = Baby.all
  @milestones = Milestone.all
  haml :index
end

post '/' do
  Milestone.create params[:milestone]
  redirect to('/')
end

post '/babies' do
  Baby.create params['baby']
  redirect to('/')
end
 
get '/baby/:id' do
  @baby = Baby.get(params[:id])
  @milestones = Milestone.all
  @baby_achievements = @baby.achievements.all
  haml :baby
end

delete '/baby/:id' do
  Baby.get(params[:id]).destroy
  redirect to('/')
end

post '/milestones' do
  Milestone.create params['milestone']
  redirect to("/")
end

get '/milestones/:id' do
  "Under Construction"
end

delete '/milestones/:id' do
  Milestone.get(params[:id]).destroy
  redirect to('/')
end

put '/baby/:id/achievements' do
  milestone = Milestone.get params[:id]
  milestone.reached_at = milestone.reached_at.nil? ? Time.now : nil
  milestone.save
  redirect to("/baby/#{milestone.baby.id}")
end

delete '/baby/:id/achievements' do
  achievement = Achievement.all(:baby_id => params['id'], :milestone_id => params['milestone_id'])
  achievement.destroy
  redirect to("/baby/#{params['id']}")
end

post '/baby/:id/achievements' do
  Achievement.create(:baby_id => params['id'], :milestone_id => params['milestone_id'], :reached_at => Time.now)
  redirect to("/baby/#{params['id']}")
end


 