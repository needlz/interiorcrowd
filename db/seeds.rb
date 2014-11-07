# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

DesignCategory.delete_all
DesignCategory.create(id: 1,
                      name: 'Complete My Look',
                      description: 'choose this if you already have a style that you like but need to just pull it together',
                      pos: 1,
                      price: 99,
                      before_image: 'contest_creation/before_picture.png',
                      after_image: 'contest_creation/after_picture.png')
DesignCategory.create(id: 2,
                      name: 'Update My Style',
                      description: 'choose this if your place needs updating to fit your current style',
                      pos: 2,
                      price: 99,
                      before_image: 'contest_creation/before_picture.png',
                      after_image: 'contest_creation/after_picture.png')
DesignCategory.create(id: 3,
                      name: 'Total Room Overhaul',
                      description: 'choose this if you want to start from scratch and have a completely new space',
                      pos: 3,
                      price: 199,
                      before_image: 'contest_creation/before_picture.png',
                      after_image: 'contest_creation/after_picture.png')

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
 


