# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

DesignCategory.delete_all
DesignCategory.create(id: 1,
                      name: 'quick_fix',
                      pos: 1,
                      price: 99,
                      before_picture: 'contest_creation/before_picture.png',
                      after_picture: 'contest_creation/after_picture.png')
DesignCategory.create(id: 2,
                      name: 'update_my_style',
                      pos: 2,
                      price: 99,
                      before_picture: 'contest_creation/before_picture.png',
                      after_picture: 'contest_creation/after_picture.png')
DesignCategory.create(id: 3,
                      name: 'total_room_overhaul',
                      pos: 3,
                      price: 199,
                      before_picture: 'contest_creation/before_picture.png',
                      after_picture: 'contest_creation/after_picture.png')

DesignSpace.delete_all
DesignSpace.create(id: 1, name: 'Bedroom', pos: 10, parent_id: 0)
DesignSpace.create(id: 2, name: 'Master', pos: 11, parent_id: 1)
DesignSpace.create(id: 3, name: 'Guest', pos: 12, parent_id: 1)
DesignSpace.create(id: 4, name: 'Children', pos: 13, parent_id: 1)

DesignSpace.create(id: 5, name: 'Other', pos: 14, parent_id: 1)

DesignSpace.create(id: 6, name: 'Bathroom', pos: 30, parent_id: 0)
DesignSpace.create(id: 7, name: 'Master (full bath)', pos: 31, parent_id: 6)
DesignSpace.create(id: 8, name: 'Guest (full bath)', pos: 32, parent_id: 6)
DesignSpace.create(id: 9, name: 'Children (full bath)', pos: 33, parent_id: 6)
DesignSpace.create(id: 10, name: 'Master (half bath)', pos: 34, parent_id: 6)
DesignSpace.create(id: 11, name: 'Children (full bath)', pos: 35, parent_id: 6)
DesignSpace.create(id: 12, name: 'Guest (half bath)', pos: 36, parent_id: 6)

DesignSpace.create(id: 13, name: 'Kitchen', pos: 40, parent_id: 0)
DesignSpace.create(id: 14, name: 'Living Room', pos: 50, parent_id: 0)
DesignSpace.create(id: 15, name: 'Family Room/Den', pos: 60, parent_id: 0)

DesignSpace.create(id: 16, name: 'Dining Room', pos: 70, parent_id: 0)
DesignSpace.create(id: 17, name: 'Mudroom', pos: 80, parent_id: 0)
DesignSpace.create(id: 18, name: 'Playroom', pos: 90, parent_id: 0)

DesignSpace.create(id: 19, name: 'Foyer', pos: 100, parent_id: 0)
DesignSpace.create(id: 20, name: 'Garage', pos: 110, parent_id: 0)
DesignSpace.create(id: 21, name: 'Closet', pos: 120, parent_id: 0)

DesignerLevel.delete_all
DesignerLevel.create(id: 1, name: 'Novice', image: 'back-pic.png')
DesignerLevel.create(id: 2, name: 'Enthusiast', image: 'back-pic.png')
DesignerLevel.create(id: 3, name: 'Savvy', image: 'back-pic.png')

Appeal.delete_all
Appeal.create(id: 1, first_name: 'feminine', second_name: 'masculine', image: 'blank.png')
Appeal.create(id: 2, first_name: 'elegant', second_name: 'eclectic', image: 'blank.png')
Appeal.create(id: 3, first_name: 'traditional', second_name: 'modern', image: 'blank.png')
Appeal.create(id: 4, first_name: 'conservative', second_name: 'bold', image: 'blank.png')
Appeal.create(id: 5, first_name: 'muted', second_name: 'colorful', image: 'blank.png')
Appeal.create(id: 6, first_name: 'timeless', second_name: 'trendy', image: 'blank.png')
Appeal.create(id: 7, first_name: 'fancy', second_name: 'playful', image: 'blank.png')
