String.class_eval do
  def gzip
    Zlib::GzipWriter.wrap(StringIO.new(gzipped = '')) { |gz| gz.write(self); gzipped }
  end
end
