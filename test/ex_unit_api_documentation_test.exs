defmodule ExUnitApiDocumentationTest do
  use ExUnit.Case

  @index_json "./priv/static/docs/index.json"
  @doc_json "./priv/static/docs/test_docs.json"
  @expect_doc %{"http_method" => "GET",
                "requests" => [%{"request_body" => "request body",
                                 "request_headers" => %{"header1" => "foo"},
                                 "request_method" => "GET",
                                 "request_path" => "http://localhost:4000/api/",
                                 "response_body" => "OK",
                                 "response_headers" => %{"header2" => "bar"},
                                 "status_code" => 200}],
                "route" => "http://localhost:4000/api/"}

  def read_index do
    if File.exists?(@index_json) do
      File.read!(@index_json) |> Poison.decode!
    else
      []
    end
  end

  def read_docs do
    File.read!(@doc_json) |> Poison.decode!
  end

  def run_test do
    ExUnitApiDocumentation.start_doc("test_docs")
    response = %HTTPoison.Response{
                             body: "OK",
                             headers: [{"header2", "bar"}],
                             status_code: 200
                         }
    ExUnitApiDocumentation.document("GET", "http://localhost:4000/api/",
                                    [{"header1", "foo"}],
                                    "request body",
                                    response)
    ExUnitApiDocumentation.write_json()
  end

  setup_all do
    :ok
  end

  setup do
    ExUnitApiDocumentation.start
    File.rm_rf!("./priv/static/docs")
    on_exit fn ->
      ExUnitApiDocumentation.stop
    end
    :ok
  end

  test "updates the index" do
    index_before = read_index()
    run_test()
    index_after = read_index()
    diff = index_after -- index_before
    assert ["/docs/test_docs.json"] == diff
  end

  test "writes metadata" do
    run_test()
    docs = read_docs()
    assert "test_docs" == docs["name"]
  end

  test "adds the documentation" do
    run_test()
    docs = read_docs()
    [doc] = docs["docs"]
    assert @expect_doc == doc
  end
end
