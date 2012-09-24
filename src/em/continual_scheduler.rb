class EM::ContinualScheduler
  # TODO look at worker.rb and re-factor/re-think
  def schedule(worker)
    EM.next_tick { worker.do_work }
  end
end
