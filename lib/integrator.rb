require 'rubygems'
require 'json'
require 'fileutils'

require 'integrator/processor'

class Integrator

  def initialize(directory, processors, log=$stderr, retry_count=0)
    @path = directory
    @processors = processors
    @retry_count = retry_count   
    @log = log

    @inbox = File.join(directory, "inbox")
  end
  
  def load_file(filename)
    file = File.open(File.join(@inbox, filename), "r")
    json = JSON.parse(file.read)    
  end
  
  def queued
    Dir.glob(File.join(@inbox, '**', '*')).select { |file| File.file?(file) }.length
  end
  
  def poll(pause = 0)
    processed = []
    self.lock
    if (self.queued > 0)      
      Dir.foreach(@inbox) do |item|
        next if item == '.' or item == '..'

        self.log "Processing #{item}"
        
        json = load_file(item)
        @processors.each { |processor|
          self.process(processor, json, item, 0)
        }
        processed << item
        
        FileUtils.rm(File.join(@inbox, item))
        sleep pause
      end
    end
    self.unlock
    
    processed
  end

  def process(processor, json, item, retry_count)
    begin
      processor.process(json)
    rescue
      self.log "Failure processing #{item}"
      if retry_count < @retry_count
        self.log "Retrying processing of #{item} will retry #{@retry_count - retry_count} times"
        process(processor, json, retry_count + 1)
      end
    end    
  end
  
  def lock
    @lock = File.open(File.join(@path, "lock"), File::RDWR|File::CREAT, 0644)
    @lock.flock(File::LOCK_EX)
  end
  
  def unlock
    @lock.flock(File::LOCK_UN)
  end

  def log(message)
    @log.puts message
  end
end