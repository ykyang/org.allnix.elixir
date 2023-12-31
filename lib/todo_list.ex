## 4.1.1 Basic abstraction
defmodule TodoList do
  #import MultiDict

  ## 4.1.3
  #def new(), do: %{}
  # def add_entry(todo_list, date, title) do
  #   MultiDict.add(todo_list, date, title)
  # end
  # def entries(todo_list, date) do
  #   Map.get(todo_list, date, [])
  # end

  ## 4.1.4
  # def new(), do: MultiDict.new()
  # def add_entry(todo_list, entry) do
  #   MultiDict.add(todo_list, entry.date, entry)
  # end
  # def entries(todo_list, date) do
  #   MultiDict.get(todo_list, date)
  # end

  ## 4.2.1
  defstruct next_id: 1, entries: %{}

  #def new(), do: %TodoList{}
  def new(entries \\ []) do
    Enum.reduce(
      entries, %TodoList{},
      fn entry, todo_list ->
        add_entry(todo_list, entry)
      end
    )
  end

  @spec add_entry(TodoList, map()) :: TodoList
  def add_entry(todo_list, entry) do
    # add id to entry
    entry = Map.put(entry, :id, todo_list.next_id)
    new_entries = Map.put(
      todo_list.entries, todo_list.next_id, entry
    )

    %TodoList{todo_list |
      entries: new_entries,
      next_id: todo_list.next_id + 1
    }
  end

  def entries(todo_list, date) do
    todo_list.entries |> Map.values()
    |> Enum.filter(fn entry -> entry.date == date end)
  end

  def update_entry(todo_list, entry_id, update_fn) do
    case Map.fetch(todo_list.entries, entry_id) do
      :error -> todo_list
      {:ok, old_entry} ->
        new_entry = update_fn.(old_entry)
        new_entries = Map.put(todo_list.entries, new_entry.id, new_entry)
        %TodoList{todo_list | entries: new_entries}
    end
  end

  def delete_entry(todo_list, entry_id) do
    Map.delete(todo_list, entry_id)
  end
end

defmodule TodoList.CsvImporter do
  import File
  def import(file) do
    entries = File.stream!(file)
    |> Stream.map(fn line -> String.trim_trailing(line, "\n") end)
    #|> Enum.each(fn line -> IO.puts("#{line}") end)
    |> Stream.map(fn line -> String.split(line, ",") end)
    #|> Enum.each(fn [a,b] -> IO.puts("#{a} #{b}") end)
    |> Stream.map(fn [a,b] -> [Date.from_iso8601!(a), b] end)
    #|> Enum.each(fn [a,b] -> IO.puts("#{a} #{b}") end)
    |> Stream.map(fn [date,title] -> %{date: date, title: title} end)
    #|> Enum.each(fn x -> IO.inspect(x) end)

    todo_list = TodoList.new(entries)
  end

end
