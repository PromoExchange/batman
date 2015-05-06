namespace :supplier do
  desc 'Fake supplier creation'
  task :fake, [:repeat] => [:environment] do |t,args|
    args.with_defaults(:repeat => 10)

    args.repeat.to_i.times do
      Supplier.create( { name: Faker::Company.name ,
        description: Faker::Lorem.sentence(4)})
    end
  end
end
