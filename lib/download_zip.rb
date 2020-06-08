require 'zip'

def download_zip(file_name, file_hash)
  if !file_hash.blank? and !file_name.nil?
    t = Tempfile.new("pedigrees-#{Time.now.to_s.gsub(/ /,"_")}-#{rand(9999).to_s}")
    Zip::OutputStream.open(t.path) do |z|
      file_hash.each do |file, file_loc|
        z.put_next_entry(file)
	    z.write IO.read(file_loc)
      end
    end
    send_file t.path, :type => 'application/zip',
                      :disposition => 'attachment',
		      :filename => file_name
    t.close
  end
end
