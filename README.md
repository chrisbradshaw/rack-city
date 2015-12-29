# Sinatra and Active Record: Associations and Complex Forms

## Objectives

1. Build forms that allow a user to create and edit a given resource and its associated resources. 
2. Build controller actions that handle the requests sent by such forms. 

## Introduction

As the relationships we build between our models grow and become more complex, we need to build ways for our users to interact with those models in all of their complexity. If a song has many genres, then a user should be able to create a new song *and* select from a list of existing genres and/or create a new genre to be associated to that song, all at the same time. In other words, if our models are associated in a certain way, our users should be able to create and edit instances of those models in ways that reflect those associations. 

In order to achieve this, we'll have to build forms that allow for a user to create and edit not just the given object, but any and all objects associated that are associated to it. 

## Overview

In this walk-through, we're dealing with a pet domain model. We have an `Owner` model and a `Pet` model. An owner has many pets and a pet belongs to an owner. We've already built the migrations, models and some controller actions and views. Fork and clone this lab to follow along. 

Because an owner has many pets, we want our user to be able to choose, of the existing pets in our database, which ones to associate to an owner *when an owner is being created*, and/or to create a new pet *and associate it to the owner being created*. So, our form for a new owner must also contain a way for users to select a number of existing pets to associate to that owner as well as a way for a user to create a brand new pet to get associated to that owner. The same is true of editing a given owner: a user should be able to select and de-select existing pets and/or create a new pet to associate to the owner. 

Here, we'll be taking a look together at the code that will implement this functionality. Then, you'll build out the same feature for the creation/editing of a new pet.

## Instructions

### Before you Begin

Since we've provided you with much of the code for this project, take a few moments to go through the provided files and familiarize yourself with the app. Note that an owner has a name and has many pets and a pet has a name and belongs to an owner. Note that we have two separate controllers, a Pets Controller and an Owners Controller, each of which inherit from the Application Controller. Note that each controller has a set of routes that enable the basic CRUD actions (except for delete, we won't really care about delete for the purposes of this exercise). 

**Make sure you run `rake db:migrate` and `rake db:seed` before you move on**. This will migrate our database and seed it with one owner and two pets to get us started. 

#### A note on Seed Files

The phrase "seeding the database" refers to the practice of filling up your database with some dummy data. As we develop our apps, it is essential that we have some data to work with, or we won't be able to tell if our app is working/try out the actions and features that we are building. Sinatra makes it easy for us to seed our database by providing us with something called a seed file. This file should be placed in the `db` directory: `db/seeds.rb`. This file is where you can write code that creates and saves instances of your models. 

Then, when you run the seed task provided for us by Sinatra and Rake, `rake db:seed`, the code in the seed file with be executed, thus inserting some data into your database. 

Go ahead and open up the seed file in this app, `db/seeds.rb`. You should see the following:

```ruby
 # Add seed data here. Seed your database with `rake db:seed`
sophie = Owner.create(name: "Sophie")
Pet.create(name: "Maddy", owner: sophie)
Pet.create(name: "Nona", owner: sophie)
```

This is code you should be pretty familiar with by now. We are simply creating and saving an instance of our `Owner` class and creating and saving two new instances of the `Pet` class. 

So, when `rake db:seed` is run, the code in this file is actually executed, effectively inserting that data regarding this owner and these pets into our database. 

You can write code to seed your database in any number of ways. We've done it fairly simply here, but you could imagine writing code in your seed file that sends a request to an external API and instantiates and saves instance of a class using the response from the API. You could, for example, write code that opens a directory of files and uses information about each file to create and save instances of a class. The list goes on. 

### Creating A New Owner and its Associated Pets 

Open up `app/views/owners/new.erb` and you should see the following code:

```html
<h1>Create a new Owner</h1>

<form action="/owners" method="POST">
  <label>Name:</label>
  
  <br></br>
  
  <input type="text" name="owner[name]">
  
  <input type="submit" value="Create Owner">
</form>
```

Here we have a basic form for a new owner with an field for that new owner's name. However, we want our users to be able to create an owner and select from the list of existing pets to associate to that new owner *at the same time*. So, our form should include a list of checkboxes, one for each existing pet, for our user to select from at will. 

How can we dynamically, or programmatically, generate a list of checkboxes from all the pets that are currently in our database?

#### Dynamically Generating Checkboxes

In order to dynamically generate these checkboxes, we need to load up all of the pets from the database. Then, we can iterate over them in our `owners/new.erb` view using erb tags to inject each pet's information into a checkbox form element. Let's take a look:

```html
# views/owners/new.erb
<%Pet.all.each do |pet|%>
    <input type="checkbox" name="owner[pet_ids][]" value="<%=pet.id%>"><%=pet.name%></input>
<%end%>
```
Let's break this down: 

