class OwnersController < ApplicationController

  get '/owners' do
    @owners = Owner.all
    erb :'/owners/index' 
  end

  get '/owners/new' do 
    erb :'/owners/new'
  end

   post '/owners' do 
    @owner = Owner.create(params[:owner])
    if !params["pet"]["name"].empty?
      @owner.pets << Pet.create(name: params["pet"]["name"])
    end
    @owner.save
    redirect to "owners/#{@owner.id}"
  end

  get '/owners/:id/edit' do 
    @owner = Owner.find(params[:id])
    erb :'/owners/edit'
  end

  get '/owners/:id' do 
    @owner = Owner.find(params[:id])
    erb :'/owners/show'
  end

  post '/owners/:id' do 
    @owner = Owner.find(params[:id])
    @owner.update(params["owner"])
      if !params["pet"]["name"].empty?
        @owner.pets << Pet.create(name: params["pet"]["name"])
      end
    redirect to "owners/#{@owner.id}"
  end
  
end