namespace :product do

  task :fake, [:repeat] => [:environment] do |t,args|
    args.with_defaults(:repeat => 1000)
    args.repeat.to_i.times do
      s = Supplier.limit(1).order("RANDOM()")
      # //puts s.inspect

      if s.nil?  # No suppliers, create 10 fakes
        10.times do
          Supplier.create( { name: Faker::Company.name ,
            description: Faker::Lorem.sentence(4)})
        end
      end

      # Create base product
      p = Product.create({name: Faker::Commerce.product_name,
                        description: Faker::Lorem.sentence(4),
                        includes: Faker::Lorem.sentence(1),
                        features: Faker::Lorem.sentence(2),
                        packsize: rand(1000),
                        packweight: rand(100),
                        unit_measure: rand(100),
                        leadtime: rand(10),
                        rushtime: rand(10),
                        info: Faker::Lorem.sentence(8),
                        supplier_id: s[0].id
                        })

    end
  end
end
