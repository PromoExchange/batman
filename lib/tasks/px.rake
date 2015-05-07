namespace :px do
  task help: :environment do |t|
    text = <<END
PX Rake commands
px:help                 This output
px:info                 Current DB stats
px:fake:supplier[<num>] Create num fake suppliers, default=10
px:fake:material[<num>] Create num fake materials, default=10
px:fake:materialproduct Create material product associations
                        For each product that does not have a material
                        association, create one randomly.
px:fake:size[<num>]     Create num fake sizes, default=10
px:fake:brand[<num>]    Create num fake brands, default=100
px:fake:keyword[<num>]  Create num fake keywords, default=100.
px:fake:line[<num>]     Create num fake lines.
                        Associate with current brands
                        If no brands exists, create 10 fake ones
px:fake:lineproduct     Create line product associations
                        For each product that does not have a line
                        association, create one randomly.
px:fake:image[<num>]    Create num fake images (num*type),
                        default 1000 (1000*type)
px:fake:imagetype[<num>] Create imagetype associations with products
                        N.B. (num * types) * products
                        Default = 1 (You should not need to change this)
px:fake:keywordproduct[<num>]
                        Create keyword product associations
                        N.B. num * products
                        Default = 10 (You should not need to change this)
px:fake:sizeproduct[<num>]
                        Create size product associations
                        N.B. num * products
                        Default = 10 (You should not need to change this)
px:fake:product[<num>]  Create num fake products, default=1000
                        N.B. Will use random associations are available
*The paramater and the square brackets are optional.
END
    puts text
  end

  task info: :environment do |t|
    text = <<END
PX Database Stats
Table           | Count
----------------|----------------
Product         | #{Product.count}
Supplier        | #{Supplier.count}
Material        | #{Material.count}
MaterialProduct | #{MaterialProduct.count}
Size            | #{Size.count}
SizeProduct     | #{SizeProduct.count}
Brand           | #{Brand.count}
Line            | #{Line.count}
LineProduct     | #{LineProduct.count}
Color           | #{Color.count}
Image           | #{Image.count}
Imagetype       | #{Imagetype.count}
Keyword         | #{Keyword.count}
KeywordProduct  | #{KeywordProduct.count}
END
    puts text
  end

  namespace :fake do
    desc 'Fake supplier'
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

    desc 'Fake size'
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

    desc 'Fake material'
    task :material, [:repeat] => [:environment] do |t,args|
      args.with_defaults(:repeat => 10)

      args.repeat.to_i.times do
        Material.create( { name: Faker::Commerce.color })
      end
    end

    desc '***DRY*** Fake Brand'
    task :brand, [:repeat] => [:environment] do |t,args|
      args.with_defaults(:repeat => 10)

      args.repeat.to_i.times do
        Brand.create( { name: Faker::Company.name })
      end
    end

    desc '***DRY*** Fake Line'
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

    desc 'Fake Image'
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

    desc 'Fake ImageType'
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

    desc 'Fake Keyword'
    task :keyword, [:repeat] => [:environment] do |t,args|
      args.with_defaults(:repeat => 100)

      args.repeat.to_i.times do
        Keyword.create({ word: Faker::Lorem.word })
      end
    end

    desc 'Fake KeywordProduct'
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

    desc 'Fake Line Product'
    task :lineproduct, [:repeat] => [:environment] do |t,args|
      Product.find_each do |p|
        if LineProduct.where(product_id: p.id).empty?
          line = Line.limit(1).order("RANDOM()").first
          # puts image.id
          # puts p.id
          CreateLineProduct( p.id , line.id , false )
        end
      end
    end

    def CreateLineProduct( product_id , line_id, check_first )
      frgtbtt = false

      if check_first
        frgtbtt = LineProduct.exists?(product_id: product_id)
      end

      LineProduct.create( { line_id: line.id ,
                          product_id: product_id }) unless frgtbtt
    end

    desc 'Fake Material Product'
    task :materialproduct, [:repeat] => [:environment] do |t,args|

      Product.find_each do |p|
        if MaterialProduct.where(product_id: p.id).empty?
          material = Material.limit(1).order("RANDOM()").first
          # puts image.id
          # puts p.id
          CreateMaterialProduct( p.id , material.id , false )
        end
      end
    end

    def CreateMaterialProduct( product_id , material_id , check_first )
      frgtbtt = false

      if check_first
        frgtbtt = MaterialProduct.exists?(product_id: product_id)
      end

      MaterialProduct.create( { material_id: material_id ,
                                product_id: product_id }) unless frgtbtt
    end

    desc 'Fake Size Product'
    task :sizeproduct, [:repeat] => [:environment] do |t,args|
      args.with_defaults(:repeat => 10)
      Product.find_each do |p|
        if SizeProduct.where(product_id: p.id).empty?
          args.repeat.to_i.times do
            size = Size.limit(1).order("RANDOM()").first

            SizeProduct.create( { size_id: size.id,
                                  product_id: p.id })
          end
        end
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
