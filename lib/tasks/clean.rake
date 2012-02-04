namespace :clean do

  desc "Clean temporary objects that are older than one hour"
  task :temp_objects => :environment do
    objs_to_delete = TempObject.where('added < ? ', 1.hour.ago)
    objs_to_delete.each do |object|
      object.destroy
    end
  end

end
