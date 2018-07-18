defmodule AccelWorldDownloader.Downloader do
    def async_download(last_chapter) do
      Enum.each(1..last_chapter, fn i ->
        spawn(AccelWorldDownloader.Downloader, :download_chapter, [i])
      end)
    end
  
    def download(last_chapter) do
      Enum.each(1..last_chapter, fn i ->
        download_chapter(i)
      end)
    end
  
    def download_chapter(chapter) do
      "https://manga-fox.com/accel-world/chapter-#{chapter}"
      |> get_html
      |> find_pages_urls
      |> download_pages(chapter)
  
      convert_pages(chapter, :pdf)
      IO.puts("Chapter #{chapter} done")
    end
  
    defp get_html(url) do
      %{body: body} = HTTPoison.get!(url)
      body
    end
  
    defp find_pages_urls(html) do
      html
      |> Floki.find(".content-area img")
      |> Enum.map(fn page ->
        {"img", img, _} = page
        [_, _, {"src", src}] = img
        src
      end)
    end
  
    defp download_pages(urls, chapter) do
      urls
      |> Enum.with_index()
      |> Enum.each(fn {url, index} ->
        %{body: img} = HTTPoison.get!(url)
        File.mkdir("/opt/accel-world/#{chapter}")
        File.write!("/opt/accel-world#{chapter}/manga_#{index}.jpg", img)
      end)
    end
  
    defp convert_pages(chapter, :pdf) do
      options = [
        "/opt/accel-world/#{chapter}/manga_*.jpg",
        "-quality",
        "100",
        "/opt/accel-world/final_manga_#{chapter}.pdf"
      ]
  
      System.cmd("convert", options)
      :ok
    end
  
    defp convert_pages(chapter, :kindle) do
      :ok
    end
  end
  