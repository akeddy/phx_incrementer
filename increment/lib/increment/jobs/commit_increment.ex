defmodule Increment.CommitIncrement do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work() # Schedule work to be performed at some point
    {:ok, state}
  end

  def handle_info(:work, state) do
    # Do the work you desire here
    query = Cachex.Query.create(true, {:key, :value})
    cache = :persistence_cache
            |> Cachex.stream!(query)
            |> Enum.map(fn {k,v} -> %{"key" => k, "value" => v} end)
    Cachex.reset(:persistence_cache)

    Increment.Repo.transaction(fn ->
      Enum.map(cache, fn c ->
        Increment.Tasks.create_counter(c)
      end)
    end)

    schedule_work() # Reschedule once more
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 1 * 30 * 1000) # In 5 minutes
  end
end
