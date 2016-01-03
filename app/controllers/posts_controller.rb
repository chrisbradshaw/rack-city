class PostsController < ApplicationController

  get '/posts' do
    @posts = Post.all
    erb :'/posts/index' 
  end

  get "/posts/new" do
      @title = "New Post"
      @post = Post.new
    erb :"posts/new"
    end

  post '/posts' do 
    @post = Post.new(params[:post])
    if !params["author"]["name"].empty?
      @post.author = Author.new(name: params[:author][:name])
    end
    @post.save
    redirect to "posts/#{@post.id}"
  end


  get '/posts/:id' do
      @authors = Author.all
      @post = Post.find(params[:id])
      erb :'/posts/show'
    end

  get '/posts/:id/edit' do 
      @post = Post.find(params[:id])
      erb :'/posts/edit'
    end
  
    post '/posts/:id' do
      @post = Post.find(params[:id])
      @post.update(params[:post])
      @post.author = Author.create(name: params["author"]["name"]) unless params["author"]["name"].empty?
      @post.save
      redirect to "posts/#{@post.id}"
    end

  get '/posts/:id/delete' do
     @post = Post.find(params[:id])
     # binding.pry
     erb :"posts/delete"
   end

  post '/posts/:id/delete' do
     @post = Post.find(params[:id])
     @post.destroy
     redirect '/'
   end
end