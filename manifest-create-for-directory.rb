require 'json'

dir = "./images/"
canvases = []
slug = "custom"
no = 1
urlbase = "http://jeffreycwitt.com"
imageurlbase = "http://localhost:8182/iiif/2"

## list of files in directory to be skipped
skip_array = ["manifest.jsonld"]

def canvas_block(slug, filename, no, w, h, label, urlbase, imageurlbase)
  block = {
    "@context": "http://iiif.io/api/presentation/2/context.json",
    "@id": "#{urlbase}/#{slug}/canvas/#{no}",
    "@type": "sc:Canvas",
    "label": label,
    "height": h.to_i,
    "width": w.to_i,
    "images": [{
      "@context": "http://iiif.io/api/presentation/2/context.json",
      "@id": "#{urlbase}/#{slug}/annotation/#{no}-image",
      "@type": "oa:Annotation",
      "motivation": "sc:painting",
      "on": "#{urlbase}/#{slug}/canvas/#{no}",
      "resource": {
        "@id": "#{urlbase}/#{slug}/res/#{no}",
        "@type": "dctypes:Image",
        "format": "image/jpeg",
        "height": h.to_i,
        "width": w.to_i,
        "service": {
          "@context": "http://iiif.io/api/image/2/context.json",
          "@id": "#{imageurlbase}/#{filename}",
          "profile": "http://iiif.io/api/image/2/level2.json"
        }
      }
    }]
  }
end

# Get list of images directory
filenames = Dir.entries(dir)
# sort imageurlbase by creation date
sorted_filenames = filenames.sort_by {|filename| File.new(dir + "/" + filename).birthtime  }
# loop through images
sorted_filenames.each do |item|
  next if item == '.' or item == '..' or item == '.DS_Store' or skip_array.include? item
  # get width of image using imagemagik
  # comment out if image imagemagik is not installed
  # and set w manually
  w = `identify -format '%w' #{dir}/#{item}`
  # get height of image using imagemagik
  # comment out if image imagemagik is not installed
  # and seth manually
  h = `identify -format '%h' #{dir}/#{item}`
  # set label (file name minus prefix)
  label = item.split(".")[0]
  # create canvas block for image
  canvases << canvas_block(slug, item, no, w, h, label, urlbase, imageurlbase)
  no = no + 1
end

manifest = {
  "@context": "http://iiif.io/api/presentation/2/context.json",
  "@id": "#{urlbase}/#{slug}/manifest",
  "@type": "sc:Manifest",
  "label": "Manifest for #{slug}",
  "description": "Manifest for #{slug}",
  "license": "https://creativecommons.org/publicdomain/zero/1.0/",
  "sequences": [
    {
      "@context": "http://iiif.io/api/presentation/2/context.json",
      "@id": "#{urlbase}/#{slug}/sequence/normal",
      "@type": "sc:Sequence",
      "label": "Current page order",
      "viewingDirection": "left-to-right",
      "viewingHint": "paged",
      "canvases": canvases
    }
  ]
}

File.open("manifest.jsonld", 'w') { |file| file.write(JSON.pretty_generate(manifest)) }
