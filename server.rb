# server.rb
require 'sinatra'
require 'sinatra/namespace'
require 'mongoid'
require_relative 'book' # Require the Book model
require_relative 'book_serializer'

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

end
