require 'rubygems'
require 'date'
require 'integrator'

class FailureProcessor < Processor
  def process(json)
  	raise "Intentonal failure"
  end
end