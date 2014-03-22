# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

DesignCategory.delete_all
DesignCategory.create(id: 1, name: 'Furniture', pos: 1, price: 99, image_name: 'bedroom.png') 
DesignCategory.create(id: 2, name: 'Floor covering', pos: 2, price: 99, image_name: 'carpet.png')
DesignCategory.create(id: 3, name: 'Wall treatments', pos: 3, price: 59, image_name: 'painting.png')
DesignCategory.create(id: 4, name: 'Window treatments', pos: 4, price: 120, image_name: 'window.png')
DesignCategory.create(id: 5, name: 'Artwork', pos: 5, price: 99, image_name: 'artwork.png')
DesignCategory.create(id: 6, name: 'Accessories', pos: 6, price: 59, image_name: 'file-manager.png')
DesignCategory.create(id: 7, name: 'Space Planning', pos: 7, price: 59, image_name: 'graphics.png')
DesignCategory.create(id: 8, name: 'Other(specify)', pos: 8, price: 0)
DesignCategory.create(id: 9, name: 'Everything (Soup to nuts)', pos: 9, price: 299)

DesignSpace.delete_all
DesignSpace.create(id: 1, name: 'Bedroom', pos: 10, parent: 0)
DesignSpace.create(id: 2, name: 'Master', pos: 11, parent: 1)
DesignSpace.create(id: 3, name: 'Guest', pos: 12, parent: 1) 
DesignSpace.create(id: 4, name: 'Children', pos: 13, parent: 1)

DesignSpace.create(id: 5, name: 'Other', pos: 14, parent: 1)

DesignSpace.create(id: 6, name: 'Bathroom', pos: 30, parent: 0)
DesignSpace.create(id: 7, name: 'Master (full bath)', pos: 31, parent: 6)
DesignSpace.create(id: 8, name: 'Guest (full bath)', pos: 32, parent: 6)
DesignSpace.create(id: 9, name: 'Children (full bath)', pos: 33, parent: 6)
DesignSpace.create(id: 10, name: 'Master (half bath)', pos: 34, parent: 6)
DesignSpace.create(id: 11, name: 'Children (full bath)', pos: 35, parent: 6)
DesignSpace.create(id: 12, name: 'Guest (half bath)', pos: 36, parent: 6)

DesignSpace.create(id: 13, name: 'Kitchen', pos: 40, parent: 0)
DesignSpace.create(id: 14, name: 'Living Room', pos: 50, parent: 0)
DesignSpace.create(id: 15, name: 'Family Room/Den', pos: 60, parent: 0)

DesignSpace.create(id: 16, name: 'Dining Room', pos: 70, parent: 0)
DesignSpace.create(id: 17, name: 'MudRoom', pos: 80, parent: 0)
DesignSpace.create(id: 18, name: 'PlayRoom', pos: 90, parent: 0)

DesignSpace.create(id: 19, name: 'Foyer', pos: 100, parent: 0)
DesignSpace.create(id: 20, name: 'Garage', pos: 110, parent: 0)
DesignSpace.create(id: 21, name: 'Closet', pos: 120, parent: 0)
 


