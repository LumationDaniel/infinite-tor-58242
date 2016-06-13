# Prerequisites

1. RVM
2. Postgres
3. Heroku account
4. Facebook developer account

# Getting Started

### Clone the project

    git clone git@github.com:cyu/pickem.git

### RVM

Trust the project ```.rvmrc``` and install ruby & gemset if necessary

### Gems

    bundle install

### Database
Copy ```config/database.sample.yml``` to ```config/database.yml``` and configure to point to your local PostgreSQL database.  Then create the database with sample data:

    rake db:create db:schema:load db:seed

### Heroku

    heroku apps:create APP_NAME

  You'll need to come up with a unique *APP_NAME*.  Then push your local database to the Heroku instance:

    heroku db:push --confirm APP_NAME

### Facebook

Create a new Facebook App (http://developers.facebook.com). You'll need to set the following values:

* **Display Name**: Pickoff - Sports Pick 'em Game

* **Namespace**: Should probably be the same as *APP_NAME*, but it has to be unique across all Facebook apps.

* **App Domains**: ```APP_NAME.herokuapp.com```

* Website with Facebook Login:
  * **Site URL**: ```http://APP_NAME.herokuapp.com```

* App on Facebook:
  * **Canvas URL**: ```http://APP_NAME.herokuapp.com/fb/```
  * **Secure Canvas URL**: ```https://APP_NAME.herokuapp.com/fb/```

Next, copy ```config/env.sample.yml``` to ```config/env.yml``` and set the following values:

    FB_CANVAS_PAGE: 'http://apps.facebook.com/APP_NAME'
    FB_APP_ID: 'APP_ID'
    FB_APP_SECRET: 'APP_SECRET'

Now run the following rake command:

    rake facebook:app_access_token

The result of this command will be the app access token.  Set this value to ```env.yml```:

    FB_ACCESS_TOKEN: 'ACCESS_TOKEN'

Finally, export this config to Heroku:

    rake heroku:config:load
