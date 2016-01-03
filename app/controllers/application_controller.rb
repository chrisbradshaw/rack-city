class ApplicationController < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :session_secret, "my_application_secret"
  set :views, Proc.new { File.join(root, "../views/") }

    get "/about" do
    @title = "About Me"
    erb :"pages/about"
  end


    helpers do
    def title
      if @title
        "#{@title} -- Blogs"
      else
        "This is the blog"
      end
    end

 
    def post_date(time)
     time.strftime("%d %b %Y")
    end


    def post_show_page?
        request.path_info =~ /\/posts\/\d+$/
    end

     def author_show_page?
        request.path_info =~ /\/authors\/\d+$/
    end

end

end