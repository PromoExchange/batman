namespace :px do
  task help: :environment do |t|
    text = <<END
PX Rake commands
px:help                 This output
px:info                 Current DB stats
px:fake:product[<num>]  Create num fake products, default=1000
px:fake:supplier[<num>] Create num fake suppliers, default=10
px:fake:material[<num>] Create num fake materials, default=10
px:fake:size[<num>]     Create num fake sizes, default=10
px:fake:brand[<num>]    Create num fake brands, default=100
px:fake:line[<num>]     Create num fake lines.
                        Associate with current brands
                        If no brands exists, create 10 fake ones
The paramater and the square brackets are optional.
END
    puts text
  end

  task info: :environment do |t|
    text = <<END
PX Rake commands
Products  #{Product.count}
Suppliers #{Supplier.count}
Materials #{Material.count}
Sizes     #{Size.count}
Brands    #{Brand.count}
Lines     #{Line.count}
Colors    #{Color.count}
END
    puts text
  end

  namespace :fake do
    desc 'Fake supplier creation'
    task :supplier, [:repeat] => [:environment] do |t,args|
      args.with_defaults(:repeat => 10)

      args.repeat.to_i.times do
        Supplier.create( { name: Faker::Company.name ,
          description: Faker::Lorem.sentence(4)})
      end
    end

    desc 'Fake size creation'
    task :size, [:repeat] => [:environment] do |t,args|
      args.with_defaults(:repeat => 10)

      args.repeat.to_i.times do
        Size.create( { name: Faker::Lorem.word ,
                        width: Faker::Number.number(2),
                        height: Faker::Number.number(2),
                        depth: Faker::Number.number(2),
                        dia: Faker::Number.number(2)})
      end
    end

    desc 'Fake material creation'
    task :material, [:repeat] => [:environment] do |t,args|
      args.with_defaults(:repeat => 10)

      args.repeat.to_i.times do
        Material.create( { name: Faker::Commerce.color })
      end
    end

    desc '***DRY*** Fake Brand creation'
    task :brand, [:repeat] => [:environment] do |t,args|
      args.with_defaults(:repeat => 10)

      args.repeat.to_i.times do
        Brand.create( { name: Faker::Company.name })
      end
    end

    desc '***DRY*** Fake Line creation'
    task :line, [:repeat] => [:environment] do |t,args|
      args.with_defaults(:repeat => 500)

      # TODO: DRY This up,
      if Brand.count == 0
        10.times do
          Brand.create( { name: Faker::Company.name })
        end
      end

      args.repeat.to_i.times do
        brand = Brand.limit(1).order("RANDOM()")
        Line.create( { name: Faker::Commerce.product_name ,
                        brand_id: brand[0].id})
      end
    end

    task :product, [:repeat] => [:environment] do |t,args|
      args.with_defaults(:repeat => 1000)
      args.repeat.to_i.times do

        if Supplier.count  == 0  # No suppliers, create 50 fakes
          50.times do
            Supplier.create( { name: Faker::Company.name ,
              description: Faker::Lorem.sentence(4)})
          end
        end

        supplier = Supplier.limit(1).order("RANDOM()")

        # Create base product
        p = Product.create({name: Faker::Commerce.product_name,
                          description: Faker::Lorem.sentence(4),
                          includes: Faker::Lorem.sentence(1),
                          features: Faker::Lorem.sentence(2),
                          packsize: Faker::Lorem.sentence(4),
                          packweight: Faker::Lorem.sentence(3),
                          unit_measure: Faker::Lorem.sentence(2),
                          leadtime: Faker::Lorem.sentence(2),
                          rushtime: Faker::Lorem.sentence(2),
                          info: Faker::Lorem.sentence(8),
                          supplier_id: supplier[0].id
                          })

      end
    end
  end
end
