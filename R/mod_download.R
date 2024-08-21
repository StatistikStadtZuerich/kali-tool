#' download UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
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
        outputId = ns("csvDownload"),
        label = "csv",
        image = img(ssz_icons$download)
      ),
      sszDownloadButton(
        outputId = ns("excelDownload"),
        label = "xlsx",
        image = img(ssz_icons$download)
      ),
      sszOgdDownload(
        outputId = ns("ogdDown"),
        label = "OGD",
        image = img(ssz_icons("link")),
        href = ogd_link
      )
    )

  )
}

#' download Server Functions
#'
#' @noRd
mod_download_server <- function(id, data_person, data_download){
  moduleServer( id, function(input, output, session){
    ns <- session$ns
    ## Write Download Table
    # CSV
    output$csvDownload <- downloadHandler(
      filename = function(vote) {
        suchfeld <- gsub(" ", "-", data_person()$Name, fixed = TRUE)
        paste0("Gemeinderatswahlen_", input$select_year, "_", suchfeld, ".csv")
      },
      content = function(file) {
        write.csv(data_download(), file, fileEncoding = "UTF-8", row.names = FALSE, na = " ")
      }
    )

    # Excel
    output$excelDownload <- downloadHandler(
      filename = function(vote) {
        suchfeld <- gsub(" ", "-", data_person()$Name, fixed = TRUE)
        paste0("Gemeinderatswahlen_", input$select_year, "_", suchfeld, ".xlsx")
      },
      content = function(file) {
        ssz_download_excel(
          data_download(),
          file,
          data_person()$Name
        )
      }
    )

  })
}

## To be copied in the UI
# mod_download_ui("download_1")

## To be copied in the server
# mod_download_server("download_1")
