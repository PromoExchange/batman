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
px:fake:keyword[<num>]  Create num fake keywords, default=100.
px:fake:line[<num>]     Create num fake lines.
                        Associate with current brands
                        If no brands exists, create 10 fake ones
px:fake:image[<num>]    Create num fake images (num*type),
                        default 1000 (1000*type)
px:fake:imagetype[<num>] Create imagetype associations with products
                        N.B. num * types * products
                        Default = 1 (You should not need to change this)
px:fake:keywordproduct[<num>]
                        Create keyword product associations
                        N.B. num * keywords * products
                        Default = 10 (You should not need to change this)
*The paramater and the square brackets are optional.
END
    puts text
  end

  task info: :environment do |t|
    text = <<END
PX Database Stats
Table           | Count
----------------|----------------
Products        | #{Product.count}
Suppliers       | #{Supplier.count}
Materials       | #{Material.count}
Sizes           | #{Size.count}
Brands          | #{Brand.count}
Lines           | #{Line.count}
Colors          | #{Color.count}
Images          | #{Image.count}
Imagetype       | #{Imagetype.count}
Keyword         | #{Keyword.count}
KeywordProduct  | #{KeywordProduct.count}
END
    puts text
  end

  namespace :fake do
    desc 'Fake supplier creation'
    task :supplier, [:repeat] => [:environment] do |t,args|
      args.with_defaults(:repeat => 10)

      args.repeat.to_i.times do
        CreateSupplier
      end
    end

    def CreateSupplier()
      Supplier.create( { name: Faker::Company.name ,
        description: Faker::Lorem.sentence(4)})
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

    desc 'Fake Image creation'
    task :image, [:repeat] => [:environment] do |t,args|
      args.with_defaults(:repeat => 1000)

      args.repeat.to_i.times do
          {
            'large'  => '500x500',
            'medium' => '400x400',
            'small' => '300x300',
            'thumb' => '150x150',
            'zoom' => '50x50'
          }.each do |k,v|
          CreateImage( k, v,false)
        end
      end
    end

    desc 'Fake ImageType creation'
    task :imagetype, [:repeat] => [:environment] do |t,args|
      args.with_defaults(:repeat => 1)

      image_types = {
        'large'  => '500x500',
        'medium' => '400x400',
        'small' => '300x300',
        'thumb' => '150x150',
        'zoom' => '50x50'
      }

      # At least one of each
      image_types.each do |k,v|
        CreateImage( k, v,false)
      end

      args.repeat.to_i.times do
        Product.find_each do |p|
          image_types.each do |k,v|
            image = Image.limit(1).where( title: k).order("RANDOM()").first
            # puts image.id
            # puts p.id
            Imagetype.create( { image_id: image.id ,
                                product_id: p.id,
                                sizetype: k })
          end
        end
      end
    end

    def CreateImage(title,dim,check_first)
      frgtbtt = false

      if check_first
        frgtbtt = Image.exists?(title: title)
      end

      Image.create( { title: title ,
                      location: Faker::Avatar.image(Faker::Number.number(12) , dim)}) unless frgtbtt
    end

    desc 'Fake Keyword creation'
    task :keyword, [:repeat] => [:environment] do |t,args|
      args.with_defaults(:repeat => 100)

      args.repeat.to_i.times do
        Keyword.create({ word: Faker::Lorem.word })
      end
    end

    desc 'Fake KeywordProduct creation'
    task :keywordproduct, [:repeat] => [:environment] do |t,args|
      args.with_defaults(:repeat => 10)

      args.repeat.to_i.times do
        Product.find_each do |p|
          keyword = Keyword.limit(1).order("RANDOM()").first
          # puts image.id
          # puts p.id
          KeywordProduct.create( { keyword_id: keyword.id ,
                                    product_id: p.id })
        end
      end

      args.repeat.to_i.times do
        Keyword.create({ word: Faker::Lorem.word })
      end
    end

    desc 'Create fake product'
    task :product, [:repeat] => [:environment] do |t,args|
      args.with_defaults(:repeat => 1000)
      args.repeat.to_i.times do

        if Supplier.count == 0  # No suppliers, create 50 fakes
          50.times do
            CreateSupplier
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
    end # task :product
  end # namespace :fake
end # namespace :px
