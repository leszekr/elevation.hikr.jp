require 'sinatra'
require 'json'

set :root, File.join(File.dirname(__FILE__), '..')
set :views, Proc.new { File.join(root, "views") } 

get '/' do
	haml :home
end

def get_filename(lon,lat)
  lat_floor = lat.floor
  lon_floor = lon.floor

  lon_floor_s = lon_floor.abs.to_s
  if(lon_floor.abs<100) 
    lon_floor_s = "0"+lon_floor_s
    if(lon_floor.abs<10)
      lon_floor_s = "0"+lon_floor_s
    end
  end

  if(lon_floor<0)
    lon_floor_s = "W"+lon_floor_s
  else
    lon_floor_s = "E"+lon_floor_s
  end

  lat_floor_s = lat_floor.abs.to_s
  if(lat_floor.abs<10)
    lat_floor_s = "0" + lat_floor_s
  end

  if(lat_floor<0)
    lat_floor_s = "S"+lat_floor_s
  else
    lat_floor_s = "N"+lat_floor_s
  end

  "elevation/#{lat_floor_s}#{lon_floor_s}.hgt"
end

def get_elevation(lon,lat)
  filename = get_filename lon, lat
  lat_floor = lat.floor
  lon_floor = lon.floor
  p filename
  if File.exist?(filename)
    latpos = 1201-(1200*(lat-lat_floor)).round
    lngpos = (1200*(lon-lon_floor)).round
    seek = 2*1201*latpos+2*lngpos
    i = IO.binread(filename,2,seek)
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
  filename = params[:filename] || "geo.json"
  if params[:geojson]
    obj = JSON.parse(params[:geojson])
    if(obj["features"])
      obj["features"].each do |feature|
        if feature["geometry"] && feature["geometry"]["type"] && feature["geometry"]["coordinates"]
          if feature["geometry"]["type"]=="Point"
            coords = feature["geometry"]["coordinates"]
            e = get_elevation(coords[0].to_f,coords[1].to_f)
            feature["geometry"]["coordinates"][2] = e
          elsif feature["geometry"]["type"]=="LineString"
            feature["geometry"]["coordinates"].each do |coords|
              e = get_elevation(coords[0].to_f,coords[1].to_f)
              coords[2] = e
            end
          elsif feature["geometry"]["type"]=="Polygon"
            feature["geometry"]["coordinates"].each do |coordset|
              coordset.each do |coords|
                e = get_elevation(coords[0].to_f,coords[1].to_f)
                coords[2] = e
              end
            end
          end
        end
      end
    end
    headers 'Content-Disposition'=> 'attachment; filename="'+filename+'"'
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
