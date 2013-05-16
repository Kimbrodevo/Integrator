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
  
  def poll(pause = 0)
    processed = []
    self.lock
    if (self.queued > 0)      
      Dir.foreach(@inbox) do |item|
        next if item == '.' or item == '..'
        json = load_file(item)
        @processors.each { |processor|
          processor.process(json)
        }
        processed << item
        
        FileUtils.rm(File.join(@inbox, item))
        sleep pause
      end
    end
    self.unlock
    
    processed
  end
  
  def lock
    @lock = File.open(File.join(@path, "lock"), File::RDWR|File::CREAT, 0644)
    @lock.flock(File::LOCK_EX)
  end
  
  def unlock
    @lock.flock(File::LOCK_UN)
  end
end