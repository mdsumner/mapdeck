% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/map_layer_column.R
\name{add_column}
\alias{add_column}
\title{Add column}
\usage{
add_column(map, data = get_map_data(map), polyline = NULL,
  lon = NULL, lat = NULL, fill_colour = NULL, fill_opacity = NULL,
  stroke_colour = NULL, stroke_opacity = NULL, stroke_width = NULL,
  radius = 1000, elevation = NULL, elevation_scale = 1,
  coverage = 1, angle = 0, disk_resolution = 20, tooltip = NULL,
  auto_highlight = FALSE, highlight_colour = "#AAFFFFFF",
  layer_id = NULL, id = NULL, palette = "viridis",
  na_colour = "#808080FF", legend = FALSE, legend_options = NULL,
  legend_format = NULL, update_view = TRUE, focus_layer = FALSE,
  transitions = NULL)
}
\arguments{
\item{map}{a mapdeck map object}

\item{data}{data to be used in the layer. All coordinates are expected to be in
Web Mercator Projection}

\item{polyline}{column of \code{data} containing the polylines}

\item{lon}{column containing longitude values}

\item{lat}{column containing latitude values}

\item{stroke_width}{width of the stroke in pixels}

\item{radius}{in metres. Default 1000}

\item{elevation_scale}{value to scale the elevations of the columns Default 1}

\item{coverage}{radius multiplier, in range [0,1]. The radius of the disk is calcualted
by coverage * radius}

\item{disk_resolution}{The number of sides to render the disk as.
The disk is a regular polygon that fits inside the given radius.
A higher resolution will yield a smoother look close-up, but also requires more resources to render.}

\item{tooltip}{variable of \code{data} containing text or HTML to render as a tooltip}

\item{auto_highlight}{logical indicating if the shape under the mouse should auto-highlight}

\item{highlight_colour}{hex string colour to use for highlighting. Must contain the alpha component.}

\item{layer_id}{single value specifying an id for the layer. Use this value to
distinguish between shape layers of the same type. Layers with the same id are likely
to conflict and not plot correctly}

\item{id}{an id value in \code{data} to identify layers when interacting in Shiny apps.}

\item{palette}{string or matrix. String will be one of \code{colourvalues::colour_palettes()}.
A matrix must have at least 5 rows, and 3 or 4 columns of values between [0, 255],
where the 4th column represents the alpha. You can use a named list to specify a different
palette for different colour options (where available),
 e.g. list(fill_colour = "viridis", stroke_colour = "inferno")}

\item{na_colour}{hex string colour to use for NA values}

\item{legend}{either a logical indiciating if the legend(s) should be displayed, or
a named list indicating which colour attributes should be included in the legend.}

\item{legend_options}{A list of options for controlling the legend.}

\item{legend_format}{A list containing functions to apply to legend values. See section legend}

\item{update_view}{logical indicating if the map should update the bounds to include this layer}

\item{focus_layer}{logical indicating if the map should update the bounds to only include this layer}

\item{transitions}{list specifying the duration of transitions.}
}
\description{
The ColumnLayer can be used to render a heatmap of vertical cylinders. It renders
a tesselated regular polygon centered at each given position (a "disk"), and extrude it in 3d.
}
\details{
\code{add_column} supports POINT and MULTIPOINT sf objects
}
\section{data}{


If the \code{data} is a simple feature object, the geometry column is automatically
detected. If the sf object contains more than one geometry column and you want to use a specific one,
you'll need to set the active geometry using \code{sf::st_geometry( x ) <- "your_column" },
where \code{"your_column"} is the name of the column you're activating. See \code{?sf::st_geometry}
}

\section{legend}{


The \code{legend_options} can be used to control the appearance of the legend.
This should be a named list, where the names are one of
\itemize{
  \item{css - a string of valid \code{css} for controlling the appearance of the legend}
  \item{title - a string to use for the title of the legend}
}

If the layer allows different fill and stroke colours, you can use different options for each. See examples in \link{add_arc}.

The \code{legend_format} can be used to control the format of the values in the legend.
This should be a named list, where the names are one of
\itemize{
  \item{fill_colour}
  \item{stroke_colour}
}

depending on which type of colouring the layer supports.

The list elements must be functions to apply to the values in the legend.
}

\section{id}{


The \code{id} is returned to your R session from an interactive shiny environment
by observing layer clicks. This is useful for returning the data.frame row relating to the
cliked shape.

From within a shiny server you would typically use \code{ observeEvent({input$map_arc_click})},
where 'map' is the map_id supplied to \code{mapdeckOutput()}, and 'arc' is the layer
you are clicking on
}

\examples{
\dontrun{

## You need a valid access token from Mapbox
key <- 'abc'
set_token( key )


df <- capitals
df$elev <- sample(50000:500000, size = nrow(df), replace = T)

mapdeck(style = mapdeck_style("dark"), pitch = 45) \%>\%
add_column(
  data = df
  , lat = "lat"
  , lon = "lon"
  , elevation = "elev"
  , fill_colour = "lon"
  , disk_resolution = 20
  , radius = 100000
  , tooltip = "capital"
)

library( sf )
sf <- sf::st_as_sf( df, coords = c("lon", "lat"))
sf$elev <- df$elev
mapdeck( style = mapdeck_style("dark"), pitch = 45 ) \%>\%
add_column(
  data = sf
  , layer_id = "col_layer"
  , elevation = "elev"
  , radius = 100000
  , fill_colour = "country"
)


}

}
