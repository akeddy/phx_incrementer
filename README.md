# phx_incrementer
A simple incrementer to support distributed operations

## Usage

For first time usage you'll need to ensure you have access to a postgresql instance. Dev is configured to run off of localhost, prod will take host information as env_vars.

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
to perform tests: ```MIX_ENV=test mix test```  
to view test coverage ```MIX_ENV=test mix test --cover``` (Test coverage is performed via ExCoverAlls)  
to view coverage report: ```MIX_ENV=test mix coveralls.html```

Currently major functions are covered with reasonable test coverage. Could always use more, but limitations on time and this being a prototype come into play.

A note on testing: as a cache exists between command ingestion and result persistence sleeps have been introduced into the unit tests for the controller. This ensures that the cache operation is given adequate time to commit before the results are checked.

## Design Considerations

When designing this system for the required specifications there were a number of considerations required. Outlined below are the major considerations I took into account when designing my approach.

### Scalability
Vertical scalability is a fairly easy problem for Elixir. As it is highly thread based access to additional resources is trivial. Horizontal scalability however still needs to be designed into the system. Tools like docker-compose or Kubernetes support such operations. As I' m more familiar with docker-compose for a small deployment like this it's likely the better tool for the job.

### Postgresql Connections
This is potentially the most sensitive portion of project. Configuring and optimizing Postgresql can create incredible performance gains, unfortunately for this exercise we are limited to an out of the box postgres implementation. Such an instatiation will suffer from tens of thousands of simultaneus connections, impacting performance in the best case and totally blocking in the worst. With scalability a major concern on this project it's very easy to imagine an instance where tens to hudreds of thousands of connections to the application are made per second. I considered configuring and distributing the Postgresql instance to be outside the scope of the problem, but even with tuning there would be an upper bound on connections per second the database could take, especially with many worker pods. To mitigate this some mechanism to pool database updates would be ideal. In an Elixir environment this would require some level of storage, mixed with some application that could perform timed releases of data. Depending on the time bound it would be ideal to implement our most simple case of 1 call to increment creating 1 call to the persistence layer, but if there's more time in the project it would be better to cache these calls to persistence in some way and call them back in a transaction.

### Testing
For this application testing is obviously going to be important. It would be beneficial to pick a setup that comes with support for testing out of the box, rather than having to create a testing framework for this application.

### Tools
 - need to accept HTTP requests
 - needs to send HTTP responses
 - need to make Postgresql connections
 - needs horizontal scalability
 - needs vertical scalibility
 - a layer of persistence would be helpful (cache)

### Conclusions
Taking all of these considerations in mind I decided to deploy Elixir with a Phoenix framework as the basis of the project. This provided a number of out of the box tools which address considerations listed above. Phoenix comes with an endpoint instance which can be used as an api to direct HTTP calls to a given controller. Phoenix bundles with Ecto, thereby giving a uniform database interface. Ecto also supports database migrations allowing the design of the database to be maintained as code, and easily transported as part of the project. Phoenix supports GenServers, which I have used in the past to act as cron-ed daemons to perform periodic work (in this case submitting batches of Postgres requests). A rudementary performance dashboard is provided with the Live Dashboard which removes the need to tie in a full monitoring stack for this project. Phoenix also comes with a number of flags do define which pieces of the framework to deploy. In this case we removed html, assets, live view and mailer (essentially the web parts of the stack).

I chose Cachex for the batching of persistence queries primarily because it was a technology that suited the need which I had used before. It comes with guarantees about how long data can live inside the cache which gives some confidence that your cache will not grow infinitely over sufficiently long updates. Of course a sufficiently persistent stream of inputs could keep every key alive indefinitely while creating new ones which would make this a poor solution. Cachex is the single piece of this applications I have the most reservations about. Given the nature of how Elixir performs context switching it seems highly possible that the context could switch between the persistence daemon copying the cache and it being cleared. In this case we could have any number of updates to counts which would be lost by the application. In testing I have yet to find such an instance but I would consider that technical debt of this implementation, and an error case to watch for. In production having the Elixir app send to some sort of message broker like Kafka which a suite of services to persist to the database would be more robust.

## Horizontal Scalability
I have included a \docker folder for deployment and scalability testing. To start the docker instance simply up the database, load balancer and as many versions of the application as required.

Ex.  
```docker-compose up -d --scale increment=2```

will start the application with two instances of increment behind the nginx load balancer. HTTP requests can be made to `localhost:3333/increment` to submit json requests.
