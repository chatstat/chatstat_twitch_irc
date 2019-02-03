defmodule TwitchIrc.UUID do
  def uuid() do
    UUID.uuid4(:default)
  end

  def empty_id_map() do
    %{id: uuid()}
  end

  def add_id(map) when is_map(map) do
    case Map.has_key?(map, :id) do
      true -> map
      false -> Map.put(map, :id, uuid())
    end
  end
end
