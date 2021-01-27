defmodule Jaang.Release.Seeder do
  @moduledoc """
  Release tasks for seeds.
  """

  #  And then for the release:
  #
  # _build/prod/rel/jaang/bin/jaang eval 'Jaang.Release.Seeder.seed(Elixir.Jaang.Repo, "seeds.exs")'
  require Logger

  @app :jaang

  @doc """
  Seed seeds file for repo.
  """
  @spec seed(Ecto.Repo.t(), String.t()) :: :ok | {:error, any()}
  def seed(repo, filename) do
    load_app()

    case Ecto.Migrator.with_repo(repo, &eval_seed(&1, filename)) do
      {:ok, {:ok, _fun_return}, _apps} ->
        :ok

      {:ok, {:error, reason}, _apps} ->
        Logger.error(reason)
        {:error, reason}

      {:error, term} ->
        IO.warn(term, [])
        {:error, term}
    end
  end

  @spec eval_seed(Ecto.Repo.t(), String.t()) :: any()
  defp eval_seed(repo, filename) do
    seeds_file = get_path(repo, "seeds", filename)

    if File.regular?(seeds_file) do
      {:ok, Code.eval_file(seeds_file)}
    else
      {:error, "Seeds file not found."}
    end
  end

  @spec get_path(Ecto.Repo.t(), String.t(), String.t()) :: String.t()
  defp get_path(repo, directory, filename) do
    priv_dir = "#{:code.priv_dir(@app)}"

    repo_underscore =
      repo
      |> Module.split()
      |> List.last()
      |> Macro.underscore()

    Path.join([priv_dir, repo_underscore, directory, filename])
  end

  @spec load_app() :: :ok | {:error, term()}
  defp load_app(), do: Application.load(@app)
end
