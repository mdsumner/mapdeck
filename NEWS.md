# mapdeck 0.3

* `add_mesh()` for quadmesh objects
* Google Map supported
* `mapdeck_legend` and `legend_element` for manually creating legends
* `add_column()` to draw columns (as any polygon shape)
* `add_text()` gets `billbaord`, `font_family`, `font_weight`
* `add_greatcircles()` to draw flat great circles
* `add_line` width docs updated to say 'metres'
* `add_arc` gets `tilt` and `height` arguments
* `add_arc` gets `brush_radius` argument for brushing
* opacity values can be in [0,1) OR [0,255]
* layeres work without an access token
* `add_title()` for adding titles to map
* `add_scatterplot` gets `stroke_colour` and `stroke_width` arguments
* `add_hexagon` gets transitions
* `add_hexagon` gets `weight` and `colour_value` arguments for defining height and colour
* `stroke_width` units defined in help files

# mapdeck 0.2

* different palettes for both stroke & fill options
* `stroke_colour` fix for polygons
* `transitions` argument for most layers
* `mapdeck()` argument order changed so `data` is first ( to work better with pipes ) 
* `update_view` and `focus_layer` added to focus layers on data
* bearing and pitch maintained on data layer updates
* `bearing` argument to `mapdeck()`
* `add_geojson()` fully supported
* `add_sf()` convenience function
* Z attributes supported
* `MULTI`-geometry sf objects supported 
* can use variables in place of string arguments
* `highlight_colour` argument
* all `add_*()` functions migrated to c++
* `layer_id` is optional to the user
* `auto_highlight` argument
