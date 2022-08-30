require Logger
defmodule IncrementWeb.CounterController do
  use IncrementWeb, :controller

  alias Increment.Tasks
  alias Increment.Tasks.Counter

  action_fallback IncrementWeb.FallbackController

  # def index(conn, _params) do
  #   counters = Tasks.list_counters()
  #   render(conn, "index.json", counters: counters)
  # end

  # def create(conn, %{"counter" => counter_params}) do
  def create(conn, %{"key" => key, "value" => value} = counter_params) do
    Logger.debug("Key: #{key}")
    Logger.debug("Value: #{value}")
    with {:ok, %Counter{} = _counter} <- Tasks.create_counter(counter_params) do
      conn
      |> put_status(:created)
      # |> put_resp_header("location", Routes.counter_path(conn, :show, counter))
      # |> render("show.json", counter: counter)
      |> send_resp(200, "")
    end
  end

  # def show(conn, %{"id" => id}) do
  #   counter = Tasks.get_counter!(id)
  #   render(conn, "show.json", counter: counter)
  # end

  # def update(conn, %{"id" => id, "counter" => counter_params}) do
  #   counter = Tasks.get_counter!(id)

  #   with {:ok, %Counter{} = counter} <- Tasks.update_counter(counter, counter_params) do
  #     render(conn, "show.json", counter: counter)
  #   end
  # end

  # def delete(conn, %{"id" => id}) do
  #   counter = Tasks.get_counter!(id)

  #   with {:ok, %Counter{}} <- Tasks.delete_counter(counter) do
  #     send_resp(conn, :no_content, "")
  #   end
  # end
end
