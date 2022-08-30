defmodule Increment.Increment.Counter do
  use Ecto.Schema
  import Ecto.Changeset

  schema "counters" do
    field :key, :string
    field :value, :integer

    timestamps()
  end

  @required ~w(key value)a
  @optional ~w()a

  @doc false
  def changeset(counter, attrs) do
    counter
    # |> cast(attrs, [:key, :value])
    |> cast(attrs, @required ++ @optional)
    |> validate_required(@required)
    |> unique_constraint(
      :key, # can be any value contained in the constraint
      name: :index_for_input_keys
    )
  end
end
