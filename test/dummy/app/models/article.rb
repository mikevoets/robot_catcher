class Article < ActiveRecord::Base
  attr_accessible :title, :text
  robot_catch :title, :text
end
