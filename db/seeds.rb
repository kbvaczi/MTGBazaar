# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)



#--------
# Users #
#--------
@user = User.create(:username => "Ken", :email => 'kvaczi@gmail.com', :password => "uiopkl", :confirmed_at => "2011-07-08 15:05:55", :confirmation_sent_at => "2011-07-08 15:05:27")
@user.confirmed_at = Time.now()
@user.account = Account.create(:first_name => "Ken")
@user.save

@user = User.create(:username => "Chris", :email => 'chris@mtgbazaar.com', :password => "uiopkl", :confirmed_at => "2011-07-08 15:05:55", :confirmation_sent_at => "2011-07-08 15:05:27")
@user.account = Account.create(:first_name => "Chris")