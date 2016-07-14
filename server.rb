# server.rb
require 'sinatra'
require 'sinatra/namespace'
require 'mongoid'
require_relative 'book' # Require the Book model
require_relative 'serializer'

# DB Setup
Mongoid.load! "mongoid.config"

# Endpoints
get '/' do
  'Welcome to BookList!'
end

namespace '/api/v1' do

  before do
    content_type 'application/json'
  end

  helpers do
    def base_url
      @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
    end

    def json_params
      begin
        JSON.parse(request.body.read)
      rescue
        halt 400, { message: 'Invalid JSON' }.to_json
      end
    end
  end

  # Index
  get '/books' do
    books = Book.all
    [:title, :isbn, :author].each do |filter|
      books = books.send(filter, params[filter]) if params[filter]
    end

    books.map { |book| BookSerializer.new(book) }.to_json
  end

  # Show
  get '/books/:id' do |id|
    book = Book.where(id: id).first
    halt(404, { message: 'Book Not Found'}.to_json) unless book
    BookSerializer.new(book).to_json
  end

  # Create
  post '/books' do
    book = Book.new(json_params)
    if book.save
      response.headers['Location'] = "#{base_url}/api/v1/books/#{book.id}"
      status 201
    else
      status 422
      body BookSerializer.new(book).to_json
    end
  end

end
