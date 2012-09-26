class EM::Worker

  # Public: Set the scheduler that the worker will use to schedule itself
  #
  # scheduler - symbol representing any of the available schedulers
  #             (defaults to :continual)
  # block     - optional block that will be passed to the scheduler. See
  #             the scheduler specific documentation to see if/what-kind-of
  #             block can/should be used.
  #
  # Examples
  #
  #   class MyWorker < EM::Worker
  #     scheduler :continual
  #   end
  #
  #   class MyWorker < EM::Worker
  #     scheduler :periodic do
  #       time = Time.now
  #       if time.peak_traffic?
  #         1.sec
  #       else
  #         30.sec
  #       end
  #     end
  #   end
  #
  # Returns and instance of the scheduler being used.
  # Raises RuntimeError if provided scheduler is not a valid scheduler.
  def self.scheduler(scheduler = :continual, &block)
    @scheduler = case scheduler
                 when :continual; ContinualScheduler.new(&block)
                 when :periodic;  PeriodicScheduler.new(&block)
                 when :scalable;  ScalableScheduler.new(&block)
                 else raise "Invalid scheduler provided #{scheduler.inspect}"
                 end
  end


  # Public: Run the worker process outside of an explicit EM loop. It will
  # start a reactor and tell the scheduler to start scheduling (thus the
  # worker will start working!)
  #
  # Examples
  #
  #   class MyWorker < EM::Worker
  #     # ... code ...
  #     standalone! if $0 == __FILE__
  #   end
  #   
  #   # or
  #   
  #   class MyWorker < EM::Worker
  #     # ... code ...
  #   end
  #   MyWorker.standalone!
  #   
  # Returns value of worker.schedule!
  def self.standalone!
    worker = self.new
    worker.schedule!
  end


  # Public: Is required to be called by the client worker-class when they
  # worker is done working (for this round anyways) so that the worker can
  # be re-scheduled.
  #
  # Returns value of worker.schedule!
  def done
    schedule!
  end
  

  private

  # Private: Schedule the worker against the worker's scheduler.
  #
  # Returns result of @scheduler.schedule.
  # Raises RuntimeError if worker does not implement 'do_work' method.
  def schedule!
    if worker.respond_to? :do_work
      @scheduler.schedule(self)
    else
      raise 'Worker does not implement "do_work" method'
    end
  end



  # set the default values for a Worker
  scheduler :continual

end
