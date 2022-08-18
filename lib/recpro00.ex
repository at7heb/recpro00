defmodule Recpro00 do
  @archive "/Users/howard/Documents/rkiv-ins"
  @dict "dict.txt"
  @moduledoc """
  Documentation for `Recpro00`.
  """

  @doc """
  Hello world.

  ## Examples

      iex> Recpro00.example0()
      {:ok, "example0"}

      iex> Recpro00.example1()
      {:ok, "example1"}

  """

  def example0 do
    background = get_background()

    new_task("fry1_000.txt", "test", "test of Fry 1000", "test_fry_1000")
    |> execute_task(background)
    |> IO.inspect(label: "frequencies 1000")

    # new_task("fry300.txt", "test", "test of Fry 300", "test_fry_300")
    # |> execute_task(background)
    # |> IO.inspect(label: "frequencies 300")
    {:ok, "example0"}
  end

  def example1 do
    background = get_background()

    # new_task("mostFrequent5000.csv", "test1", "test of Frequent 5000", "test_frequent_5000")
    # |> execute_task(background)
    # |> IO.inspect(label: "frequencies 1000")

    # new_task("fry300.txt", "test", "test of Fry 300", "test_fry_300")
    # |> execute_task(background)
    # |> IO.inspect(label: "frequencies 300")
    {:ok, "example1"}
  end

  def execute_task(task, %{dict: dict} = _info) do
    # IO.inspect(Map.get(dict, "you", :not_present), label: "you...")
    corpus = get_corpus(task.corpus_file)
    missing_words = Enum.filter(corpus, fn word -> (not Map.has_key?(dict, word)) end)
    sounds = Enum.reduce(corpus, [], fn word, acc -> acc ++ Map.get(dict, word, ~w/zz yy xx/) end)
    frequencies = Enum.frequencies(sounds) |> Map.to_list()
    IO.inspect(missing_words, label: "missing words")
    Enum.sort(frequencies, fn {_k1, v1}, {_k2, v2} -> v1 >= v2 end)
  end

  def get_corpus(file_name) do
    Path.join(@archive, file_name)
    |> File.read!()
    |> String.split()
    |> Enum.map(fn a -> String.downcase(a) end)
  end

  # corpus file (e.g. Fry List)
  # short name
  # title (to supply to graphing)
  # file for output csv format
  # maybe file for graph
  def new_task(corpus_file, short_name, title, base_name) do
    %{corpus_file: corpus_file, name: short_name, title: title, base: base_name}
  end

  def get_background() do
    dict =
      Path.join(@archive, @dict)
      |> File.read!()
      |> String.split(~r/[\r\n]+/)
      |> Enum.filter(fn a -> Regex.match?(~r/^.+ /, a) end)
      |> Enum.map(fn a -> String.split(a) end)
      |> Enum.reduce(%{}, fn [h | t], acc -> Map.put(acc, h, unstressed_arpabet(t)) end)
    # IO.inspect(Map.get(dict, "can't", "xx yy zz"))
    %{dict: dict}
  end

  def unstressed_arpabet(l) when is_list(l) do
    Enum.reduce(l, [], fn a, acc -> [unstressed_arpabet(a) | acc] end)
  end

  def unstressed_arpabet(a) do
    cond do
      Regex.match?(~r/..[0-9]/, a) -> String.slice(a,0..1)
      true -> a
    end

  end
end
