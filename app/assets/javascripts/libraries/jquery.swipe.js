(function($) {
  $.fn.swipe = function(options) {
    options = $.extend({threshold: {x: 25, y: 10}}, options);

    return this.each(function() {
      var self = $(this);
      var startCoords = {x: 0, y: 0}, endCoords = {x: 0, y: 0};

      this.addEventListener("touchstart", function(event) {
        startCoords.x = event.targetTouches[0].pageX;
        startCoords.y = event.targetTouches[0].pageY;
        endCoords.x = event.targetTouches[0].pageX;
        endCoords.y = event.targetTouches[0].pageY;
      });

      this.addEventListener("touchmove", function(event) {
        endCoords.x = event.targetTouches[0].pageX;
        endCoords.y = event.targetTouches[0].pageY;
      });

      this.addEventListener("touchend", function() {
        var changeY = Math.abs(startCoords.y - endCoords.y);
        if( changeY < options.threshold ) {
          var changeX = startCoords.x - endCoords.x;
          if( changeX > 0 && changeX > options.threshold.x ) {
            self.trigger("swipeleft");
          } else if( changeX < 0 && Math.abs(changeX) > options.threshold.x ) {
            self.trigger("swiperight");
          }
        }
      });

      this.addEventListener("touchcancel", function() {
        startCoords.x = 0, startCoords.y = 0, endCoords.x = 0, endCoords.y = 0;
      });
    });
  }
});
