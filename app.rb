# file: app.rb
require "sinatra"
require "sinatra/reloader"
require_relative "lib/database_connection"
require_relative "lib/album_repository"
require_relative "lib/artist_repository"

DatabaseConnection.connect

class Application < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
    also_reload "lib/album_repository"
    also_reload "lib/artist_repository"
  end

  get "/albums" do
    repo = AlbumRepository.new
    @albums = repo.all
    # response = albums.map { |album| album.title }.join(", ")
    return erb(:albums)
  end

  post "/albums" do
    if invalid_request_parameters?
      status 400
      return ''
    end

    repo = AlbumRepository.new
    new_album = Album.new
    new_album.title = params[:title]
    new_album.release_year = params[:release_year]
    new_album.artist_id = params[:artist_id]
    repo.create(new_album)
    return erb(:album_success)
  end

  get "/artists" do
    repo = ArtistRepository.new
    @artists = repo.all
    return erb(:artists)
  end

  post "/artists" do

    repo = ArtistRepository.new
    new_artist = Artist.new
    new_artist.name = params[:name]
    new_artist.genre = params[:genre]
    repo.create(new_artist)
    return erb(:artist_success)
  end

  get "/albums/new" do
    return erb(:new_album)
  end

  get "/artists/new" do
    return erb(:new_artist)
  end

  get "/albums/:id" do
    repo = AlbumRepository.new
    artist_repo = ArtistRepository.new
    @album = repo.find(params[:id]).title
    @release_year = repo.find(params[:id]).release_year
    @artist_id = repo.find(params[:id]).artist_id
    @artist = artist_repo.find(@artist_id).name
    return erb(:index)
  end

  get "/artists/:id" do 
    repo = ArtistRepository.new
    @artist = repo.find(params[:id]).name
    @genre = repo.find(params[:id]).genre
    return erb(:artists_id)
  end

 

  def invalid_request_parameters?
    # Are the params nil?
    return true if params[:title] == nil || params[:release_year] == nil || params[:artist_id] == nil
  
    # Are they empty strings?
    return true if params[:title] == "" || params[:release_year] == "" || params[:artist_id] == ""
  
    return false
  end

  
end

# key = [:title, :release_year, :artist_id]
#     key.each { |k| return status 400 if params[k] == nil }