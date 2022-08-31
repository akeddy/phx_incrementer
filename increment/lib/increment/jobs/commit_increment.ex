defmodule Increment.CommitIncrement do
  use GenServer

  @schedule Application.get_env(:increment, :persist_cache, 30 * 1000)

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    # Schedule work to be performed at some point
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    # Do the work you desire here
    query = Cachex.Query.create(true, {:key, :value})

    temp_cache =
      :persistence_cache
      |> Cachex.stream!(query)
      |> Enum.map(fn {k, v} -> %{"key" => k, "value" => v} end)

    Cachex.reset(:persistence_cache)

    # cant decide if this is a great idea or not yet
    # the transaction protects what's going in, but if we've got millions of unique keys we become much more at risk of the psql connection timing out
    Increment.Repo.transaction(fn ->
      Enum.map(temp_cache, fn c ->
        Increment.Tasks.create_counter(c)
      end)
    end)

    # Reschedule once more
    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, @schedule)
  end
end
