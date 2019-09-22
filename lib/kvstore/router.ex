defmodule KVStore.Router do
  use Plug.Router
  use Plug.ErrorHandler
  
  require KVStore.Storage

  plug(:match)
  plug Plug.Parsers, parsers: [:urlencoded]
  plug(:dispatch)	
  plug Plug.Static, at: "/create", from: :server
  #plug Plug.Static, at: "/read", from: :server

  get("/", do: send_resp(conn, 200, "Welcome\n"))

  get "/create" do
  	conn = put_resp_content_type(conn, "text/html")
  	send_file(conn, 200, "lib/web/create.html")
  end
  post "/create"  do 
	:ok = KVStore.Storage.create conn  	
	send_resp(conn, 201, "Created")
  end

  get "/read" do
  	conn = put_resp_content_type(conn, "text/html")
  	send_file(conn, 200, "lib/web/read.html")
  end
  post "/read" do
  	val = KVStore.Storage.read conn
  	send_resp(conn, 200, "#{val}")
  end

  get "/update" do
  	conn = put_resp_content_type(conn, "text/html")
  	send_file(conn, 200, "lib/web/update.html")
  end
  post "/update" do
  	KVStore.Storage.update conn  	
	  send_resp(conn, 201, "Updated")
  end

  get "/delete" do
  	conn = put_resp_content_type(conn, "text/html")
  	send_file(conn, 200, "lib/web/delete.html")
  end
  post "/delete" do
  	KVStore.Storage.delete conn
  	send_resp(conn, 200, "Deleted")
  end

  match(_, do: send_resp(conn, 404, "Oops!\n"))

end