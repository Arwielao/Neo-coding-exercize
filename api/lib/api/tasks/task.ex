defmodule Api.Tasks.Task do
  use Ecto.Schema
  import Ecto.Changeset

  schema "tasks" do
    field :description, :string
    field :due_date, :utc_datetime
    field :priority, :string
    field :status, :string
    field :title, :string

    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [:title, :description, :status, :priority, :due_date])
    |> validate_required([:title, :description, :status, :priority, :due_date])
  end
end
