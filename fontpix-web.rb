# -*- coding: utf-8 -*-
require "sinatra"
require "haml"
require "tanka"

FONTS = {
  "KouzanBrushFontOTF" => " 衡山毛筆フォント",
  "KouzanBrushFontGyousyo" => " 衡山毛筆フォント行書",
  "KouzanBrushFontSousyo" => " 衡山毛筆フォント草書",
  "AoyagiKouzanFontT" => " 青柳衡山フォントT",
  "AoyagiSosekiFont2" => " 青柳疎石フォント2",
}

get "/" do
  @fonts = FONTS
  @params ||= {}
  haml :index
end

post "/" do
  @fonts = FONTS
  begin
    @download_url = write_to_png
  rescue => e
    return "Error: #{e}"
  end

  @params = params
  haml :index
end

helpers do
  def text
    @text ||= params[:text]
  end

  def filename
    return @filename if @filename
    @filename = params[:filename]
    @filename = Time.now.strftime("%Y%m%d%H%M%S") if @filename.empty?
    @filename << ".png" unless /.png\z/ =~ @filename
    @filename
  end

  def font
    @font ||= params[:font]
  end

  def write_to_png
    today = Time.now.strftime("%Y%m%d")
    base_dir = "public/images/#{today}"
    FileUtils.mkdir_p(base_dir)
    output_path = File.join(base_dir, filename)

    painter = Tanka::Painter.new
    painter.guess_font(font || "Gyousyo")
    painter.write_to_png(text, output_path)

    "#{base_url}/#{base_dir.gsub(/\Apublic\//, "")}/#{filename}"
  end

  def base_url
    parts_of_url = {
      :scheme => request.scheme,
      :host   => request.host,
      :port   => request.port,
      :path   => request.script_name,
    }
    URI::Generic.build(parts_of_url).to_s.gsub(/(#{request.scheme}:\/\/#{request.host}):80/, '\1')
  end
end