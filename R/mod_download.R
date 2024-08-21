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
#' @param info_single_candidate list with two data.frames named data_person and data_download; both are reactive
#' @param fn_no_ext Filename to be used for excel and csv download without extension
#' @noRd
mod_download_server <- function(id, info_single_candidate, fn_no_ext){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    ## Write Download Table
    # CSV
    output$csv_download <- downloadHandler(
      filename = function(vote) {
        paste0(fn_no_ext, ".csv")
      },
      content = function(file) {
        write.csv(info_single_candidate$data_download(), file, fileEncoding = "UTF-8", row.names = FALSE, na = " ")
      }
    )

    # Excel
    output$excel_download <- downloadHandler(
      filename = function(vote) {
        paste0(fn_no_ext, ".xlsx")
      },
      content = function(file) {
        ssz_download_excel(
          info_single_candidate$data_download(),
          file,
          info_single_candidate$data_person()$Name
        )
      }
    )

  })
}

## To be copied in the UI
# mod_download_ui("download_1")

## To be copied in the server
# mod_download_server("download_1")
