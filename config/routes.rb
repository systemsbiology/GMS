Gms::Application.routes.draw do
  root :to => 'welcome#index'
  resources :file_types
  resources :diagnoses
  resources :reports
  match "terminology" => "terminology#index"
  match '/calendar(/:year(/:month))' => 'calendar#index', :as => :calendar, :constraints => {:year => /\d{4}/, :month => /\d{1,2}/}
  resources :genome_references
  match "assemblies/ensure_files_up_to_date/(:id)", :to => "assemblies#ensure_files_up_to_date", :as => "ensure_files_up_to_date"
  resources :assemblies
  resources :assembly_files
  match "assays/summary_report/(:id)", :to =>  "assays#summary_report", :as => "summary_report"
  resources :assays
  resources :sample_assays
  resources :samples
  resources :sample_types
  resources :acquisitions
  match "people/receiving_report/(:id)", :to => "people#receiving_report", :as => "receiving_report"
  match "people/upload", :to => "people#upload", :as => "upload"
  match "people/upload_and_validate", :to => "people#upload_and_validate", :as => "upload_and_validate"
  match "people/confirm", :to => "people#confirm", :as => "confirm"
  resources :people
  resources :person_aliases
  resources :traits
  resources :phenotypes
  resources :diseases
  resources :relationships
  resources :aliases
  resources :memberships
  match "pedigrees/pedigree_file/(:id)", :to => "pedigrees#pedigree_file", :as => "pedigree_file"
  match "pedigrees/all_pedigree_files", :to => "pedigrees#all_pedigree_files", :as => "all_pedigree_files"
  match "pedigrees/pedigree_datastore", :to => "pedigrees#pedigree_datastore", :as => "pedigree_datastore"
  match "pedigrees/export_madeline_table/(:id)", :to => "pedigrees#export_madeline_table", :as => "export_madeline_table"
  match "pedigrees/founders/(:id)", :to => "pedigrees#founders", :as => "founders"
  resources :pedigrees
  resources :studies
  match "/fgg_manifest", :to => "static#fgg_manifest"

  def self.inherited(child)
    child.instance_eval do
      def model_name
        Report.model_name
      end
    end
    super
  end

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
