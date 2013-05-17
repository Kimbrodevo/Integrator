require 'rubygems'
require 'json'
require 'fileutils'

require 'integrator/processor'

class Integrator

  def initialize(directory, processors, retry_count=0, log=$stderr)
    @path = directory
    @processors = processors
    @retry_count = retry_count   
    @log = log

    @inbox = File.join(directory, "inbox")
    @archive = File.join(directory, "archive")
    
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
        
        begin
          FileUtils.rm(File.join(@inbox, item))
        rescue
          # File may already have been moved
        end
        
        sleep pause
      end
    end
    self.unlock
    
    processed
  end

  def process(processor, json, item, retry_count)
    begin
      processor.process(json)
    rescue Exception => err
      self.log err
      self.log "Failure processing #{item}"
      if retry_count < @retry_count
        self.log "Retrying processing of #{item} will retry #{@retry_count - retry_count} more times"
        process(processor, json, item, retry_count + 1)
      else
        self.log "Unable to process #{item} after #{@retry_count} attempts: archiving for manual examination"
        FileUtils.mv(File.join(@inbox, item), File.join(@archive, item))     
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