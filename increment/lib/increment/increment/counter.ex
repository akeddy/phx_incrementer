defmodule Increment.Increment.Counter do
  use Ecto.Schema
  import Ecto.Changeset

  schema "counters" do
    field :key, :string
    field :value, :integer

    timestamps()
  end

  @doc false
  def changeset(counter, attrs) do
    counter
    |> cast(attrs, [:key, :value])
    |> validate_required([:key, :value])
  end
end
