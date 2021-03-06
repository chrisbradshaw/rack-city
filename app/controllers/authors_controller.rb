class AuthorsController < ApplicationController

  get '/' do
    redirect '/posts'
  end

  get '/authors' do
    @authors = Author.all
    @posts = Post.all
    erb :'/authors/index' 
  end

  get '/authors/new' do 
    erb :'/authors/new'
  end

   post '/authors' do 
    # binding.pry
    @author = Author.create(params[:author])
    if !params["post"]["title"].empty?
      @author.posts << Post.create(title: params["post"]["title"], body: params["post"]["body"])
    end
    @author.save
    redirect to "authors/#{@author.id}"
  end

  get '/authors/:id/edit' do 
    @author = Author.find(params[:id])
    erb :'/authors/edit'
  end

  get '/authors/:id' do 
    @author = Author.find(params[:id])
    erb :'/authors/show'
  end

  post '/authors/:id' do 
    @author = Author.find(params[:id])
    @author.update(params["author"])
      if !params["post"]["title"].empty?
        @author.posts << Post.create(title: params["post"]["title"], body: params["post"]["body"])
      end
    redirect to "authors/#{@author.id}"
  end


  get '/authors/:id/delete' do
     @author = Author.find(params[:id])
     # binding.pry
     erb :"authors/delete"
   end

  post '/authors/:id/delete' do
     @author = Author.find(params[:id])
     @author.destroy
     redirect '/'
   end
  
end