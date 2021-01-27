defmodule Jaang.Seeder do
  def run_seeds do
    seed_script = Path.join(["#{:code.priv_dir(:jaang)}", "repo", "seeds.exs"])
    Code.eval_file(seed_script)
  end

  def run_sale_seeds do
    seed_script = Path.join(["#{:code.priv_dir(:jaang)}", "repo", "seeds2.exs"])
    Code.eval_file(seed_script)
  end
end
