class SampleSweeper < ActionController::Caching::Sweeper
    observe Sample

    # expire people ped_info
    def after_save(sample)
        Rails.logger.debug("sample in after_save? #{sample.inspect}")
        expire_action(:controller => 'people', :action => :ped_info)
    end
end
