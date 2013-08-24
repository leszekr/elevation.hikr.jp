require 'sinatra'
require 'json'

set :root, File.join(File.dirname(__FILE__), '..')
set :views, Proc.new { File.join(root, "views") } 

get '/' do
	haml :home
end

def get_elevation(lon,lat)
  lat_floor = lat.floor
  lon_floor = lon.floor
  if File.exist?("elevation/N#{lat_floor}E#{lon_floor}.hgt")
#   $latpos = round(1200*($lat-$flat));// numbers between 0 and 1201
#   $lngpos = 1200-round(1200*($lng-$flng));
#   $skip = round(2*1201*$lngpos+2*$latpos);
    latpos = 1201-(1200*(lat-lat_floor)).round
    lngpos = (1200*(lon-lon_floor)).round
    seek = 2*1201*latpos+2*lngpos
    i = IO.binread("elevation/N#{lat_floor}E#{lon_floor}.hgt",2,seek)
    if i
      arr = i.unpack("CC")
      e = arr[0]*256+arr[1]
      e
    else
      0
    end
  else
    0
  end
end

post '/', :provides=>"json" do
  if params[:geojson]
    obj = JSON.parse(params[:geojson])
    if(obj["features"])
      obj["features"].each do |feature|
        if feature["geometry"] && feature["geometry"]["type"] && feature["geometry"]["coordinates"]
          if feature["geometry"]["type"]=="Point"
            coords = feature["geometry"]["coordinates"]
            e = get_elevation(coords[0].to_f,coords[1].to_f)
            feature["geometry"]["coordinates"][2] = e
          else
            feature["geometry"]["coordinates"].each do |coords|
              e = get_elevation(coords[0].to_f,coords[1].to_f)
              coords[2] = e
            end
          end
        end
      end
    end
    headers 'Content-Disposition'=> 'attachment; filename="geo.json"'
    JSON.pretty_generate(obj)
  else 
    redirect '/'
  end
end

not_found do
  redirect '/'
end  

error do
  haml :notfound
end