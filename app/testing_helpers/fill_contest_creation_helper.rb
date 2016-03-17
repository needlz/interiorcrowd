class FillContestCreationHelper < TestHelperBase

  def self.contest_options_source
    { design_brief: {
        design_category: DesignCategory.last.id,
        design_area: DesignSpace.last.id },
      design_space: {
          length: '2',
          width: '2',
          height: '2',
          length_inches: '10',
          width_inches: '9',
          height_inches: '3',
          f_budget: '2000',
          feedback: 'feedback',
          document_id: [Image.space_images.last.id, Image.space_images.last.id].join(',') },
      preview: {
          b_plan: '1',
          contest_name: 'contest_name' },
      design_style: {
          designer_level: 1,
          desirable_colors: '#bbbbbb',
          undesirable_colors: '#aaaaaa,#888888',
          appeals: {
              some_appeal: {
                  reason: 'reason',
                  value: 100} },
          document_id: [Image.liked_examples.last.id, Image.liked_examples.last.id].join(','),
          ex_links: ['link1', 'link2'] },
      contest: {
          retailer_ikea: true,
          elements_to_avoid: 'Fur',
          entertaining: 1,
          durability: 2,
          preferred_retailers: {
              ikea: true,
              other: 'other'
          }
      }
    }
  end

  def create_full
    session.merge!(FillContestCreationHelper.contest_options_source)
    controller.redirect_to(controller.preview_contests_path)
  end

  def create_with_brief_pending
    session.merge!(FillContestCreationHelper.contest_options_source).deep_merge!(design_space: {document_id: nil })
    controller.redirect_to(controller.preview_contests_path)
  end

end
