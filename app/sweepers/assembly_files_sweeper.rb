class AssemblyFilesSweeper < ActionController::Caching::Sweeper
    observe AssemblyFile

    # expire assembly_files ped_info
    def after_save
        expire_action(:controller => 'assembly_files', :action => :ped_info)
    end
end
