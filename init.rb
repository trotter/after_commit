ActiveRecord::Base.class_eval do 
  include AfterCommit::ActiveRecord
  include AfterCommit::TestBypass if RAILS_ENV == 'test'
end

Object.subclasses_of(ActiveRecord::ConnectionAdapters::AbstractAdapter).each do |klass|
  klass.send(:include, AfterCommit::ConnectionAdapters)
end
