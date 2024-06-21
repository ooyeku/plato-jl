module DataFrameUtils

using Pkg
using Random

# Ensure required packages are installed
function ensure_packages_installed()
    packages = ["DataFrames", "Dates"]
    for pkg in packages
        if !haskey(Pkg.dependencies(), pkg)
            Pkg.add(pkg)
        end
    end
end


using DataFrames, Dates

# Turn a column of a DataFrame into a Date type with a specified format (by column name)
function make_date(df::DataFrame, col::String, format::String)
    df[!, col] = Date.(df[!, col], format)
    return df
end

# Turn a column of a DataFrame into a Date type with a specified format (by column index)
function make_date(df::DataFrame, col::Int, format::String, new_col::String)
    df[!, new_col] = Date.(df[!, col], format)
    return df
end

# Turn a column of a DataFrame into a Date type with a specified format (by column name, save as a new column)
function make_date(df::DataFrame, col::String, format::String, new_col::String)
    df[!, new_col] = Date.(df[!, col], format)
    return df
end

# Turn a column of a DataFrame into a Date type with a specified format (by Symbol)
function make_date(df::DataFrame, col::Symbol, format::String, new_col::Symbol)
    df[!, new_col] = Date.(df[!, col], format)
    return df
end

# Turn a column of a DataFrame into a Date type with a specified format (by column index)
function make_date(df::DataFrame, col::Int, format::String)
    df[!, col] = Date.(df[!, col], format)
    return df
end

# Create a new day of the week column from a date column (by column name)
function dayofweek(df::DataFrame, col::String)
    df[!, :dayofweek] = Dates.dayofweek.(df[!, col])
    return df
end

# Create a new day of the week column from a date column (by column index)
function dayofweek(df::DataFrame, col::Int)
    df[!, :dayofweek] = Dates.dayofweek.(df[!, col])
    return df
end

# Count missing rows in a column (by column name)
function count_missing(df::DataFrame, col::String)
    return sum(ismissing.(df[!, col]))
end

# Count missing rows in a column (by column index)
function count_missing(df::DataFrame, col::Int)
    return sum(ismissing.(df[!, col]))
end

# Count missing rows in a DataFrame
function count_missing(df::DataFrame)
    return sum(ismissing.(df))
end

# Remove rows with missing values (by column name)
function remove_missing(df::DataFrame, col::String)
    return df[.!ismissing.(df[!, col]), :]
end

# Remove rows with missing values (by column index)
function remove_missing(df::DataFrame, col::Int)
    return df[.!ismissing.(df[!, col]), :]
end

# Rename a column (by column name)
function rename_col(df::DataFrame, col::String, new_col::String)
    rename!(df, Symbol(col) => Symbol(new_col))
    return df
end

# Rename a column (by column index)
function rename_col(df::DataFrame, col::Int, new_col::String)
    rename!(df, Symbol(names(df)[col]) => Symbol(new_col))
    return df
end

# Shuffle observations in a DataFrame (reorganize row indexes)
function shuffle(df::DataFrame)
    return df[Random.shuffle(1:nrow(df)), :]
end

# Cut a DataFrame into two halves (by row index)
function cut_row(df::DataFrame, row1::Int, row2::Int)
    return df[1:row1, :], df[row2:end, :]
end

# Cut a DataFrame into two halves (automatically split in half, removes middle row if odd number of rows)
function cut_row(df::DataFrame)
    row1 = floor(Int, nrow(df) / 2)
    row2 = row1 + 1
    return df[1:row1, :], df[row2:end, :]
end

# Example usage in Plato
function example_usage()
    # Create a sample DataFrame
    df = DataFrame(DateColumn = ["2023-01-01", "2023-01-02", "2023-01-03"], Value = [10, 20, 30])

    # Convert DateColumn to Date type
    df = DataFrameUtils.make_date(df, "DateColumn", "yyyy-mm-dd")

    # Add a day of the week column
    df = DataFrameUtils.dayofweek(df, "DateColumn")

    # Count missing values in the Value column
    missing_count = DataFrameUtils.count_missing(df, "Value")
    println("Missing values in Value column: $missing_count")

    # Shuffle the DataFrame
    df = DataFrameUtils.shuffle(df)
    println("Shuffled DataFrame: \n$df")

    # Cut the DataFrame into two halves
    df1, df2 = DataFrameUtils.cut_row(df)
    println("First half of the DataFrame: \n$df1")
    println("Second half of the DataFrame: \n$df2")
end


end # module DataFrameUtils