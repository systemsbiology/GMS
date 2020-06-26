# GMS

The Genome Management System (GMS) is a Ruby on Rails website with a MySQL backend running
on Apache using Passenger that helps to organize the metadata for whole genome sequencing.


#########################################################
####  GENOME MANAGEMENT SYSTEM INSTALL DOCUMENTATION ####
#########################################################

The Genome Management System (GMS) is a website that allows researchers to
store data about the location of Whole Genome Sequencing (WGS) files.  It
is designed for use with Complete Genomics Inc (CGI) files, but can also be
used to store other types of files.


## REQUIREMENTS

The Genome Management System (GMS) is a Ruby on Rails website that runs on
Ruby 2.7.0, Rails 6, MySQL, Apache, and Passenger.  It includes Bootstrap,
jQuery and tablesorter.

## INSTALLATION

In general, download the appropriate latest version from the website listed.
Unzip and untar the file, go into the directory, type ./configure and then
make.  If you do not have root access, then you need to supply a prefix for
where the software should be installed to configure.  All software should be
installed to the same location, although MySQL is typically installed to a
separate hard disk than the web server is installed on.

1. Install Ruby

   http://www.ruby-lang.org/en/downloads/

2. Install RubyGems

   http://rubygems.org/pages/download

3. Install Rails

   > gem install rails

4. Install MySQL

   http://www.mysql.com/downloads/mysql/

5. Install Apache

   http://httpd.apache.org/download.cgi

6. Install Passenger

   > gem install passenger
   > passenger-install-apache2-module

7.  Configure Apache

   Copy the configuration output produced by passenger-install-apache2-module
   Open up the httpd.conf in the location where you installed Apache.
   Add this into the httpd.conf near the top.  There should be three directives:
   LoadModule, PassengerRoot, PassengerRuby
   In addition, you'll need to define a VirtualHost directive that points to a
   directory on the server that will serve as the base directory for the website.
   For GMS, this needs to point to the public directory, so /path/to/gms/public
   In addition, RailsEnv should be set to production.

   <VirtualHost *:80>
      ServerName pedigree.server
      ServerAlias pedigree.server
      DocumentRoot "/www/software/gms/current/public"
      ErrorLog "/www/logs/software/gms/pedigree-error_log"
      CustomLog "/www/logs/software/gms/pedigree-access_log" common
      DirectoryIndex index.html
      RailsEnv production

      <Directory "/www/software/gms/current/public">
          Options All -MultiViews
          Order deny,allow
          Satisfy Any
      </Directory>
      # Remove the www
      RewriteCond %{HTTP_HOST} ^www.pedigree.server$ [NC]
      RewriteRule ^(.*)$ http://pedigree.server/$1 [R=301,L]
  </VirtualHost>

8.  Install GMS

    Untar the GMS tar into the proper place.
    Open gms/config/environment.rb in an editor
    Change the path for PEDIGREE_ROOT.

    Open gms/config/database.yml
    Change the login and password for the MySQL server

    Install the GMS Gems:
    > bundle install

    Install the GMS javascripts:
    > yarn install

You should now be able to start MySQL and start the Apache webserver and go to the
URL where you installed GMS and it should show you an index page.

----------------------------------------

Capistrano set up requires that you have a shared directory in your deployment area.
The shared directory should have config, logs, pids, system.  Capistrano will create
the bundle directory in there with the current deploy file.  The config needs to have
the database.yml file that's appropriate for connecting to your database.  The other
directories just have to be there (though logs may need production.log).  The config
directory of GMS requires that you specify a user.

config/user.rb
set :user, "username"


-----

If installing mysql gem fails, may need to specify the srcdir for mysql

`gem install mysql2 -v '0.5.3' -- --srcdir=/usr/include/mysql`