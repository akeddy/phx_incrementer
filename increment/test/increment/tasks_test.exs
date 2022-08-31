defmodule Increment.TasksTest do
  use Increment.DataCase

  alias Increment.Tasks

  describe "counters" do
    alias Increment.Tasks.Counter

    import Increment.TasksFixtures

    @invalid_attrs %{key: nil, value: nil}

    test "list_counters/0 returns all counters" do
      counter = counter_fixture()
      assert Tasks.list_counters() == [counter]
    end

    test "get_counter!/1 returns the counter with given id" do
      counter = counter_fixture()
      assert Tasks.get_counter!(counter.id) == counter
    end

    test "create_counter/1 with valid data creates a counter" do
      valid_attrs = %{key: "some key", value: 42}

      assert {:ok, %Counter{} = counter} = Tasks.create_counter(valid_attrs)
      assert counter.key == "some key"
      assert counter.value == 42
    end

    test "create_counter/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tasks.create_counter(@invalid_attrs)
    end

    test "update_counter/2 with valid data updates the counter" do
      counter = counter_fixture()
      update_attrs = %{key: "some updated key", value: 43}

      assert {:ok, %Counter{} = counter} = Tasks.update_counter(counter, update_attrs)
      assert counter.key == "some updated key"
      assert counter.value == 43
    end

    test "update_counter/2 with invalid data returns error changeset" do
      counter = counter_fixture()
      assert {:error, %Ecto.Changeset{}} = Tasks.update_counter(counter, @invalid_attrs)
      assert counter == Tasks.get_counter!(counter.id)
    end

    test "delete_counter/1 deletes the counter" do
      counter = counter_fixture()
      assert {:ok, %Counter{}} = Tasks.delete_counter(counter)
      assert_raise Ecto.NoResultsError, fn -> Tasks.get_counter!(counter.id) end
    end

    test "change_counter/1 returns a counter changeset" do
      counter = counter_fixture()
      assert %Ecto.Changeset{} = Tasks.change_counter(counter)
    end
  end
end
