# Add seed data here. Seed your database with `rake db:seed`
chris = Author.create(name: "chris")
Post.create(title: "Harry arriving in Miami", body: "December 26th – Harry arriving in Miami x51 HQ photo", author: chris)
Post.create(title: "One Direction? More like No Direction", body: "If this is your first time here, be sure to check out our gallery with over 57,000 images of One Direction in it and growing", author: chris)