defmodule Increment.Repo.Migrations.CreateCounters do
  use Ecto.Migration

  def change do
    create table(:counters) do
      add :key, :string
      add :value, :integer

      timestamps()
    end

    create(
      unique_index(
        :counters,
        [:key],
        name: :index_for_input_keys
      )
    )
  end
end
