defmodule Murnau.Timeout do
  require Logger
  use GenServer

  @vsn "0"
  @open_timeout Application.get_env(:murnau, :open_timeout)
  @close_countdown_minutes 1

  def start_link(caller) do
    GenServer.start_link(__MODULE__, %{caller: caller}, [debug: [:statistics, :trace]])
  end

  def register(pid, request), do: GenServer.call(pid, {:register, request})
  def rewind(pid, condition, timeout, delta \\ 5000), do: GenServer.cast(pid, {:rewind, condition, timeout, delta})
  def statistics(pid), do: GenServer.call(pid, :statistics)
  def stop(pid), do: GenServer.stop(pid)

  def handle_call(:statistics, _from, state), do: {:reply, do_get_stats(state), state}
  def handle_call({:register, request}, _from, state), do: {:reply, request, Map.put(state, :request, request)}

  def handle_cast({:rewind, condition, timeout, delta}, state) do
    state =
      state
      |> Map.put(:delta, delta)
      |> Map.put(:beats, 0)
      |> Map.put(:condition, condition)

    state =
    if condition.(state.caller) do
      Process.send_after(self(), :heartbeat, timeout)
      Map.put(state, :start, :os.system_time(:seconds))
    end
    {:noreply, state}
  end

  def handle_info(:heartbeat, state) do
    state =
      state
      |> Map.put(:duration, do_get_duration(state))
      |> Map.put(:beats, state.beats + 1)

    state =
    if state.condition.(state.caller) do
      Process.send_after(self(), :heartbeat, state.delta)
      state
    else
      GenServer.cast(state.caller, state.request)
      Map.put(state, :end, :os.system_time(:seconds))
    end
    {:noreply, state}
  end

  defp do_get_duration(state), do: :os.system_time(:seconds) - state.start
  defp do_get_stats(state), do: %{beats: state.beats, duration: state.duration, begin: state.start}
end
