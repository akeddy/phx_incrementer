## Considerations

### Cache Operation
The current cache implementation creates a possible point of failure in this architecture. As the cache is a singleton instance which can be operated on by thousands of threads it is possible for the cache to become overloaded. A particularly troublesome condition exists when it is time to persist the contents of the cache to the database. This is because the GenServer responsible for persistence performs two operations
 1) Creates a local copy of the cache contents, so that a static copy exists to perform the update
 2) Removes all current entries from the cache, so that count incrementations can continue without committing the same increment

Having a cache which only stores small chunks of iteration sums removes some of the totals needing to agree accross distributed instances of the incrementation algorithm, but introduces another problem, chiefly that it is now possible for the cache to be updated between the GenServer creating a copy of the cache and the GenServer clearing it's contents. This would introduce incorrect totals on the persistence layer as valid increments would be dropped.

#### !!!! I'm not sure we need a messaging layer and not just some way of altering that cache name via a flag 

A potential solution to this problem would be to introduce a messaging layer between the persistence GenServer and all worker threads recieving increments. This messaging layer would be used by the GenServer to inform all workers that it has a copy of the cache to be submitted, and inform them of a new cache instance which should be used for continuing operations. Once it recieves the acknowledgements back of all workers accepting this the GenServer could persist and delete the existing cache.
