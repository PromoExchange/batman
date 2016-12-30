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

Windows Installation
--------------------
The following installation links are for a Microsoft Windows Environment.
N.B. These are untested as I do not have access to a Windows machine
- [Git CLI Installation](https://git-scm.com/download/win). This also includes a bash prompt.
- [Github UI Installation](https://desktop.github.com/). The official GIT github UI.
- [Redis](https://github.com/MSOpenTech/redis/releases)
- [Atom Editor](https://atom.io/). This is recommended, but use an editor you are most familiar with.
- [Ruby](http://rubyinstaller.org/)
- [Postgres](http://www.postgresql.org/download/windows/)
- [Bundler](http://bundler.io/)
- [node](https://nodejs.org/en/download/) N.B. Select 'include NPM' in the installation options.
- [Bower](http://bower.io/#install-bower)

Installation
------------
1. `git clone git@github.com:PromoExchange/batman.git`
2. `bundle install`
3. `bower install`
4. `bundle exec rake db:schema:load`
5. `bundle exec rake db:seed`
6. `PRODUCT_LOAD_IMAGES=true bundle exec rake product:load:all`, this will take a significant amount of time, as it is loading the database with all product information and images pulled from the internet.

Exporting from Heroku and importing locally
-------------------------------------------

1. `heroku pg:backups capture --app px-batman`
1. `heroku pg:backups download --app px-batman`
1. `pg_restore --verbose --clean --no-acl --no-owner -h localhost -U postgres -d batman_dev latest.dump`

See: [Heroku export/import](https://devcenter.heroku.com/articles/heroku-postgres-import-export)

Moving databases between apps
-----------------------------
1. Backup target: `heroku pg:backups capture -a <preview app>`
1. Copy Database: `heroku pg:copy px-batman-stage::HEROKU_POSTGRESQL_PINK_URL HEROKU_POSTGRESQL_WHITE_URL -a <preview app>`

Running the App
---------------
1. Ensure postgres and redis-server are running
2. `bundle exec rake resque:work QUEUE=*` in one command
3. `bundle exec rails s` in another command
4. Navigate to `http://localhost:3000` in your browser

Post Installation
-----------------
1. Sign in as spree@example.com/spree123
2. Navigate to `http://localhost:3000/admin`
3. Under general configuration set the site url to `http://localhost:3000`

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
