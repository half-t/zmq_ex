defmodule ZmqEx do
  use GenServer

  @moduledoc """
  Documentation for ZmqEx.
  """

  @socket_opts [:binary, active: true]

  def version do
    {:ok, vsn} = :application.get_key(:zmq_ex, :vsn)
    List.to_string(vsn)
  end

  require Logger

  @doc """
  Start server or client on given port.
  Returns pid of socket process.

  """
  @spec start_link(type :: :server | :client, port :: integer) :: {:ok, pid}
  def start_link(type, port) do
    Logger.debug(fn -> "Starting #{type} on port:#{port}" end)
    {:ok, pid} = GenServer.start_link(__MODULE__, [type, port])

    {:ok, pid}
  end

  @impl true
  def init([type, port]) do
    case type do
      :server -> send(self(), :start_server)
      :client -> send(self(), :start_client)
      _ -> {:error, :wrong_type}
    end

    Logger.debug(fn -> "Created socket on port:#{port}" end)

    {:ok,
     %{
       connected: false,
       type: type,
       port: port
     }}
  end

  @impl true
  def handle_info(:start_server, state = %{port: port}) do
    Logger.debug(fn -> "Starting server on port:#{port}" end)

    with {:ok, listen_socket} <- :gen_tcp.listen(port, @socket_opts),
         {:ok, socket} <- :gen_tcp.accept(listen_socket) do
      Logger.debug(fn -> "Server started, starting connection..." end)
      start_connection_server(socket)
      send_loop(socket)
      {:noreply, Map.put(state, :socket, socket)}
    end
  end

  @impl true
  def handle_info(:start_client, state = %{port: port}) do
    Logger.debug(fn -> "Starting client on port:#{port}" end)
    {:ok, socket} = start_client(port)
    Logger.debug(fn -> "Client started, starting connection..." end)
    start_connection(socket)
    send_loop(socket)
    {:noreply, Map.put(state, :socket, socket)}
  end

  @impl true
  def handle_info(:setup_connection, state = %{port: port, socket: socket}) do
    Logger.debug(fn -> "Starting connection on port:#{port}" end)
    start_connection(socket)
    send_loop(socket)
    {:noreply, state}
  end

  @impl true
  def handle_info({:tcp, _socket, data}, state) do
    Logger.debug(fn -> "Raw message: #{inspect(data)}" end)
    dmsg = decode(data)
    Logger.debug(fn -> "Decoded message: #{inspect(dmsg)}" end)
    {:noreply, state}
  end

  defp start_client(port) do
    :gen_tcp.connect('localhost', port, @socket_opts)
  end

  defp send_loop(socket) do
    reply = IO.gets("Please enter something: ")
    enc_reply = encode(reply)
    :gen_tcp.send(socket, enc_reply)
    send_loop(socket)
  end

  defp start_connection_server(socket) do
    # to handle compatibility with old version, should be rewritten
    # msg will be used when we will handle the handshake
    :inet.setopts(socket, active: false)
    :gen_tcp.send(socket, partial_server_greeting())
    {:ok, _msg1} = :gen_tcp.recv(socket, 0)
    :gen_tcp.send(socket, server_version())
    {:ok, _msg2} = :gen_tcp.recv(socket, 0)
    :gen_tcp.send(socket, server_greeting_rest())
    {:ok, _msg3} = :gen_tcp.recv(socket, 0)

    ready(socket)
    check_ready(socket)
  end

  defp start_connection(socket) do
    # to handle compatibility with old version, should be rewritten
    :inet.setopts(socket, active: false)
    {:ok, msg1} = :gen_tcp.recv(socket, 0)
    :gen_tcp.send(socket, msg1)
    {:ok, msg2} = :gen_tcp.recv(socket, 0)
    :gen_tcp.send(socket, msg2)
    {:ok, msg3} = :gen_tcp.recv(socket, 0)
    :gen_tcp.send(socket, msg3)

    ready(socket)
    check_ready(socket)
    Logger.debug(fn -> "Send welcome messages" end)
    :inet.setopts(socket, active: true)
  end

  defp ready(socket),
    do:
      :gen_tcp.send(
        socket,
        <<4, 41, 5, "READY", 11, "Socket-Type", 0, 0, 0, 6, "DEALER", 8, "Identity", 0, 0, 0, 0>>
      )

  defp check_ready(socket) do
    {:ok, msg} = :gen_tcp.recv(socket, 0)

    case msg do
      <<4, 41, 5, "READY", 11, "Socket-Type", 0, 0, 0, 6, "DEALER", 8, "Identity", _data::binary>> ->
        true

      _ ->
        false
    end
  end

  defp encode(msg), do: <<0, byte_size(msg)::size(8), msg::binary>>

  defp decode(
         <<4, s::size(8), comm_size, comm::binary-size(comm_size), comm_size_2,
           comm_2::binary-size(comm_size_2), 0, 0, 0, comm_size_3,
           comm_3::binary-size(comm_size_3), comm_size_4, comm_4::binary-size(comm_size_4),
           body::binary>>
       ),
       do: {s, comm, comm_2, comm_3, comm_4, body}

  defp decode(<<0, msg_size, msg::binary-size(msg_size)>>), do: msg

  defp partial_server_greeting, do: <<255, 0, 0, 0, 0, 0, 0, 0, 1, 127>>
  defp server_version, do: <<3>>
  defp server_greeting_rest, do: <<0, 78, 85, 76, 76, 0::size(424)>>
end
