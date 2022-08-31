defmodule Increment.TasksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Increment.Tasks` context.
  """

  @doc """
  Generate a counter.
  """
  def counter_fixture(attrs \\ %{}) do
    {:ok, counter} =
      attrs
      |> Enum.into(%{
        key: "some key",
        value: 42
      })
      |> Increment.Tasks.create_counter()

    counter
  end
end
