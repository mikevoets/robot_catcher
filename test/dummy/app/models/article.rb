class Article < ActiveRecord::Base
  robot_validate :title, :text
end
