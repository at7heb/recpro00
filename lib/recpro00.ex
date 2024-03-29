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

      iex> Recpro00.example2()
      {:ok, "example2"}

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

    new_task("mostFrequent5000.csv", "test1", "test of Frequent 5000", "test_frequent_5000")
    |> execute_task(background)
    |> IO.inspect(label: "frequent 5000")

    {:ok, "example1"}
  end

  def example2 do
    background = get_background()

    new_task("boxcar1.csv", "test2", "test of boxcar1", "test_boxcar1")
    |> execute_task(background)
    |> IO.inspect(label: "boxcar1")
    {:ok, "example2"}
  end

  def execute_task(task, %{dict: dict, phonemes: phonemes} = _info) do
    # IO.inspect(Map.get(dict, "you", :not_present), label: "you...")
    corpus = get_corpus(task.corpus_file)
    missing_words = Enum.filter(corpus, fn word -> not Map.has_key?(dict, elem(word, 0)) end)

    frequencies =
      Enum.map(phonemes, fn a -> {a, 0} end)
      |> Enum.into(%{})

    Enum.take(corpus, 5)
    # |> IO.inspect(label: "corpus")
    # IO.inspect(frequencies, label: "frequencies initial")

    sounds =
      Enum.reduce(corpus, frequencies, fn word, freqs ->
        update_frequencies(word, freqs, dict)
      end)

    # Enum.take(sounds, 5) |> IO.inspect(label: "sounds")
    # frequencies = Enum.frequencies(sounds) |> Map.to_list()
    frequencies = sounds
    IO.inspect(missing_words, label: "missing words")
    rv = Enum.sort(frequencies, fn {_k1, v1}, {_k2, v2} -> v1 >= v2 end)
    # Enum.take(rv, 5) |> IO.inspect(label: "sorted frequencies")
    rv
  end

  def update_frequencies({spelling, count} = _word, frequency_map, dict) do
    # IO.inspect({spelling, count}, label: "word in update_frequencies")
    # IO.inspect(frequency_map, label: "map in update_frequencies")

    phonemes = Map.get(dict, spelling, ~w/zz yy xx/)
    # |> IO.inspect(label: "phonemes in update_frequencies")

    new_frequency_map =
      Enum.reduce(phonemes, frequency_map, fn phoneme, fm ->
        Map.update(fm, phoneme, count, fn value -> value + count end)
      end)

    # IO.inspect("have new frequency map")
    new_frequency_map
  end

  def get_corpus(file_name) do
    file_path = Path.join(@archive, file_name)

    if file_name |> String.downcase(:ascii) |> String.ends_with?(".csv") do
      get_corpus_with_counts(file_path)
    else
      get_corpus_without_counts(file_path)
    end
  end

  def get_corpus_without_counts(file_path) do
    file_path
    |> File.read!()
    |> String.split()
    |> Enum.map(fn a -> {String.downcase(a), 1} end)
  end

  def get_corpus_with_counts(file_path) do
    file_path
    |> File.read!()
    |> String.split()
    |> CSV.decode!(headers: true)
    |> Enum.map(fn a ->
      {String.downcase(Map.get(a, "Word")), Map.get(a, "Frequency") |> String.to_integer()}
    end)
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
    dict_list =
      Path.join(@archive, @dict)
      |> File.read!()
      |> String.split(~r/[\r\n]+/)
      |> Enum.filter(fn a -> Regex.match?(~r/^.+ /, a) end)
      |> Enum.map(fn a -> String.split(a) end)

    # dict_list |> Enum.take(5) |> IO.inspect(label: "dictionary list")
    dict =
      dict_list
      |> Enum.reduce(%{}, fn [h | t], acc -> Map.put(acc, h, unstressed_arpabet(t)) end)

    # IO.inspect(Map.get(dict, "can't", "xx yy zz"))
    phonemes =
      dict_list
      |> Enum.reduce([], fn dict_entry, acc ->
        (dict_entry |> tl |> hd |> String.split()) ++ acc
      end)
      |> unstressed_arpabet()
      |> Enum.uniq()

    # |> IO.inspect(label: "phonemes")

    %{dict: dict, phonemes: phonemes}
  end

  def unstressed_arpabet(l) when is_list(l) do
    Enum.reduce(l, [], fn a, acc -> [unstressed_arpabet(a) | acc] end)
  end

  def unstressed_arpabet(a) do
    cond do
      Regex.match?(~r/..[0-9]/, a) -> String.slice(a, 0..1)
      true -> a
    end
  end
end
