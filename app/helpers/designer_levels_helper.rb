module DesignerLevelsHelper

  def designer_level_image(designer_level)
    designer_level_pictures = {
        'novice' => '/assets/design_levels/novice.jpg',
        'enthusiast' => '/assets/design_levels/enthusiast.jpg',
        'savvy' => '/assets/design_levels/savvy.jpg'
    }
    designer_level_pictures[designer_level.name]
  end

end

