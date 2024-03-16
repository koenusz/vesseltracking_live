defmodule VesseltrackingLive.TestHelpers do
  def remove_not_loaded_associations(struct_with_assoc, struct_without_assoc) do
    keys_to_remove =
      struct_without_assoc
      |> Map.from_struct()
      |> Enum.filter(fn {_k, v} -> match?(%Ecto.Association.NotLoaded{}, v) end)
      |> Keyword.keys()

    map1 =
      struct_with_assoc
      |> Map.from_struct()
      |> Map.drop(keys_to_remove)

    map2 =
      struct_without_assoc
      |> Map.from_struct()
      |> Map.drop(keys_to_remove)

    {map1, map2}
  end
end
