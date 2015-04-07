class AssemblyFilesSweeper < ActionController::Caching::Sweeper
    observe AssemblyFile

    # expire assembly_file ped_info
    def after_save(assembly_file)
        expire_action(:controller => '/assembly_files', :action => 'ped_info', :format => 'json')
        expire_action(:controller => '/people', :action => 'ped_info', :format => 'json')
    end
end