* We use erb to get all of the pets with `Pet.all`, then we iterate over that collection of pet objects and generate a checkbox for each pet. 
* That checkbox has a `name` of `"owner[pet_ids][]"` because we want to structure our params such that the array of pet ids is stored inside the `"owner"` hash, since we are aiming to associate the pets that have these ids with this new owner. 
* We give the checkbox a value of the given pet's id. This way, when that checkbox is selected, its value, i.e. the pet's id, is what gets sent through in the params. 
* Lastly, in between the opening and closing input tags, we use erb to render the given pet's name. 

The result is that we'll have a form that looks something like this:

![](http://readme-pics.s3.amazonaws.com/create-owner-orig.png)


Let's place a  `binding.pry` in the `post '/owners'` route and submit our form so that we can get a better understanding of the params we're creating with our form. Once you hit your binding, type `params` in the terminal and you should see something like this:

```ruby
{"owner"=>{"name"=>"Adele", "pet_ids"=>["1", "2"]}}
```

I filled out my form with a name of "Adele" and I checked the boxes for "Maddy" and "Nona". So, our params have a key of `"owner"` which points to a value that is a hash that contains a key of `"name"`, with the name from the form, and a key of `"pet_ids"`, which points to an array containing the ids of all of the pets we selected via our checkboxes. Let's move on to writing the code that will create new owner *and* associate it to these pets. 

#### Creating New Owners With Associated Pets in the Controller

We are familiar with using mass assignment to create new instances of a class with Active Record. For example, if we had a hash, `owner_info` that looked like this:

```ruby
owner_info = {name: "Adele"}
```

We could easily create a new owner like this:

```ruby
Owner.create(owner_info)
```

But our params has this additional key of `"pet_ids"` that points to an array of pet id numbers. You may be wondering if we can still use mass assignment here. Well, the answer is yes. Active Record is smart enough to take that key of `pet_ids`, pointing to an array of numbers, and find the pets that have those ids and associate them to the given owner––all because we set up our associations such that an owner has many pets. Wow! Let's give it a shot. Still in your Pry console that you entered via the `binding.pry` in the `post '/owners'` action of the Owners Controller, type:

```ruby
@owner = Owner.create(params["owner"])
# => #<Owner:0x007fdfcc96e430 id: 2, name: "Adele">
```

It worked! Now, type:

```ruby
@owner.pets
#=> [#<Pet:0x007fb371bc22b8 id: 1, name: "Maddy", owner_id: 5>, #<Pet:0x007fb371bc1f98 id: 2, name: "Nona", owner_id: 5>]
```

And our usage of mass assignment did successfully associate the new owner to the pets with the id numbers from the params. 

Now that we have this working code, let's go ahead and place it in our `post '/owners'` action:

```ruby
# app/controllers/owners_controller.rb

post '/owners' do 
  @owner = Owner.create(params[:owner])
  redirect to "owners/#{@owner_id}"
end
```

Great! We're almost done with this feature. But, remember that we want a user to be able to create a new owner, select some existing pets to associate that owner too *and* have the option of creating a new pet to associate to that owner. Let's build that capability into our form.

#### Creating a New Owner and Associating it to a New Pet

This will be fairly simple. All we need to do is add a section to our form for creating a new pet:

```html
and/or, create a new pet:
    <br></br>
    <label>name:</label>
      <input  type="text" name="pet[name]"></input>
    <br></br>
```

Now our whole form should look something like this:

```html
<h1>Create a new Owner</h1>

<form action="/owners" method="POST">
  <label>Name:</label>
  
  <br></br>
  
  <input type="text" name="owner[name]">
  
  <br></br>
  
  <label>Choose an existing pet:</label>
  
  <br></br>
  
  <%Pet.all.each do |pet|%>
    <input type="checkbox" name="owner[pet_ids][]" value="<%=pet.id%>"><%=pet.name%></input>
  <%end%>
  
  <br></br>
    
    <label>and/or, create a new pet:</label>
    <br></br>
    <label>name:</label>
      <input  type="text" name="pet[name]"></input>
    <br></br>
  <input type="submit" value="Create Owner">
</form>
```

Note that we've included the section for creating a new pet at the bottom of the form and we've given that input field a name of `pet[name]`. Now, if we fill our our form like this:

![](http://readme-pics.s3.amazonaws.com/creat-owner-two.png)

When we submit our form, our params should look something like this:

```ruby
{"owner"=>{"name"=>"Adele", "pet_ids"=>["1", "2"]}, "pet"=>{"name"=>"Fake Pet"}}
```

Our `params["owner"]` hash is unchanged, so `@owner = Owner.create(params["owner"])` still works. But what about creating our new pet with a name of `"Fake Pet"` and associating it to our new owner?

For this, we'll have to grab the name our of `params["pet"]["name"]`, use it to create a new pet and add that new pet to our new owners collection of pets:

```ruby
@owner.pets << Pet.create(name: params["pet"]["name"])
```

But (you might be wondering), what if the user *does not* fill out the field to name and create a new pet? Then our params would look like this:

```ruby
{"owner"=>{"name"=>"Adele", "pet_ids"=>["1", "2"]}, "pet"=>{"name"=>" "}}
```

And the above line of code would create a new pet with a name of an empty string and associate it to our owner. That's no good. We'll need a way to control whether or not the above line of code runs, based on whether or not the `params["pet"]["name"]` value is an empty string. How about an `if` statement!

```ruby
if !params["pet"]["name"].empty?
  @owner.pets << Pet.create(name: params["pet"]["name"])
end
```

That looks pretty good. Let's put it all together:

```ruby
post '/owners' do 
  @owner = Owner.create(params[:owner])
  if !params["pet"]["name"].empty?
    @owner.pets << Pet.create(name: params["pet"]["name"])
  end
  @owner.save
  redirect to "owners/#{@owner.id}"
end
```

Let's sum up before we move on. We:

* Built a form that dynamically generated checkboxes for each of the existing pets.
* Added a field to that form for a user to fill out the name for a brand new pet. 
* Built a controller action that uses mass assignment to create a new owner and associate it to any existing pets that a user selected via checkboxes. 
* Added to that controller action code that checks to see if a user did in fact fill our the form field to name and create a new pet. If so, our code will create that new pet and add it to the newly created owner's collection of pets. 

Now that we can create a new owner with associated pets, let's build out the feature for editing that owner and its associated pets. 

### Editing Owners and Associated Pets

Our edit form will be very similar to our create form. We want a user to be able to edit everything about a user: its name as well as its associated pets. So, our form should have the standard, pre-filled name field, as well as the dynamically generated checkboxes of existing pets. This time, though, those checkboxes should be automatically checked if the given owner already owns that pet. Lastly, we'll need the same form field we built earlier for a user to create a new pet to be associated to our owner. 

Let's do it!

```htmledit.erb<h1>Update Owner</h1>

<form action="/owners/<%=@owner.id%>" method="POST">
  <label>Name:</label>
  
  <br></br>
  
  <input type="text" name="owner[name]" value="<%=@owner.name%>">
  
  <br></br>
  
  <label>Choose an existing pet:</label>
  
  <br></br>
  
  <%Pet.all.each do |pet|%>
    <input type="checkbox" name="owner[pet_ids][]" value="<%=pet.id%>" <%='checked' if @owner.pets.include?(pet) %>><%=pet.name%></input>
  <%end%>
  
  <br></br>
  
  <label>and/or, create a new pet:</label>
  <br></br>
  <label>name:</label>
    <input  type="text" name="pet[name]"></input>
  <br></br>
  <input type="submit" value="Create Owner">
</form>
```

The main different here is that we added the `checked` property to each checkbox, on the condition that the given pet is already owned by this owner, i.e included in this owner's collection of pets. We implemented this `if` statement by wrapping the `checked` attribute in erb tags, allowing us to use Ruby on our view page. 

Go ahead and make some changes to your owner using this edit form, then place a `binding.pry` in your `post '/owners/:id'` action and submit the form. Once you hit your binding, type `params` in the terminal. 

I filled out my edit form like this:

![](http://readme-pics.s3.amazonaws.com/update-owner.png)

Notice that I've unchecked the first two pets, Maddy and Nona, and checked the next two pets.

My params consequently look like this:



You should see something like this:


```ruby
{"owner"=>{"name"=>"Adele", "pet_ids"=>["3", "4"]},
 "pet"=>{"name"=>"Another New Pet"},
 "splat"=>[],
 "captures"=>["8"],
 "id"=>"8"}
```

#### Updating Owners in the Controller

Let's update our owner with this new information. Just like Active Record was smart enough to allow us to use mass assignment to not only create a new owner but to associate that owner to the pets whose ids were contained in the `"pet_ids"` array, it is smart enough to allow us to update an owner in the same way. In our Pry console in the terminal, let's execute the following:

```ruby
@owner = Owner.find(params[:id])
@owner.udpate(params[:owner])
```

Now, if we type `@owner.pets`, we'll see that the owner is no longer associated to pets 1 or 2, but is associated to the pets who have an id of 3 and 4:

```ruby
@owner.pets
# => [#<Pet:0x007fd511d5e560 id: 3, name: "SBC", owner_id: 8>,
 #<Pet:0x007fd511d5e3d0 id: 4, name: "Fake Pet", owner_id: 8>]
```

Great! Now, we need to implement similar logic as in our `post '/owners'` action to handle a user trying to make a new pet to associate to our owner:

```ruby
post '/owners/:id' do 
  @owner = Owner.find(params[:id])
  @owner.update(params["owner"])
  if !params["pet"]["name"].empty?
    @owner.pets << Pet.create(name: params["pet"]["name"])
  end
  redirect to "owners/#{@owner.id}"
end
```

And that's it! 

### Creating and Updating Pets with Associated Owners

Now that we've walked through these features together for the `Owner` model, take some time and try to build out the same functionality for `Pet`. The form to create a new pet should allow a user to select from the list of available owners and/or create a new owner to associate to a pet and the form to edit a given pet should allow the user to select/de-select existing owners and/or create a new owner. 

There are no tests for this, just use the examples above to get it working. 