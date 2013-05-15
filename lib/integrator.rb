require 'rubygems'
require 'json'

require 'integrator/processor'

class Integrator

  def initialize(directory, processors)
    @path = directory
    @processors = processors
    @inbox = File.join(directory, "inbox")
  end
  
  def load_file(filename)
    file = File.open(File.join(@inbox, filename), "r")
    json = JSON.parse(file.read)    
  end
  
  def queued
    Dir.glob(File.join(@inbox, '**', '*')).select { |file| File.file?(file) }.count
  end
  
  def poll
    processed = []
    if (self.queued > 0)      
      Dir.foreach(@inbox) do |item|
        next if item == '.' or item == '..'
        json = load_file(item)
        @processors.each { |processor|
          processor.process(json)
        }
        processed << item
      end
    end
    processed
  end
  
  def lock
    
  end
  
  def unlock
  end
end