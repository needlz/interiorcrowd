getVisibleHeight = function() {
    var visibleHeight = 250;
    if (window.matchMedia( "(max-width: 320px)" ).matches) {
        visibleHeight = 420;
    } else if (window.matchMedia( "(max-width: 768px)" ).matches) {
        visibleHeight = 320;
    }
    return visibleHeight;
};

getOffsetToHiddenText = function() {
    var offsetTop = 60;
    if (window.matchMedia( "(max-width: 320px)" ).matches) {
        offsetTop = 20;
    } else if (window.matchMedia( "(max-width: 480px)" ).matches) {
        offsetTop = 40;
    }
    return offsetTop;
};

getInitialOffsetToStory = function() {
    var restoreOffset = 1130;
    if (window.matchMedia( "(max-width: 320px)" ).matches) {
        restoreOffset = 1830;
    } else if (window.matchMedia( "(max-width: 768px)" ).matches) {
        restoreOffset = 1330;
    } else if (window.matchMedia( "(max-width: 992px)" ).matches) {
        restoreOffset = 1230;
    }
    return restoreOffset;
};

enableSpoiler = function() {
    $('#the-story-collapsible').dotdotdot({ height: getVisibleHeight() });
};

showMore = function(offset) {
    $('#the-story-collapsible').dotdotdot();
    $('.read-more').hide();
    $('html, body').animate({
        scrollTop: offset.top + getOffsetToHiddenText()
    });
};

showLess = function(offset) {
    $('#the-story-collapsible').dotdotdot({ height: getVisibleHeight() });
    $('html, body').animate({
        scrollTop: offset.top - getInitialOffsetToStory()
    });
};

$(document).ready(function(){

    enableSpoiler();

    $(document).on('click', '.read-more', function(event){
        event.preventDefault();
        showMore($(this).offset());
    });

    $(document).on('click', '.read-less', function(event){
        event.preventDefault();
        showLess($(this).offset());
    });
});

$(document).ready(function(){

    var sliderFuction = function() {

        if( $('.about-slider').hasClass('slick-initialized') ) {
            $('.slick-navigation-wrapper').remove();
            $('.about-slider').slick('unslick');
        }

        $('.about-slider').slick({
            dots: true,
            arrows: false,
            slide: '.about-slide',
            slidesToShow: 1,
            slidesToScroll: 1,
            responsive: [{
                breakpoint: 99999,
                settings: "unslick"
            },{
                breakpoint: 991,
                settings: {
                    slidesToShow: 2,
                    dots: true
                }
            },{
                breakpoint: 768,
                settings: {
                    slidesToShow: 1,
                    dots: true
                }
            }]
        });

        if ( !($('.slick-navigation-wrapper').length) ) {
            $('.slick-dots').each(function(index, el) {
                $(this)
                    .wrap('<div class="slick-navigation-wrapper"></div>');
                $(this).parents('.slick-navigation-wrapper')
                    .append('<button type="button" class="slick-next">Next</button>')
                    .prepend('<button type="button" class="slick-prev">Prev</button>');
            });
        }

    };

    sliderFuction();
    $(window).resize(function() {
        sliderFuction();
    });

    $(document).on('click', '.slick-prev', function(event) {
        $(this).parents('.slick-slider').slick('slickPrev');
    });

    $(document).on('click', '.slick-next', function(event) {
        $(this).parents('.slick-slider').slick('slickNext');
    });

});
