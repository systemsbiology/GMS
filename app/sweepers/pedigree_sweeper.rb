class PedigreeSweeper < ActionController::Caching::Sweeper
    observe Pedigree

    # expire people ped_info
    def after_save(pedigree)
        expire_action(:controller => 'people', :action => :ped_info, :format => 'json')
        expire_action(:controller => 'pedigree', :action => :all_pedigrees, :format => 'json')
    end
end
