class @ProcessedFilesUpdater

  uploadIconFilename = 'thumbnail_is_being_generated.svg'
  uploadIconFilenameEscaped = 'thumbnail_is_being_generated\\.svg'

  @setTimer: ->
    return if @timer
    @timer = setTimeout(
      =>
        @update()
      5000
    )

  @update: (onUpdated)=>
    @timer = null
    $imagesBeingProcessed = @imagesBeingProcessed()
    if $imagesBeingProcessed.length
      imagesIds = $imagesBeingProcessed.map(
        (index, img)=>
          @imageSrc(img)[1]
      ).get()
      imagesIds = imagesIds.filter (item, pos)->
        imagesIds.indexOf(item) == pos
      $.ajax
        url: '/images/ready?images_ids=' + imagesIds.join(',')
        success: (response)=>
          for imageResponse in response
            if imageResponse.processed
              $images = $imagesBeingProcessed.filter (index, img)=>
                regexp = "\\/assets\\/#{ uploadIconFilenameEscaped }\\?image_id=#{ imageResponse.image_id }&ready_url\=(.+)"
                @imageSrc(img, regexp)
              $images.each (index, img)=>
                $img = $(img)
                if imageResponse.file_type == 'image'
                  url = @imageSrc(img)[2]
                else
                  url = '/assets/file-icon.png'
                if $img.prop('tagName') == 'IMG'
                  $img.attr('src', url)
                else if $img.prop('tagName') == 'DIV'
                  $img.css('background-image', "url(#{ url })")
                else if $img.prop('tagName') == 'A'
                  $img.attr('href', url)
      @setTimer()
      

  @imageSrc: (element, regex)->
    regex = regex || "\\/assets\\/#{ uploadIconFilenameEscaped }\\?image_id=(\\d+)&ready_url=(.+)"
    $image = $(element)
    if $image.prop('tagName') == 'IMG'
      $image.attr('src').match(new RegExp(regex))
    else if $image.prop('tagName') == 'DIV'
      $image.css('background-image').match(new RegExp(regex + '"'))
    else if $image.prop('tagName') == 'A'
      $image.attr('href').match(new RegExp(regex + '"'))

  @imagesBeingProcessed: ->
    $("img[src*=\"/assets/#{ uploadIconFilename }?\"], [style*=\"/assets/#{ uploadIconFilename }?\"]").filter (index, image)=>
      @imageSrc(image)

$ ->
  ProcessedFilesUpdater.setTimer()
