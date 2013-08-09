Portfolio.pages = {};
Portfolio.initialize = function(page) {
  var remove_active = function() {
    $(this).attr("style", null);
    $(this).closest(".menu").removeClass("active click-active opened");
  };

  var remove_block = function() {
    $(this).attr("style", null);
  };

  $("#menu-nav").on("click", "a.has-children", function(event) {
    if( $(this).attr("href") == "#" ) event.preventDefault();

    var menu = $(this).closest(".menu");
    if( menu.css("display") == "inline-block" ) return;

    // Hide this menu
    if( menu.hasClass("active") || menu.hasClass("click-active") || menu.hasClass("opened") ) {
      menu.find(".sub-menu").slideUp(75, remove_active);

    // Show this menu, hide others
    } else {
      $("#menu-nav .active, #menu-nav .opened").each(function() {
        $(this).removeClass("active click-active opened");
        $(this).find(".sub-menu").slideUp(75, remove_active);
      });

      menu.find(".sub-menu").slideDown(75, remove_block);
      menu.addClass("click-active opened");
    }
  });

  $("#menu-nav").on("mouseenter", ".menu", function() {
    if( $(this).css("display") != "inline-block" ) return;

    $("#menu-nav .active").removeClass("opened active mouse-active");
    $(this).addClass("opened active mouse-active");

    var sub_menu = $(this).find(".sub-menu");
    sub_menu.css("left", "");

    var sub_position = sub_menu.position();
    var sub_right = sub_position.left + sub_menu.width();
    var right = $("#menu-nav").position().left + $("#menu-nav").width();

    if( sub_right > right ) {
      var offset = sub_position.left - ((sub_right - right) * 2) - 1;
      sub_menu.css("left", offset + "px");
    }
  });

  $("#menu-nav").on("mouseleave", ".menu", function() {
    if( $(this).css("display") != "inline-block" ) return;
    $("#menu-nav .active").removeClass("opened active mouse-active");
  });

  if( Portfolio.pages[page] ) {
    Portfolio.pages[page]();
  }
};