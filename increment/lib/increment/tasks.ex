defmodule Increment.Tasks do
  @moduledoc """
  The Tasks context.
  """

  import Ecto.Query, warn: false
  alias Increment.Repo

  alias Increment.Tasks.Counter

  @doc """
  Returns the list of counters.

  ## Examples

      iex> list_counters()
      [%Counter{}, ...]

  """
  def list_counters do
    Repo.all(Counter)
  end

  @doc """
  Gets a single counter.

  Raises `Ecto.NoResultsError` if the Counter does not exist.

  ## Examples

      iex> get_counter!(123)
      %Counter{}

      iex> get_counter!(456)
      ** (Ecto.NoResultsError)

  """
  def get_counter!(id), do: Repo.get!(Counter, id)

  @doc """
  Creates a counter.

  ## Examples

      iex> create_counter(%{field: value})
      {:ok, %Counter{}}

      iex> create_counter(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_counter(attrs \\ %{}) do
    %Counter{}
    |> Counter.changeset(attrs)
    |> Repo.insert(
      on_conflict: [inc: [value: Map.get(attrs, "value", 0)]],
      conflict_target: :key,
      returning: true
    )
  end

  @doc """
  Updates a counter.

  ## Examples

      iex> update_counter(counter, %{field: new_value})
      {:ok, %Counter{}}

      iex> update_counter(counter, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_counter(%Counter{} = counter, attrs) do
    counter
    |> Counter.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a counter.

  ## Examples

      iex> delete_counter(counter)
      {:ok, %Counter{}}

      iex> delete_counter(counter)
      {:error, %Ecto.Changeset{}}

  """
  def delete_counter(%Counter{} = counter) do
    Repo.delete(counter)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking counter changes.

  ## Examples

      iex> change_counter(counter)
      %Ecto.Changeset{data: %Counter{}}

  """
  def change_counter(%Counter{} = counter, attrs \\ %{}) do
    Counter.changeset(counter, attrs)
  end

  @doc """
  Caches a counter.

  ## Examples

      iex> cache_counter(%{field: value})
      {:ok, _int}

      iex> cache_counter(%{field: bad_value})
      {:error, _integer}

  """
  def cache_counter(attrs \\ %{})

  def cache_counter(%{"key" => key, "value" => value}) do
    Cachex.incr(:persistence_cache, key, value, initial: 0)
  end

  def cache_counter(%{}) do
    {:error, 0}
  end
end
