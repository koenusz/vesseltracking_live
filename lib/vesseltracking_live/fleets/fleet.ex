defmodule Vesseltracking.Fleets.Fleet do
  use Ecto.Schema
  import Ecto.Changeset
  alias Vesseltracking.{Fleets.Authorization, Accounts.User, Fleets.Fleet, Fleets.Vessel}

  schema "fleets" do
    field(:name, :string)
    field(:company_id, :id)
    has_many(:vessels, Vessel)
    many_to_many(:authorized_users, User, join_through: Authorization)
    timestamps()
  end

  @doc false
  def changeset(%Fleet{} = fleet, attrs) do
    fleet
    |> cast(attrs, [:name, :company_id])
    |> cast_assoc(:vessels, required: false)
    |> cast_assoc(:authorized_users, required: false)
    |> validate_required([:name, :company_id])
  end
end
