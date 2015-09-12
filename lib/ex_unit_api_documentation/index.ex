defmodule ExUnitApiDocumentation.Index do
  def path(docs_root) do
    Path.join([docs_root, "docs", "index.json"])
  end

  def update(path_to_add, docs_root) do
    index = read(docs_root)
    add_element(index, path_to_add)
    |> write(docs_root)
  end

  def read(docs_root) do
    index_path = path(docs_root)
    if File.exists?(index_path) do
      File.read!(index_path) |> Poison.decode!
    else
      []
    end
  end

  def write(index, docs_root) do
    File.write!(path(docs_root), to_json(index), [:write])
  end

  def to_json(index) do
    Poison.encode!(index)
  end

  defp add_element(index, path_to_add) do
    as_set = :sets.from_list(index)
    :sets.add_element(path_to_add, as_set)
    |> :sets.to_list
  end
end
