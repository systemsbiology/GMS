require 'open3'
require 'time'

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

def creation_time(file)
   Time.parse(Open3.popen3("stat", 
                           "-c",
                           "%z", 
                           file)[1].read)
end

# open up a file and parse the # comments into a hash.  Use bzcat if bzip'd or gunzip -c for gzip'd
def file_header(file, file_type)
    cmd = Array.new
    if file.match(/\.bz2\z/) then
        cmd = [ 'bzcat', file ]
    elsif file.match(/\.gz\z/) then
        cmd = [ 'gunzip', '-c', file ]
    else
        cmd = [ 'cat', file ]
    end

    header = Hash.new
    Open3.popen3(*cmd) do |stdin, stdout, stderr|
        stdout.each do |line|
            if file_type == "CGI" then 
                if line.match('^#') then
                    line.gsub!(/#/, '')
                    line.strip! # remove newline at the end
                    if line.match(/\t/) then # parsing TSV file
                        (key,value) = line.split(/\t/)
                        if line.match(/^CHROM/) then
                            values = line.split(/\t/)
                            key = 'ASSEMBLY_ID'
                            value = values.last
                        end
                    elsif line.match(/=/) then  # parsing VCF file
                        (key,value) = line.split(/=/)
                         if (key == VCF_SOURCE) then
                            (software, version) = value.split(/_/)
                            header[CGI_SOFTWARE_VERSION] = version
                            header[CGI_SOFTWARE_PROGRAM] = software
                         end
                         if (key == CGI_VCF_GENOME_REFERENCE) then
                            header[CGI_GENOME_REFERENCE] = value
                         end
                    end
                    header[key] = value
                else
                    break
                end
            elsif file_type == "VCF" then
                if line.match(/^##/) then
                    line.gsub!(/#/, '')
                    line.strip! # remove newline at the end
                    if line.match(/=</) then
                        (key,value) = line.split(/=</)
                    else 
                        (key, value) = line.split(/=/)
                    end
                    value.gsub!(/>$/,'') unless value.nil?
                    if header[key].nil? then
                        header[key] = value 
                    else
                        if header[key].is_a? Array then
                            header[key].push(value)
                        else
                            old = header[key]
                            header[key] = Array.new
                            header[key].push(old)
                            header[key].push(value)
                        end
                    end
                else
                    break
                end
            end
        end # end stdout.each
    end # end open

  return header
end
