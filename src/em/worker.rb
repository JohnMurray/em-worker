# TODO add better commets (TomDoc style! :-])
class EM::Worker

  # used to set scheduler in class-definition of child-class
  def self.scheduler(scheduler, &block)
    @scheduler = case scheduler
                 when :continual; ContinualScheduler.new(&block)
                 when :periodic;  PeriodicScheduler.new(&block)
                 when :scalable;  ScalableScheduler.new(&block)
                 end
  end


  # Run the worker in stand-alone mode
  def self.standalone!
    worker = self.new
    if worker.respond_to? :do_work
      worker.schedule!
    end
  end


  # Should be called when work in child-class is complete (up to
  # the client/implementer to call this method).
  def done
    schedule!
  end
  

  #Schedule the worker against the scheduler
  def schedule!
    @scheduler.schedule(self)
  end



  # some defaults
  scheduler :continual

end
