mapdeckGridDependency <- function() {
	list(
		createHtmlDependency(
			name = "grid",
			version = "1.0.0",
			src = system.file("htmlwidgets/lib/grid", package = "mapdeck"),
			script = c("grid.js"),
			all_files = FALSE
		)
	)
}


#' Add Grid
#'
#' The Grid Layer renders a grid heatmap based on an array of points.
#' It takes the constant size all each cell, projects points into cells.
#' The color and height of the cell is scaled by number of points it contains.
#'
#' @inheritParams add_polygon
#' @param lon column containing longitude values
#' @param lat column containing latitude values
#' @param colour_range vector of 6 hex colours
#' @param cell_size size of each cell in meters. Default 1000
#' @param extruded logical indicating if cells are elevated or not. Default TRUE
#' @param elevation_scale cell elevation multiplier. Default 1
#' @param elevation column containing the elevation of the value. This is used to calculate the
#' height of the hexagons. The height is calculated by the sum of elevations of all the coordinates
#' within the \code{radius}. If NULL, the number of coordinates is used.
#' @param colour column containing numeric values to colour by.
#' The colour is calculated by the sum of values within the \code{radius}.
#' If NULL, the number of coordinates is used.
#'
#' @inheritSection add_polygon data
#'
#' @examples
#' \donttest{
#' ## You need a valid access token from Mapbox
#' key <- 'abc'
#'
#' df <- read.csv(paste0(
#' 'https://raw.githubusercontent.com/uber-common/deck.gl-data/master/',
#' 'examples/3d-heatmap/heatmap-data.csv'
#' ))
#'
#' df <- df[ !is.na(df$lng ), ]
#'
#' mapdeck( token = key, style = mapdeck_style("dark"), pitch = 45 ) %>%
#' add_grid(
#'   data = df
#'   , lat = "lat"
#'   , lon = "lng"
#'   , cell_size = 5000
#'   , elevation_scale = 50
#'   , layer_id = "grid_layer"
#'   , auto_highlight = TRUE
#' )
#'
#' ## using sf object
#' library(sf)
#' sf <- sf::st_as_sf( df, coords = c("lng", "lat"))
#'
#' mapdeck( token = key, style = mapdeck_style("dark"), pitch = 45 ) %>%
#' add_grid(
#'   data = sf
#'   , cell_size = 5000
#'   , elevation_scale = 50
#'   , layer_id = "grid_layer"
#'   , auto_highlight = TRUE
#' )
#'
#'
#' }
#'
#' @details
#'
#' \code{add_grid} supports POINT and MULTIPOINT sf objects
#'
#'
#'
#' @export
add_grid <- function(
	map,
	data = get_map_data(map),
	lon = NULL,
	lat = NULL,
	polyline = NULL,
	cell_size = 1000,
	extruded = TRUE,
	elevation = NULL,
	elevation_scale = 1,
	colour = NULL,
	colour_range = NULL,
	auto_highlight = FALSE,
	highlight_colour = "#AAFFFFFF",
	layer_id = NULL,
	update_view = TRUE,
	focus_layer = FALSE,
	digits = 6,
	transitions = NULL
) {

	l <- list()
	l[["lon"]] <- force( lon )
	l[["lat"]] <- force( lat )
	l[["polyline"]] <- force( polyline )
	l[["elevation"]] <- force( elevation )
	l[["colour"]] <- force( colour )

	use_weight <- FALSE
	if(!is.null(elevation)) use_weight <- TRUE

	use_colour <- FALSE
	if(!is.null(colour)) use_colour <- TRUE

	l <- resolve_data( data, l, c("POINT","MULTIPOINT") )

	bbox <- init_bbox()
	update_view <- force( update_view )
	focus_layer <- force( focus_layer )

	if ( !is.null(l[["data"]]) ) {
		data <- l[["data"]]
		l[["data"]] <- NULL
	}

	if( !is.null(l[["bbox"]] ) ) {
		bbox <- l[["bbox"]]
		l[["bbox"]] <- NULL
	}

	## parmater checks
	checkNumeric(elevation_scale)
	checkNumeric(cell_size)

	if( is.null( colour_range ) ) {
		colour_range <- colourvalues::colour_values(1:6, palette = "viridis")
	}

	if(length(colour_range) != 6)
		stop("colour_range must have 6 hex colours")

	checkHex(colour_range)

	checkHexAlpha(highlight_colour)
	layer_id <- layerId(layer_id, "grid")

	map <- addDependency(map, mapdeckGridDependency())

	tp <- l[["data_type"]]
	l[["data_type"]] <- NULL

	jsfunc <- "add_grid_geo"

	if ( tp == "sf" ) {
	  geometry_column <- c( "geometry" )
	  shape <- rcpp_grid_geojson( data, l, geometry_column, digits )
	} else if ( tp == "df" ) {
		geometry_column <- list( geometry = c("lon", "lat") )
		shape <- rcpp_grid_geojson_df( data, l, geometry_column, digits )
	} else if ( tp == "sfencoded" ) {
		geometry_column <- "polyline"
		shape <- rcpp_grid_polyline( data, l, geometry_column )
		jsfunc <- "add_grid_polyline"
	}

	js_transitions <- resolve_transitions( transitions, "grid" )

	invoke_method(
		map, jsfunc, map_type( map ), shape[["data"]], layer_id, cell_size,
		jsonify::to_json(extruded, unbox = TRUE), elevation_scale,
		colour_range, auto_highlight, highlight_colour, bbox, update_view, focus_layer,
		js_transitions, use_weight, use_colour
		)
}


#' @rdname clear
#' @export
clear_grid <- function( map, layer_id = NULL) {
	layer_id <- layerId(layer_id, "grid")
	invoke_method(map, "md_layer_clear", map_type( map ), layer_id, "grid" )
}
