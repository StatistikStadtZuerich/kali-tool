#' download UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#' @param ssz_icons icon list/path which can be used
#' @param ogd_link url to be used with OGD button
#'
#' @noRd
#'
#' @importFrom shiny NS tagList
mod_download_ui <- function(id, ssz_icons, ogd_link){
  ns <- NS(id)
  tagList(
    # Download Panel
    tags$div(
      id = ns("downloadWrapperId"),
      class = "downloadWrapperDiv",
      sszDownloadButton(
        outputId = ns("csv_download"),
        label = "csv",
        image = img(ssz_icons$download)
      ),
      sszDownloadButton(
        outputId = ns("excel_download"),
        label = "xlsx",
        image = img(ssz_icons$download)
      ),
      sszOgdDownload(
        outputId = ns("ogd_download"),
        label = "OGD",
        image = img(ssz_icons("link")),
        href = ogd_link
      )
    )
  )
}

#' download Server Functions
#' @param id id of module(shiny)
#' @param data_download data frame with data to be downloaded (static!) as csv
#' @param fn_no_ext Filename to be used for excel and csv download without extension
#' @param fct_create_excel function to be called with file argument and excel args to create the excel download file
#' @param excel_arg arguments to be passed to fct_create_excel, probably the data to be downloaded in excel, can be list but rely on order, not on names
#' @noRd
mod_download_server <- function(id, data_download, fn_no_ext, fct_create_excel, excel_args){
  moduleServer( id, function(input, output, session){
    ns <- session$ns

    ## Write Download Table
    # CSV
    output$csv_download <- downloadHandler(
      filename = function(vote) {
        paste0(fn_no_ext, ".csv")
      },
      content = function(file) {
        write.csv(data_download, file, fileEncoding = "UTF-8", row.names = FALSE, na = " ")
      }
    )

    # Excel
    output$excel_download <- downloadHandler(
      filename = function(vote) {
        paste0(fn_no_ext, ".xlsx")
      },
      content = function(file) {
        fct_create_excel(file, excel_args)
      }
    )

  })
}

## To be copied in the UI
# mod_download_ui("download_1")

## To be copied in the server
# mod_download_server("download_1")
