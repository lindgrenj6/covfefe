defmodule Covfefe do
  @covfefe_file "/home/jlindgren/.covfefe"

  def main([]), do: covfefe()
  def main(["on"]), do: run_covfefe(:ON)
  def main(["off"]), do: run_covfefe(:OFF)

  defp covfefe do
    {{_, _, day}, _} = File.lstat!(@covfefe_file, time: :local).mtime

    if day != DateTime.utc_now().day do
      run_covfefe(:ON)
      :timer.sleep(2 * 1000)
      File.touch(@covfefe_file)
      System.cmd("espeak-ng", ["covfehfee brewing"])
      :timer.sleep(12 * 60 * 1000)
      System.cmd("espeak-ng", ["covfehfee ready"])
    end
  end

  defp run_covfefe(cmd) when is_atom(cmd) do
    case System.cmd("docker", ~w(run --rm #{image()} -h #{host()} --action #{cmd})) do
      {_output, 0} -> IO.puts("Covfefe is #{cmd}")
      {_output, code} -> IO.puts("Something happened, rc: #{code}")
    end
  end

  defp image, do: Application.get_env(:covfefe, :image)
  defp host, do: Application.get_env(:covfefe, :wemo_ip)
end
