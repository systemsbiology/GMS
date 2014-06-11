class PersonSweeper < ActionController::Caching::Sweeper
    observe Person

    # expire people ped_info
    def after_save(person)
        expire_action(:controller => 'people', :action => :ped_info, :format => 'json')
    end
end
