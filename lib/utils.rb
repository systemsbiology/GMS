
def array_to_html_table(header, data)
    xm = Builder::XmlMarkup.new(:indent => 2)
    xm.table {
      xm.tr { header.each {|key| xm.th(key) } }
      data.each {|row| xm.tr { row.each { |value| xm.td(value)} } }
    }
    xm.target
end

def csvdir_exists
  if !File.exists?(CSVDIR) then
    Dir.mkdir(CSVDIR)
  end
end
