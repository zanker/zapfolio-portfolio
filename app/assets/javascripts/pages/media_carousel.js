Portfolio.pages.mediacarousel = function() {
  var thumbnails = $("#page .album .thumbnails");
  if( thumbnails.length == 0 ) return;

  var index = 0, active_index = 0;
  var auto_cycle = !$("#page .album").is(":hover");

  function paginate_thumbnails(offset) {
    var list = thumbnails.find(".thumbnail img");
    var total = list.length;
    for( var i=0; i < total; i++ ) {
      var thumbnail = $(list[i]);

      var pos = offset + i;
      var data = media[pos];
      if( !data ) {
        thumbnail.hide();
        continue;
      }

      thumbnail.attr("src", data.s).attr("alt", data.title);
      thumbnail.attr("height", data.sh).attr("width", data.sw);
      thumbnail.attr("data-index", pos).show();

      // Active slide is now visible
      if( pos == active_index ) {
        thumbnails.find("li img.active").removeClass("active");
        thumbnail.addClass("active");
      } else if( thumbnail.hasClass("active") ) {
        thumbnail.removeClass("active");
      }
    }

    $("#page .thumbnails .previous a").attr("disabled", offset < total ? "disabled" : null);
    $("#page .thumbnails .next a").attr("disabled", (offset + total) >= media.length ? "disabled" : null);
  }

  var next_cycle = 1;
  var first_run = true;
  var carousel = $("#page .album .media").cycle({
    fx: "fade",
    delay: carouselTimer,
    timeout: carouselTimer,
    nowrap: false,
    fastOnEvent: 200,
    speed: 750,
    before: function() {
      next_cycle = $(this).data("cycle") == 1 ? 0 : 1;
    },
    after: function() {
      if( first_run ) { first_run = null; return; }
      active_index = index;

      if( auto_cycle ) {
        // Auto cycling so we should increment and check if we need to paginate
        if( thumbnails.find("li img[data-index=" + active_index + "]").length == 0 ) {
          paginate_thumbnails(active_index);
        } else {
          thumbnails.find("li img.active").removeClass("active");
          thumbnails.find("li img[data-index=" + active_index + "]").addClass("active");
        }
      }

      index += 1;
      if( !media[index] ) index = 0;

      var target = $("#page .album .media").find($(this).hasClass("second") ? ".first" : ".second");
      target[0].cycleH = media[index].oh;
      target[0].cycleW = "auto";
      target.attr("height", media[index].oh);
      target.attr("src", media[index].o).attr("alt", media[index].title);
    }
  });

  if( !auto_cycle ) carousel.cycle("pause");

  // Thumbnail browsing
  $("#page .thumbnails li img").click(function() {
    if( $(this).attr("data-index") == thumbnails.find("li img.active").attr("data-index") ) return;
    var next = $("#page .album .media img[data-cycle=" + next_cycle + "]");

    var data = media[$(this).attr("data-index")];
    next[0].cycleH = data.oh;
    next[0].cycleW = "auto";
    next.attr("height", data.oh);
    next.attr("src", data.o).attr("alt", data.title);
    carousel.cycle(next.data("cycle"), "fade");

    // Setup for the next rotation
    active_index = $(this).attr("data-index");
    index = active_index;

    thumbnails.find("li img.active").removeClass("active");
    $(this).addClass("active");
  });

  var total_thumbnails = thumbnails.find(".thumbnail").length;
  $("#page .thumbnails .previous a").click(function(event) {
    event.preventDefault();
    if( $(this).attr("disabled") ) return;

    paginate_thumbnails(parseInt(thumbnails.find(".thumbnail:first img").attr("data-index")) - total_thumbnails);
  });

  $("#page .thumbnails .next a").click(function(event) {
    event.preventDefault();
    if( $(this).attr("disabled") ) return;
    paginate_thumbnails(parseInt(thumbnails.find(".thumbnail:last img").attr("data-index")) + 1);
  });

  // Pagination/cycling management
  $("#page .album").mouseenter(function() {
    auto_cycle = false;
    carousel.cycle("pause");
  });

  $("#page .album").mouseleave(function() {
    if( $(".fancybox-skin").is(":visible")) return;
    auto_cycle = true;
    carousel.cycle("resume", false);
  });

  // Fancybox
  $("#page .media img").click(function() {
    carousel.cycle("pause");

    $.fancybox({
      type: "image",
      href: media[active_index].o,
      title: media[active_index].title,
      afterClose: function() { carousel.cycle("resume", false); }
    });
  });
};