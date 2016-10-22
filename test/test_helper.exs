ExUnit.start()
Application.ensure_all_started(:bypass)

defmodule Test.Server do
  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, [debug: [:statistics, :trace]])
  end

  def init(state) do
    {:ok, Map.put(state, :beats, 5)}
  end

  def set_beats(pid, beats) do
    GenServer.cast(pid, {:beats, beats})
  end
  def get_beats(pid) do
    GenServer.call(pid, :beats)
  end

  def is_open(pid) do
    GenServer.call(pid, :is_open)
  end

  def stop(pid), do: GenServer.stop(pid)

  def handle_cast({:beats, beats}, state) do
    {:noreply, Map.put(state, :beats, beats)}
  end
  def handle_call(:beats, _from, state) do
    {:reply, Map.fetch(state, :beats), state}
  end

  def handle_call(:is_open, _from, state) do
    beats = state.beats
    {:reply, beats - 1 >= 0, Map.put(state, :beats, beats - 1)}
  end

  def handle_cast(:close, state) do
    {:noreply, state}
  end
end
