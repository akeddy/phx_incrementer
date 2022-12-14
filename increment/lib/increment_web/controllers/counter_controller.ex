require Logger

defmodule IncrementWeb.CounterController do
  use IncrementWeb, :controller

  alias Increment.Tasks
  action_fallback IncrementWeb.FallbackController

  def create(conn, %{"key" => key, "value" => value} = counter_params)
      when is_bitstring(key) and is_number(value) do
    Logger.debug("Key: #{key}")
    Logger.debug("Value: #{value}")

    case Tasks.cache_counter(counter_params) do
      {:ok, _int} ->
        conn
        |> put_status(:accepted)
        |> send_resp(202, "")
      {:error, error} ->
        Logger.error("Failed to increment counter. Error: #{inspect(error)}")
        conn
        |> put_status(:bad_request)
        |> send_resp(422, "")
    end
  end

  # reject a request if it does not have the correct format
  def create(conn, %{}) do
    conn
    |> put_status(:bad_request)
    |> send_resp(422, "")
  end
end
