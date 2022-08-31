
ncrementer
A simple incrementer to support distributed operations

## Usage

For first time usage you'll need to ensure you have access to a postgresql instance. Dev is configured to run off of localhost, prod will take host information as env_vars.

Code is contained in the phoenix application ```increment/```
The Nginx Load Balancer conf is contained in ```nginx/```

### As standalone application
```bash
cd increment
mix deps.get
mix ecto.create
mix ecto.migrate
iex -S mix phx.server
```

### Docker
```bash
docker-compose build increment
docker-compose up -d --scale increment=2
```

## Testing
To perform tests: ```MIX_ENV=test mix test```  
To view test coverage: ```MIX_ENV=test mix test --cover```
To view coverage report: ```MIX_ENV=test mix coveralls.html```
*Test coverage is performed via ExCoverAlls.

Test coverage fits over major functions with 78.9% coverage

A note on testing: as a cache exists between command ingestion and result persistence sleeps have been introduced into the unit tests for the controller. This ensures that the cache operation is given adequate time to commit before the results are checked.

## Design Considerations

Outlined below are the major considerations I took into account when designing my approach, given the required specifications.

### Requirements
 - need to accept HTTP requests
 - needs to send HTTP responses
 - need to make Postgresql connections
 - needs horizontal scalability
 - needs vertical scalability
 - a layer of persistence would be helpful (cache)

### Scalability
Vertical scalability is a fairly easy problem for Elixir. As it is thread-based, access to additional resources is trivial. Horizontal scalability, however, still needs to be designed into the system. Tools like docker-compose or Kubernetes support such operations. Given the scope of work and familiarity docker-compose was selected for demonstrating scalability.

### Postgresql Connections
Configuring and optimizing Postgresql can create incredible performance gains; unfortunately for this exercise we are limited to an out-of-the-box Postgres implementation. Given the lack of tuning on the database, limited performance is expected under heavy load. In the best case performance impacts from high database load are expected to be slow application performance, and in the worst data loss. 

With scalability a major concern on this project, it's very easy to imagine an instance where tens to hundreds of thousands of connections to the application are made per second. I considered configuring and distributing the Postgresql instance to be outside the scope of the problem, but even with tuning there would be an upper bound on connections per second. To mitigate this, some mechanism to pool database updates would be ideal. As Elixir processes each call as an independent thread my first thought was to use a layer of short term storage or cache and combine it with a process that could perform timed releases of data from the cache. 

### Testing
For this application, testing is obviously going to be important. It would be beneficial to pick a technology stack that comes with support for testing out of the box, rather than having to create a testing framework for this application.

### Conclusions
Taking all of these considerations in mind, I decided to deploy Elixir with a Phoenix framework as the basis of the project. This provided a number of out of the box tools which address considerations listed above. Phoenix comes with an endpoint instance which can be used as an API to direct HTTP calls to a given controller. Phoenix bundles with Ecto, thereby giving a uniform database interface. Ecto also supports database migrations, allowing the design of the database to be maintained as code. With Phoenix it is possible to use a GenServer to perform periodic operations, and is a tool I have used in the past to support similar features. A performance dashboard is provided with the Live Dashboard which removes the need to tie in a full monitoring stack for this project. Phoenix also comes with a number of flags to define which pieces of the framework to deploy. In this case we removed html, assets, live view and mailer (essentially the web parts of the stack).

I chose Cachex for the batching of database queries because it was a technology with which I was familiar that could quickly meet the needs of the project. That is not to say it is the best tool for the job. It comes with guarantees about how long data can live inside the cache, which gives some confidence that your cache will not grow infinitely over a long period of uptime. 

My application of Cachex is the piece of this application that I have the most reservations about. Given the nature of how Elixir performs context switching, it seems highly possible that the context could switch between the persistence daemon copying the cache and it being cleared. In this case we could have any number of updates to counts which would be lost by the application. In testing I have yet to find such an instance but I would consider this an error case to watch for. In production having the Elixir app send to some sort of message broker (such as Kafka) with a suite of services to persist to the database would be more robust.

## Horizontal Scalability
I have included docker files for deployment and scalability testing. To start the docker instance simply up the database, load balancer and as many versions of the application as required.

Ex.  
```docker-compose up -d --scale increment=2```

The above command will start the application with two instances of increment behind the nginx load balancer. HTTP requests can be made to `localhost:3333/increment` to submit json requests.

