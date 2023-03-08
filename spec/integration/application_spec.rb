require "spec_helper"
require "rack/test"
require_relative "../../app"

def reset_artists_table
  seed_sql = File.read("spec/seeds/artists_seeds.sql")
  connection = PG.connect({ host: "127.0.0.1", dbname: "music_library_test" })
  connection.exec(seed_sql)
end

def reset_albums_table
  seed_sql = File.read("spec/seeds/albums_seeds.sql")
  connection = PG.connect({ host: "127.0.0.1", dbname: "music_library_test" })
  connection.exec(seed_sql)
end

describe Application do
  # This is so we can use rack-test helper methods.
  include Rack::Test::Methods

  # We need to declare the `app` value by instantiating the Application
  # class so our tests work.
  let(:app) { Application.new }

  before(:each) { reset_albums_table }
  before(:each) { reset_artists_table }

  context "GET /albums" do
    it "returns a list of all albums" do
      response = get("/albums")
      expect(response.body).to include ('<a href="/albums/1">Doolittle</a>')
      expect(response.body).to include ('<a href="/albums/2">Surfer Rosa</a>')
    end
  end

  context "POST /albums" do
    it "creates a new album" do
      response =
        post("/albums", title: "Voyage", release_year: "2022", artist_id: "2")
      expect(response.status).to eq(200)
      expect(response.body).to eq ("")
    end
  end

  context "GET /artists" do
    it "returns a list of all artists" do
      response = get("/artists")
      expected_response = "Pixies, ABBA, Taylor Swift, Nina Simone"
      expect(response.status).to eq(200)
      expect(response.body).to eq (expected_response)
    end
  end

  context "POST /artists" do
    it "creates a new artist" do
      response = post("/artists", name: "Wild nothing", genre: "Indie")
      expect(response.status).to eq(200)
      response_2 = get("/artists")
      expected_response =
        "Pixies, ABBA, Taylor Swift, Nina Simone, Wild nothing"
      expect(response_2.status).to eq(200)
      expect(response_2.body).to eq (expected_response)
    end
  end

  context "GET /albums/:id" do
    it "returns the HTML content for a single album" do
      response = get("/albums/1")
      expect(response.body).to include ("Release year: 1989")
      expect(response.body).to include ("Artist: Pixies")
    end
  end
end
