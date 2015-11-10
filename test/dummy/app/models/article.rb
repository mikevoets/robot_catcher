class Article < ActiveRecord::Base
  rc_validate :title, :text
end
