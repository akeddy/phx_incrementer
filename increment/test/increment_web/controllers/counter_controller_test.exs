defmodule IncrementWeb.CounterControllerTest do
  use IncrementWeb.ConnCase

  import Increment.TasksFixtures

  alias Increment.Tasks.Counter

  @create_attrs %{
    key: "some key",
    value: 42
  }
  @invalid_attrs %{key: nil, value: nil}
  @missing_attrs %{}

  setup %{conn: conn} do
    sleep_time = Application.get_env(:increment, :persist_cache, 30 * 1000)
    {:ok, conn: put_req_header(conn, "accept", "application/json"), sleep_time: sleep_time}
  end

  describe "index" do
    test "raise error on disabled common path", %{conn: conn} do
      assert_raise ArgumentError, fn -> get(conn, Routes.counter_path(conn, :index)) end
    end
  end

  describe "create counter" do
    test "renders counter when data is valid", %{conn: conn, sleep_time: sleep_time} do
      conn = post(conn, Routes.counter_path(conn, :create), @create_attrs)
      assert "" = response(conn, 202)
      # for cache commits
      :timer.sleep(sleep_time)
      counter = Increment.Repo.get_by(Counter, key: @create_attrs.key)

      assert %Increment.Tasks.Counter{
               key: "some key",
               value: 42
             } = counter
    end

    test "update counter 100 times", %{conn: conn, sleep_time: sleep_time} do
      cap = 100
      range = 1..cap
      total = 42 * cap

      conn =
        Enum.reduce(range, conn, fn _x, acc ->
          post(conn, Routes.counter_path(acc, :create), @create_attrs)
        end)

      assert "" = response(conn, 202)

      # for cache commits
      :timer.sleep(sleep_time)
      counter = Increment.Repo.get_by(Counter, key: @create_attrs.key)

      assert %Increment.Tasks.Counter{
               key: "some key",
               value: ^total
             } = counter
    end

    test "update counter 1000 times", %{conn: conn, sleep_time: sleep_time} do
      cap = 1000
      range = 1..cap
      total = 42 * cap

      conn =
        Enum.reduce(range, conn, fn _x, acc ->
          post(conn, Routes.counter_path(acc, :create), @create_attrs)
        end)

      assert "" = response(conn, 202)

      # for cache commits
      :timer.sleep(sleep_time)
      counter = Increment.Repo.get_by(Counter, key: @create_attrs.key)

      assert %Increment.Tasks.Counter{
               key: "some key",
               value: ^total
             } = counter
    end

    test "update counter 10_000 times", %{conn: conn, sleep_time: sleep_time} do
      cap = 10_000
      range = 1..cap
      total = 42 * cap

      conn =
        Enum.reduce(range, conn, fn _x, acc ->
          post(conn, Routes.counter_path(acc, :create), @create_attrs)
        end)

      assert "" = response(conn, 202)

      # for cache commits
      :timer.sleep(sleep_time)
      counter = Increment.Repo.get_by(Counter, key: @create_attrs.key)

      assert %Increment.Tasks.Counter{
               key: "some key",
               value: ^total
             } = counter
    end

    @tag timeout: 600_000
    @tag :big_test
    test "update counter 100_000 times", %{conn: conn, sleep_time: sleep_time} do
      cap = 100_000
      range = 1..cap
      total = 42 * cap

      conn =
        Enum.reduce(range, conn, fn _x, acc ->
          post(conn, Routes.counter_path(acc, :create), @create_attrs)
        end)

      assert "" = response(conn, 202)

      # for cache commits
      :timer.sleep(sleep_time)
      counter = Increment.Repo.get_by(Counter, key: @create_attrs.key)

      assert %Increment.Tasks.Counter{
               key: "some key",
               value: ^total
             } = counter
    end

    @tag timeout: 600_000
    @tag :big_test
    test "update counter 1_000_000 times", %{conn: conn, sleep_time: sleep_time} do
      cap = 1_000_000
      range = 1..cap
      total = 42 * cap

      conn =
        Enum.reduce(range, conn, fn _x, acc ->
          post(conn, Routes.counter_path(acc, :create), @create_attrs)
        end)

      assert "" = response(conn, 202)

      # for cache commits
      :timer.sleep(sleep_time)
      counter = Increment.Repo.get_by(Counter, key: @create_attrs.key)

      assert %Increment.Tasks.Counter{
               key: "some key",
               value: ^total
             } = counter
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.counter_path(conn, :create), counter: @invalid_attrs)
      assert response(conn, 422) != %{}
    end

    test "renders errors when no data", %{conn: conn} do
      conn = post(conn, Routes.counter_path(conn, :create), counter: @missing_attrs)
      assert response(conn, 422) != %{}
    end
  end

  describe "update counter" do
    setup [:create_counter]

    test "raise error for invalid common path", %{conn: conn, counter: counter} do
      assert_raise ArgumentError, fn ->
        put(conn, Routes.counter_path(conn, :update, counter), counter: @invalid_attrs)
      end
    end
  end

  describe "delete counter" do
    setup [:create_counter]

    test "raise error for invalid common path", %{conn: conn, counter: counter} do
      assert_raise ArgumentError, fn ->
        delete(conn, Routes.counter_path(conn, :delete, counter))
      end
    end
  end

  defp create_counter(_) do
    counter = counter_fixture()
    %{counter: counter}
  end
end
