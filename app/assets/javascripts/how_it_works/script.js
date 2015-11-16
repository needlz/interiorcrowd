$(document).ready(function(){

    $('.faq-panel-title').on('click', function(event) {
        event.preventDefault();
    });
    //drop
    activePop = null;
    dropClass = $('.faq-panel');
    function closeInactivePop() {
        dropClass.each(function (i) {
            if ($(this).hasClass('active') && i!=activePop) {
                $(this).removeClass('active');
            }
        });
        return false;
    }
    dropClass.mouseover(function() {
        activePop = dropClass.index(this);
    });
    dropClass.mouseout(function() {
        activePop = null;
    });
    $(document.body).click(function(){
        closeInactivePop();
    });
    $(".faq-panel-title").click(function(){
        $(this).parent(dropClass).toggleClass("active");
    });

});//document ready

$(window).load(function() {

    //load

});//window load