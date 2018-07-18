defmodule AccelWorldDownloader do
  alias AccelWorldDownloader.Downloader

  defdelegate download(), to: Downloader
end
