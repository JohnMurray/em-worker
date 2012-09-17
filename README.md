# em-worker

So right now, this is really all just an idea that I'm trying to
think through and see if it's really worth it or not. So, here's
what I got.

## Problem

You need to run some type of task over and over again (let's assume
continuously w/o stop). How do you go about doing it? If it sits
behind a queue then you're in luck. There are many queue processing
libraries out there. However, let's assume that you're not sitting behind
a queue and you're not using a queue processing library. How would you
go about solving the problem?

For the sake of demonstration, let's use the following problem:

```text
You are creating a new social network (that's just what the world
needs) and you want to create an activity stream. To solve the problem
of sharing, you've implemented a model such that your items are pushed
into the stream in an "unpublished" state. 

You then have a process which will (periodically) collect all unpublished
items and push them to the user's friends' streams (based on said user's
privacy settings). That's really not that bad of a model to be honest
(seems to be how etsy does it).
```

How do you implement this process? Cron tasks? If so, how would you
deploy this on something like Heroku? Would you use their cron plugin?
If so, then you're really limiting yourself to scaling up to aggregate/
process more data. 


## Solution

I think a valid option is to use a framework like EventMachine where you
can schedule tasks to be run (on a timer, the next tick, etc.) and you
don't have to rely on any type of cron. There are lots of projects that
use this model.



## A Better Solution

Given that I feel like this is a common problem, shouldn't someone make
something that makes all of this a little easier (for EM)? That's what
I am talking about! How can we go about making a framework for writing
"workers" that uses eventmachine and extracts all of the nasty
setup/implementation details that go along with creating a service like
this in EventMachine?


## An Idea

A library (gem) that extracts the running and scheduling of the worker
processes. It would basically be a single class that looked something
like:

```ruby
class MyWorker < EM::Worker
  def do_work
    # gets called continuously
  end
end
```

There is just one method that executes and then is scheduled to run
again. There could also be some type of scheduler that determines
when a worker should be run. The default scheduler that runs something
continuously might look like:
```ruby
class EM::WorkerScheduler
  def initialize(workers)
    @workers = workers
  end

  def run
    @workers.each do |worker|
      EM.next_tick do
        worker.run!
      end
    end
  end
end

class EM::Worker
  def run!
    do_work
    EM.next_tick(&method(:do_work))
  end
end
```

I'm sure there's something wrong here that doesn't work but you 
get the point. The scheduler starts a worker task and that worker
then performs it's work and runs the `do_work` method and schedules
itself again for the next available tick. 

Obviously there could be many diffeent types of schedulers you could
pick an choose from. You could also implement your own scheduler (I
would imagine) very easily.



## Advantages?
So, what would the real advantage be? If we're talking about
continuously running processes or things that run on a timer, then I'm
not sure there is too much of an advantage to that. The equivalent EM
code would be really simple as well. I see there being two main
advantages:

+ Throttling/Scaling Scheduler
+ Running in _Standalone_ mode


### Throtting/Scaling Scheduler

### Standalone Mode
I imagine standalone mode would just be some way to run it without having
to include EM explicitely such like:

```ruby
# File my_worker.rb
class MyWorker < EM::Worker
  set_scheduler :continuous
  
  def do_work
    # ... some task ...
  end
end
```

And you could start it like:
```bash
# start it with a provided binary
worker my_worker.rb
```

Or you could start it in Ruby like:
```ruby
# main.rb (or something)
require './my_worker'

MyWorker.standalone!
```


## Suggestions?

Tell me what you think: me@johnmurray.io
