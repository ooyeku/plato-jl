module RUtils

using Pkg

# Ensure required packages are installed
function ensure_packages_installed()
    packages = ["RCall", "StatsBase", "DataFrames", "CSV"]
    for pkg in packages
        if !haskey(Pkg.dependencies(), pkg)
            Pkg.add(pkg)
        end
    end
end


using RCall, StatsBase, DataFrames, CSV

export load_iris, load_mtcars, load_diamonds, load_mpg, load_txhousing, load_economics, load_midwest, 
       rsummary, tabyl_r, tabyl_j, colnames_r, colnames_j, coltypes_r, coltypes_j, nrow_r, nrow_j, 
       ncol_r, ncol_j, ggplot_r, install_tidyverse, install_janitor, load_tidyverse, load_janitor, loadggplot2

# Install tidyverse
function install_tidyverse()
    R"""install.packages('tidyverse', repos='http://cran.us.r-project.org')"""
end

# Install janitor
function install_janitor()
    R"""install.packages('janitor', repos='http://cran.us.r-project.org')"""
end

# Load tidyverse package
function load_tidyverse()
    R"""library(tidyverse)"""
end

# Load janitor package
function load_janitor()
    R"""library(janitor)"""
end

# Load ggplot2 package
function loadggplot2()
    R"""library(ggplot2)"""
end

# Load iris dataset
function load_iris()
    R"""df <- iris"""
    iris = @rget df
    return iris
end

# Load mtcars dataset
function load_mtcars()
    R"""df <- mtcars"""
    mtcars = @rget df
    return mtcars
end

# Load diamonds dataset
function load_diamonds()
    R"""library(ggplot2)"""
    R"""df <- diamonds"""
    diamonds = @rget df
    return diamonds
end

# Load mpg dataset
function load_mpg()
    R"""df <- mpg"""
    mpg = @rget df
    return mpg
end

# Load txhousing dataset
function load_txhousing()
    R"""df <- txhousing"""
    txhousing = @rget df
    return txhousing
end

# Load economics dataset
function load_economics()
    R"""df <- economics"""
    economics = @rget df
    return economics
end

# Load midwest dataset
function load_midwest()
    R"""df <- midwest"""
    midwest = @rget df
    return midwest
end

# Summarize with R summary
function rsummary(dataset)
    R"""summary($dataset)"""
end

# Wrapper for tabyl
function tabyl_r(dataset, colindex = 1)
    R"""tabyl($dataset[[$colindex]])"""
end

function tabyl_j(dataset, colindex = 1)
    R"""t <- tabyl($dataset[[$colindex]])"""
    t = @rget t
end

# Check column names
function colnames_r(dataset)
    R"""colnames($dataset)"""
end

function colnames_j(dataset)
    R"""c <- colnames($dataset)"""
    c = @rget c
end

# Check column types
function coltypes_r(dataset)
    R"""sapply($dataset, class)"""
end

function coltypes_j(dataset)
    R"""c <- sapply($dataset, class)"""
    c = @rget c
end

# Count number of rows
function nrow_r(dataset)
    R"""nrow($dataset)"""
end

function nrow_j(dataset)
    R"""n <- nrow($dataset)"""
    n = @rget n
end

# Count number of columns
function ncol_r(dataset)
    R"""ncol($dataset)"""
end

function ncol_j(dataset)
    R"""n <- ncol($dataset)"""
    n = @rget n
end

# Wrapper for ggplot
function ggplot_r(dataset, x, y)
    R"""ggplot($dataset, aes(x = $x, y = $y)) + geom_point()"""
end

# Example usage in Plato
function example_usage()
    # Install and load necessary R packages
    RUtils.install_tidyverse()
    RUtils.load_tidyverse()
    RUtils.install_janitor()
    RUtils.load_janitor()
    RUtils.loadggplot2()

    # Load a dataset
    iris_df = RUtils.load_iris()
    println("Iris dataset:\n$iris_df")

    # Get summary statistics
    println("Summary of iris dataset:")
    RUtils.rsummary(iris_df)

    # Get column names
    colnames = RUtils.colnames_j(iris_df)
    println("Column names of iris dataset:\n$colnames")

    # Plot using ggplot
    RUtils.ggplot_r(iris_df, "Sepal.Length", "Sepal.Width")
end

end # module RUtils