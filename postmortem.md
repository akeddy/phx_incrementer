# Overview 

# Development Pain Points
It was interesting to me that the parts of the stack I had used before (Elixir, Phoenix, Docker) caused me the most pain, while the piece I had not implemented before (the load balancer) went relatively smoothly. While I have experience implementing horizontally scalable pipelines and redundant systems, I'd never implemented load balancing in docker before. In the past that had been an abstracted step done at the DevOps level, or I'd done it manually by defining individual containers with unique parameters to create my horizontally scaled system. Exposure to the `--scale` flag in docker-compose was surprisingly pain free. Conversely, Elixir and Phoenix caused me quite the headache when it came to dockerization. This came down to a recent (at least from my perspective) upgrade in the Elixir ecosystem; the upgrade of Erlang/OTP to version 25. When using the newest Elixir Docker container (1.13.4) you unfortunately get version 24 of the Erlang/OTP environment. When your libraries expect version 25 this causes a number of compilation issues. Coupling this with a few increments of the Phoenix framework from the last time I ran `mix phx.new` and I ended up needing to debug a bit more of the foundation of my application than I expected.

Even with the debugging, running a fresh `mix phx.new` was rather exciting, as it gave me an excuse to see many of the improvements made in the application scafolding and boilerplate. Introduction of the new "runtime.conf" instead of the expected "prod.secrets.exs" made for quite a surprise in some compilation errors and where mystery values were being pulled from.

I was surprised to learn in testing that the application could not handle 100k immediate submissions at once. Based on the results of initial tests this appeared to happen because postgres would become overwhelmed. Under this architecutre 1 increment task created 1 postgres insert, which would then be held open for a period of time. Admittedly: 100k connections to postgres from one machine is excessive, but I was surprised to see this as a performance bottleneck so soon. It became clear here that some sort of batching was required for postgres submissions as transactions.

Even after performing some batches I found there to performance bottlenecks of an indeterminate nature. Sending a unit test with 100K increments would cause timeouts, while sending 100k via curl requests seemed to work reasonably well. I suspect this was due to the speed at which the tests perform (100k curls was quite slow, while unit tests we remarkably quick).

## Cache Operation
The current cache implementation creates a possible point of failure in this architecture. As the cache is a singleton instance which can be operated on by thousands of threads it is possible for the cache to become overloaded. A particularly troublesome condition exists when it is time to persist the contents of the cache to the database. This is because the GenServer responsible for persistence performs two operations
 1) Creates a local copy of the cache contents, so that a static copy exists to perform the update
 2) Removes all current entries from the cache, so that count incrementations can continue without committing the same increment

As dicussed in the README this introduces the problem that it is now possible for the cache to be updated between the GenServer creating a copy of the cache and the GenServer clearing it's contents. This would introduce incorrect totals on the persistence layer as valid increments would be dropped. For a production ready system some other mechanism to persist between ingestion and the database should be explored. At minimum a method to ensure both operations happen at once is needed.

Without protection another possible solution to the problem would be to instantiate a new cache for use by all worker threads when persistence starts. This would guarantee all new workers are using a clean cache that is not being operated on. A different cache system would likely be needed given that Cachex is instatiated at runtime.

# Scalability
## Horizontal Scaling
A note on scalability: while Elixir applications are capable of being incredibly performant on their own there is obviously some level of performance for which this single instance will no longer be able to handle the load. A docker environment is provided with the application to demo the horizontal scalability of this application, leveraging the `--scale` flag and a load balancer. This allows arbitrary instances of the application to be started and have traffic routed. All application instances connect to the same database layer and provide continuous updates to the data there. This single database instance represents an area of concern for sufficiently large deployments. 
 
## Vertical Scaling
Vertical scaling through increased resources is readily available to this Elixir application due to the thread based nature of the language.

# For the Future
For the future of this application I'd like to see authentication + a telemetry dashboard introduced. If possible integrating the Prometheus metrics via libraries such as PromEx would be an excellent move forward. I have not significantly performance tested even a single instance of the application, and I would be very interested to see if there is a threshold of traffic  that would cause cache misses to occur. I suspect we'd eventually see them. 

## Production Readiness
There are many reasons I do not consider this application production ready. The simplest reasons there are the lack of performance and security testing. While I used a Phx framework to expidite development (as covered in the README) this is far too much overhead for an application that is so simple. For production it would be much better to develope this as a standalone script. Finally I question the scalability of our database, There has been no tuning performed on it, and I suspect it would start to show it's many out-of-the-box cracks under a signifcant load.

