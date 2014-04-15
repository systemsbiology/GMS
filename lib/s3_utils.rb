
def get_software_version(asm_location)
    workspace = "/tmp"
    summaryFile = "summary-#{self.name}.tsv"
    summaryPath = "#{asm_location}/#{summaryFile}"
    localPath = "#{workspace}/#{summaryFile}"
    logger.debug("getting SummaryFile #{summaryPath}")
    begin
        system("s3cmd get #{summaryPath} #{localPath} --force")
    rescue Exception => e
        logger.debug "exception #{e.inspect}"
        raise "Couldn't get file from s3 #{summaryPath}"
    end
    software_version = nil
    s = File.open(localPath, "r")
    s.each_line do |line|
        break if line.match("^$")
        if line.match("^#SOFTWARE_VERSION") then
            logger.debug "found software version #{line.inspect}"
            line.strip!
            (key, software_version) = line.split("\t")
            logger.debug "software version #{software_version}"
        end
    end
    s.close
    logger.debug "software version #{software_version}"

    logger.debug "removing localPath #{localPath}"
    begin
        system("rm #{localPath}")
    rescue Exception => e
        logger.debug "Couldn't delete local file exception #{e.inspect}"
    end
    return software_version
end
