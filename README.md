# phx_incrementer
A simple incrementer to support distributed operations

## Usage

## Design Considerations

## Horizontal Scalability
I have included a \docker folder for deployment and scalability testing. To start the docker instance simply up the database, load balancer and as many versions of the application as required.

Ex.  
```docker-compose up -d --scale increment=2```

will start the application with two instances of increment behind the nginx load balancer. HTTP requests can be made to `localhost:3333/increment` to submit json requests.
