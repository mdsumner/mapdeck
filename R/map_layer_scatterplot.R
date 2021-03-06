mapdeckScatterplotDependency <- function() {
	list(
		createHtmlDependency(
			name = "scatterplot",
			version = "1.0.0",
			src = system.file("htmlwidgets/lib/scatterplot", package = "mapdeck"),
			script = c("scatterplot.js"),
			all_files = FALSE
		)
	)
}

mapdeckScatterplotBrushDependency <- function() {
	list(
		createHtmlDependency(
			name = "scatterplot_brush",
			version = "1.0.0",
			src = system.file("htmlwidgets/lib/scatterplot_brush", package = "mapdeck"),
			script = c("scatterplot_brush.js"),
			all_files = FALSE
		)
	)
}

#' Add Scatterplot
#'
#' The Scatterplot Layer takes in coordinate points and renders them as circles
#' with a certain radius.
#'
#' @inheritParams add_polygon
#' @param lon column containing longitude values
#' @param lat column containing latitude values
#' @param radius in metres. Default 1
#'
#' @inheritSection add_polygon data
#' @inheritSection add_arc legend
#' @inheritSection add_arc id
#'
#' @section transitions:
#'
#' The transitions argument lets you specify the time it will take for the shapes to transition
#' from one state to the next. Only works in an interactive environment (Shiny)
#' and on WebGL-2 supported browsers and hardware.
#'
#' The time is in milliseconds
#'
#' Available transitions for scatterplot
#'
#' list(
#' position = 0,
#' fill_colour = 0,
#' radius = 0
#' )
#'
#' @examples
#'
#' \donttest{
#' ## You need a valid access token from Mapbox
#' key <- 'abc'
#' set_token( key )
#'
#' mapdeck( style = mapdeck_style("dark"), pitch = 45 ) %>%
#' add_scatterplot(
#'   data = capitals
#'   , lat = "lat"
#'   , lon = "lon"
#'   , radius = 100000
#'   , fill_colour = "country"
#'   , layer_id = "scatter_layer"
#'   , tooltip = "capital"
#' )
#'
#' df <- read.csv(paste0(
#' 'https://raw.githubusercontent.com/uber-common/deck.gl-data/master/',
#' 'examples/3d-heatmap/heatmap-data.csv'
#' ))
#'
#' df <- df[ !is.na(df$lng), ]
#'
#' mapdeck( token = key, style = mapdeck_style("dark"), pitch = 45 ) %>%
#' add_scatterplot(
#'   data = df
#'   , lat = "lat"
#'   , lon = "lng"
#'   , layer_id = "scatter_layer"
#' )
#'
#' ## as an sf object
#' library(sf)
#' sf <- sf::st_as_sf( capitals, coords = c("lon", "lat") )
#'
#' mapdeck( token = key, style = mapdeck_style("dark"), pitch = 45 ) %>%
#' add_scatterplot(
#'   data = sf
#'   , radius = 100000
#'   , fill_colour = "country"
#'   , layer_id = "scatter_layer"
#'   , tooltip = "capital"
#' )
#'
#' }
#'
#' @details
#'
#' \code{add_scatterplot} supports POINT and MULTIPOINT sf objects
#'
#' @export
add_scatterplot <- function(
	map,
	data = get_map_data(map),
	lon = NULL,
	lat = NULL,
	polyline = NULL,
	radius = NULL,
	fill_colour = NULL,
	fill_opacity = NULL,
	stroke_colour = NULL,
	stroke_width = NULL,
	stroke_opacity = NULL,
	tooltip = NULL,
	auto_highlight = FALSE,
	highlight_colour = "#AAFFFFFF",
	layer_id = NULL,
	id = NULL,
	palette = "viridis",
	na_colour = "#808080FF",
	legend = FALSE,
	legend_options = NULL,
	legend_format = NULL,
	update_view = TRUE,
	focus_layer = FALSE,
	transitions = NULL,
	brush_radius = NULL
) {

	l <- list()
	l[["lon"]] <- force(lon)
	l[["lat"]] <- force(lat)
	l[["polyline"]] <- force(polyline)
	l[["radius"]] <- force(radius)
	l[["fill_colour"]] <- force(fill_colour)
	l[["fill_opacity"]] <- resolve_opacity(fill_opacity)
	l[["stroke_colour"]] <- force( stroke_colour )
	l[["stroke_opacity"]] <- resolve_opacity( stroke_opacity )
	l[["stroke_width"]] <- force( stroke_width )
	l[["tooltip"]] <- force(tooltip)
	l[["id"]] <- force(id)
	l[["na_colour"]] <- force(na_colour)

	l <- resolve_palette( l, palette )
	l <- resolve_legend( l, legend )
	l <- resolve_legend_options( l, legend_options )
	l <- resolve_data( data, l, c( "POINT", "MULTIPOINT") )

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

	layer_id <- layerId(layer_id, "scatterplot")
	checkHexAlpha(highlight_colour)

	map <- addDependency(map, mapdeckScatterplotDependency())

	tp <- l[["data_type"]]
	l[["data_type"]] <- NULL

	if(!is.null(brush_radius)) {
		jsfunc <- "add_scatterplot_brush_geo"
		map <- addDependency(map, mapdeckScatterplotBrushDependency())
	} else {
		jsfunc <- "add_scatterplot_geo"
		map <- addDependency(map, mapdeckScatterplotDependency())
	}

	if ( tp == "sf" ) {
		geometry_column <- c( "geometry" )
		shape <- rcpp_scatterplot_geojson( data, l, geometry_column )
	} else if ( tp == "df" ) {
		geometry_column <- list( geometry = c("lon", "lat") )
		shape <- rcpp_scatterplot_geojson_df( data, l, geometry_column )
	} else if ( tp == "sfencoded" ) {
		geometry_column <- c( "polyline" )
		shape <- rcpp_scatterplot_polyline( data, l, geometry_column )
		if(!is.null(brush_radius)) {
			jsfunc <- "add_scatterplot_brush_polyline"
		} else {
			jsfunc <- "add_scatterplot_polyline"
		}
	}

	js_transitions <- resolve_transitions( transitions, "scatterplot" )
	if( inherits( legend, "json" ) ) {
		shape[["legend"]] <- legend
	} else {
		shape[["legend"]] <- resolve_legend_format( shape[["legend"]], legend_format )
	}

	#print( shape[["data"]] )

	invoke_method(
		map, jsfunc, map_type( map ), shape[["data"]], layer_id, auto_highlight, highlight_colour,
		shape[["legend"]], bbox, update_view, focus_layer, js_transitions,
		brush_radius
		)
}

#' @rdname clear
#' @export
clear_scatterplot <- function( map, layer_id = NULL) {
	layer_id <- layerId(layer_id, "scatterplot")
	invoke_method(map, "md_layer_clear", map_type( map ), layer_id, "scatterplot" )
}
