Heroku buildpack that will install pdftk into /app/bin on Heroku. Supports **heroku-24**.

## How to use

1. Add this buildpack to your app. 
2. Add the libgcj.so.* to your search path: `heroku config:set LD_LIBRARY_PATH=/app/bin`
3. Use /app/bin/pdftk. BTW, the default PATH includes /app/bin, so this might happen automatically.

## How to upgrade PDFTK

Update the tarball_url line in scripts/build.sh

    heroku create
    heroku config:set BUILDPACK_URL=https://github.com/dgmdan/heroku-buildpack-apt
    git push heroku master

Now you'll have a new Heroku app on the default stack that runs the `scripts/build.sh` script in this buildpack. That script will download the most recent PDFTK source and configure it with default options.

Use `heroku logs -t` to see when compilation is done. It'll start showing dots..

`heroku open`

1. Download the generated pdftk.zip
2. Chmod +x them
3. put them into `binaries-$STACK/` into this buildpack. $STACK shall be the name of your stack as given in the Heroku $STACK variable.

`heroku ps:scale web=0` to turn off the dyno.


# Differences between this and the original repo

* no binaries included in this buildpack
* this repo relies on [heroku-buildpack-apt](https://elements.heroku.com/buildpacks/heroku/heroku-buildpack-apt) for 
  installation of apt packages, rather than including .deb's for these packages in this buildpack. You must add
  `heroku-buildpack-apt` and it must be before `heroku-pdftk-buildpack` in your app's buildpacks.
