# ========= Build argument =========
ARG R_VERSION

# multi-stage build

# =========================
# Stage 1: Build + Test
# =========================
FROM rocker/geospatial:${R_VERSION} AS builder

# Must be root so pak can install system dependencies
USER root

# Install pak
RUN R -q -e "install.packages(c('pak', 'renv'))"

WORKDIR /app

# Copy only lockfile first (better caching), DESCRIPTION needed for pak to identify system requirements
COPY DESCRIPTION DESCRIPTION
COPY renv.lock renv.lock

# Install R packages AND system dependencies from lockfile
# first need to create a pak-compatible lockfile
RUN R -q -e "renv::restore()"
RUN R -q -e "pak::pkg_sysreqs('.')"

# Copy full source for tests and install
COPY . /pkg

# install package (we already have the dependencies)
RUN R -q -e "pak::local_install(dependencies = FALSE)"

# Run tests (fail on error)
RUN R -q -e "testthat::test_local(reporter = testthat::check_reporter())"
#RUN R -q -e "Sys.setenv(CI='true'); setwd('/pkg'); devtools::test()"


# =========================
# Stage 2: Runtime
# =========================
FROM rocker/geospatial:${R_VERSION} AS runtime

# Use non-root user for runtime
USER rstudio

WORKDIR /app

# Copy installed R libraries from builder
COPY --from=builder /usr/local/lib/R /usr/local/lib/R

# Copy runtime files only (no source/tests)
COPY inst/ /inst/

EXPOSE 3838

CMD R -q -e "options(shiny.port=3838, shiny.host='0.0.0.0'); library(KALI); KALI::run_app()"

