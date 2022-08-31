# Overview 

# Development Pain Points
It was interesting to me that the parts of the stack I had used before (Elixir, Phoenix, Docker) caused me the most pain, while the piece I had not implemented before (the load balancer) went relatively smoothly. While I have experience implementing horizontally scalable pipelines and redundant systems, I'd never implemented load balancing in docker before. In the past that had been an abstracted step done at the DevOps level, or I'd done it manually by defining individual containers with unique parameters to create my horizontally scaled system. Exposure to the `--scale` flag in docker-compose was surprisingly pain free. Conversely, Elixir and Phoenix caused me quite the headache when it came to dockerization. This came down to a recent (at least from my perspective) upgrade in the Elixir ecosystem; the upgrade of Erlang/OTP to version 25. When using the newest Elixir Docker container (1.13.4) you unfortunately get version 24 of the Erlang/OTP environment. When your libraries expect version 25 this causes a number of compilation issues. Coupling this with a few increments of the Phoenix framework from the last time I ran `mix phx.new` and I ended up needing to debug a bit more of the foundation of my application than I expected.

Even with the debugging, running a fresh `mix phx.new` was rather exciting, as it gave me an excuse to see many of the improvements made in the application scafolding and boilerplate. Introduction of the new "runtime.conf" instead of the expected "prod.secrets.exs" made for quite a surprise in some compilation errors and where mystery values were being pulled from.
  
## Cache Operation
The current cache implementation creates a possible point of failure in this architecture. As the cache is a singleton instance which can be operated on by thousands of threads it is possible for the cache to become overloaded. A particularly troublesome condition exists when it is time to persist the contents of the cache to the database. This is because the GenServer responsible for persistence performs two operations
 1) Creates a local copy of the cache contents, so that a static copy exists to perform the update
 2) Removes all current entries from the cache, so that count incrementations can continue without committing the same increment

Having a cache which only stores small chunks of iteration sums removes some of the totals needing to agree accross distributed instances of the incrementation algorithm, but introduces another problem, chiefly that it is now possible for the cache to be updated between the GenServer creating a copy of the cache and the GenServer clearing it's contents. This would introduce incorrect totals on the persistence layer as valid increments would be dropped.

#### !!!! I'm not sure we need a messaging layer and not just some way of altering that cache name via a flag 
 
A potential solution to this problem would be to introduce a messaging layer between the persistence GenServer and all worker threads recieving increments. This messaging layer would be used by the GenServer to inform all workers that it has a copy of the cache to be submitted, and inform them of a new cache instance which should be used for continuing operations. Once it recieves the acknowledgements back of all workers accepting this the GenServer could persist and delete the existing cache.

# Scalability
## Horizontal Scaling
A note on scalability: while Elixir applications are capable of being incredibly performant on their own there is obviously some level of performance for which this single instance will no longer be able to handle the load. When this happens there are two common strategies which can be deployed:

 1) region specific standalone instances of the application
 2) replication of the application (via Kubernetes/Docker)

We demo solution 2) here via the provided docker-compose environment where by use of the `--scale` flag and a load balancer arbitrary instances of the application can be started and have traffic routed. All application instances connect to the same database layer and provide continuous updates to the data there. 
 
## Vertical Scaling
Vertical scaling through increased resources is readily available to this Elixir application due to the thread based nature of the language.

# For the Future

There are many reasons I do not consider this application production ready. First is of course going to be the limited amount of performance testing it has undergone. Secondly, it lacks even a rudimentary authorization protocol, so it's security evaluation is similarly under developed. While I used a Phx framework to expidite development (as covered in the README) this is far too much overhead for an application that is so simple. For production it would be much better to develope this as a standalone script. Finally I question the scalability of our database, There has been no tuning performed on it, and I suspect it would start to show it's many out-of-the-box cracks under a signifcant load.

For the future of this application I'd like to see authentication + a telemetry dashboard introduced. If possible integrating the Prometheus metrics via libraries such as PromEx would be an excellent move forward. I have not significantly performance tested even a single instance of the application, and I would be very interested to see if there is a threshold of traffic  that would cause cache misses to occur. I suspect we'd eventually see them. 
