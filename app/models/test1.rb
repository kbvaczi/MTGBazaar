class Test1 < ActiveRecord::Base
  has_many :purchases, :through => :transactions, :source => :test2
  has_many :transactions
end
