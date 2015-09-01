PromoExchange
================
[ ![Codeship Status for PromoExchange/batman](https://codeship.com/projects/44871a70-d8a4-0132-f585-769405cfda59/status?branch=master)](https://codeship.com/projects/78898)
[![Deploy to Heroku](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy)

Batman is the main application for PromoExchange's promotional products auction platform. It houses product, auction, and user information.

Requirements
-------------
- [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
- [Ruby 2.2.2](https://github.com/sstephenson/rbenv)
- [Bundler 1+](http://bundler.io/)
- [Rails 4.2.1](http://railsapps.github.io/installing-rails.html)
- [Postgres 9+](https://wiki.postgresql.org/wiki/Detailed_installation_guides)
- [Redis](http://redis.io/topics/quickstart)

Installation
------------
1. `git clone git@github.com:PromoExchange/batman.git`
2. `bundle install`
3. `bower install`
4. `bundle exec rake db:schema:load`
5. `bundle exec rake db:seed`
6. `PRODUCT_LOAD_IMAGES=true bundle exec rake product:load:all`, this will take a significant amount of time, as it is loading the database with all product information and images pulled from the internet.

Running the App
---------------
1. Ensure postgres and redis-server are running
2. `bundle exec rake resque:work QUEUE=*`
3. `bundle exec rails s`
4. Navigate to `http://localhost:3000` in your browser

Running specs
-------------
- `bundle exec rspec` from the root directory of the application

Documentation
-------------
- Documentation is available via the project [wiki](https://github.com/PromoExchange/batman/wiki)

Issues
------
Open a bug on Pivotal Tracker

Contributing
------------
- Fork repo
- Submit pull requests to the development branch

License
-------
This application and all code herein belongs to Promobidz LLC.
