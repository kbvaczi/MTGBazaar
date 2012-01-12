class Test2 < ActiveRecord::Base
  has_one :buyer, :through => :transaction, :source => :test1
  has_one :transaction
end
