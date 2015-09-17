require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

set :port, 4000
set :environment, :production
set :server, 'thin'
set :sockets, []

def request_max
  puts 'Move Your mouse to the farest right down point in the screen, TMouse needs to know your screen resolution.'
  puts 'Calibration ends in 3 seconds'
  sleep 1
  puts 'Calibration ends in 2 seconds'
  sleep 1
  puts 'Calibration ends in 1 seconds'
  sleep 1
  point = Mouse.current_position
  x = point.x.ceil
  y = point.y.ceil
  puts "Thanks you, your screen resolution is: #{x}x#{y}"
  return {x: x, y: y}
end

screen = request_max
max_x = screen[:x]
max_y = screen[:y]

get '/' do
  if !request.websocket?
    erb :index
  else
    request.websocket do |ws|
      ws.onopen do
        warn 'TMouse connected.'
        ws.send("Hello World!")
        settings.sockets << ws
      end
      ws.onmessage do |msg|
        point = msg.split(',').map &:to_f
        # Mouse.move_to [point[0]*max_x, point[1]*screen[:y]]
        warn msg
      end
      ws.onclose do
        warn 'TMouse disconnected.'
        settings.sockets.delete(ws)
      end
    end
  end
end

__END__
@@ index
<html>
  <head>
    <meta name="viewport" content="width=device-width,user-scalable=no">
    <script src="//code.jquery.com/jquery-1.11.3.min.js"></script>
    <script src="//code.jquery.com/jquery-migrate-1.2.1.min.js"></script>
    <style media="screen">
      body, html{
        width: 100%;
        height: 100%;
        overflow: hidden;
      }
    </style>
  </head>
  <body>
    <script type="text/javascript">
      $(function(){
          var ws       = new WebSocket('ws://' + window.location.host + window.location.pathname);
          var doc      = $('body');
          var width    = doc.width(), height = doc.height();

          $(document.body).bind("touchmove", function(event) {
            endCoords = event.originalEvent.targetTouches[0];
            ws.send([endCoords.pageX/width, endCoords.pageY/height]);
            evet.preventDefault()
          });
        });
    </script>
  </body>
</html>
