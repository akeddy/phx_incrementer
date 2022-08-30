defmodule IncrementWeb.CounterControllerTest do
  use IncrementWeb.ConnCase

  import Increment.TasksFixtures

  alias Increment.Tasks.Counter

  @create_attrs %{
    key: "some key",
    value: 42
  }
  @update_attrs %{
    key: "some updated key",
    value: 43
  }
  @invalid_attrs %{key: nil, value: nil}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all counters", %{conn: conn} do
      conn = get(conn, Routes.counter_path(conn, :index))
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create counter" do
    test "renders counter when data is valid", %{conn: conn} do
      conn = post(conn, Routes.counter_path(conn, :create), counter: @create_attrs)
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.counter_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "key" => "some key",
               "value" => 42
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.counter_path(conn, :create), counter: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update counter" do
    setup [:create_counter]

    test "renders counter when data is valid", %{conn: conn, counter: %Counter{id: id} = counter} do
      conn = put(conn, Routes.counter_path(conn, :update, counter), counter: @update_attrs)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.counter_path(conn, :show, id))

      assert %{
               "id" => ^id,
               "key" => "some updated key",
               "value" => 43
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, counter: counter} do
      conn = put(conn, Routes.counter_path(conn, :update, counter), counter: @invalid_attrs)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete counter" do
    setup [:create_counter]

    test "deletes chosen counter", %{conn: conn, counter: counter} do
      conn = delete(conn, Routes.counter_path(conn, :delete, counter))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.counter_path(conn, :show, counter))
      end
    end
  end

  defp create_counter(_) do
    counter = counter_fixture()
    %{counter: counter}
  end
end
