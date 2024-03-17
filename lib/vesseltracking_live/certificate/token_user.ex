defmodule VesseltrackingLive.Certificate.TokenUser do
  use Ecto.Schema
  import Ecto.Changeset

  schema "token_users" do
    field :comment, :string
    field :username, :string
    field :pubkey, :binary
    field :approved?, :boolean, default: false
    field :created_at, :utc_datetime
    field :expires_at, :utc_datetime
  end

  @doc false
  def changeset(token_user, attrs) do
    token_user
    |> cast(attrs, [:username, :pubkey, :approved?, :created_at, :expires_at, :comment])
    |> validate_required([:username, :pubkey, :approved?, :created_at, :expires_at, :comment])
  end

  def pem_encoded_public_key(private_key) do
    private_key
    |> public_key_from_private_key()
    |> pem_entry_encode(:RSAPublicKey)
  end

  def generate_private_key(size \\ 4096) do
    :public_key.generate_key({:rsa, size, 65537})
  end

  def public_key_from_private_key(private_key) do
    {:RSAPublicKey, elem(private_key, 2), elem(private_key, 2)}
  end

  def pem_entry_encode(key, type) do
    :public_key.pem_encode([:public_key.pem_entry_encode(type, key)])
  end
end
