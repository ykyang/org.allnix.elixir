defmodule Todo.CacheTest do
  use ExUnit.Case

  test "server_process" do
    tche = Todo.Cache

    {:ok, pid_cache} = tche.start()
    assert File.exists?("persist/")

    pid_amy = tche.server_process(pid_cache, "amy")
    pid_bob = tche.server_process(pid_cache, "bob")

    assert pid_bob != pid_amy
    assert pid_amy == tche.server_process(pid_cache, "amy")
    assert pid_bob == tche.server_process(pid_cache, "bob")
  end

  test "todo operations" do
    File.rm("./persist/bobs_list")
    File.rm("./persist/amys_list")

    tche = Todo.Cache
    tsrv = Todo.Server

    {:ok, pid_cache} = tche.start()
    assert File.exists?("persist/")

    # Bob
    pid_server = tche.server_process(pid_cache, "bobs_list")
    tsrv.add_entry(pid_server, %{date: ~D[2023-12-19], title: "Dentist"})
    entries = tsrv.entries(pid_server, ~D[2023-12-19])
    ## Use pattern match
    assert [%{date: ~D[2023-12-19], title: "Dentist"}] = entries

    # Amy
    pid_server = tche.server_process(pid_cache, "amys_list")
    tsrv.add_entry(pid_server, %{date: ~D[2023-12-19], title: "Dentist"})
    entries = tsrv.entries(pid_server, ~D[2023-12-19])
    ## Use pattern match
    assert [%{date: ~D[2023-12-19], title: "Dentist"}] = entries
  end

  test "Lots of TODO list" do
    # TODO
  end
end
