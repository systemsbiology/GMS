class SampleSweeper < ActionController::Caching::Sweeper
    observe Sample

    # expire people ped_info
    def after_save
        expire_action(:controller => 'people', :action => :ped_info)
    end
end
