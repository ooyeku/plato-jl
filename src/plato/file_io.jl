module FileIO

using Pkg
using CSV, DataFrames, JSONTables, XLSX, Feather

# Ensure required packages are installed
function ensure_packages_installed()
    packages = ["CSV", "DataFrames", "JSONTables", "XLSX", "Feather"]
    for pkg in packages
        if !haskey(Pkg.dependencies(), pkg)
            Pkg.add(pkg)
        end
    end
end

# Load a file into a DataFrame
function load(filename::String; sheet::String="Sheet1")
    try
        if endswith(filename, ".csv")
            return CSV.read(filename, DataFrame)
        elseif endswith(filename, ".json")
            return DataFrame(JSONTables.jsontable(filename))
        elseif endswith(filename, ".xlsx")
            return DataFrame(XLSX.readtable(filename, sheet)...)
        elseif endswith(filename, ".feather")
            return Feather.read(filename)
        else
            error("Unsupported file type: $filename")
        end
    catch e
        error("Error reading file $filename: $e")
    end
end

# Save a DataFrame to a file
function save(data::DataFrame, filename::String; sheet::String="Sheet1")
    try
        if endswith(filename, ".csv")
            CSV.write(filename, data)
        elseif endswith(filename, ".json")
            open(filename, "w") do io
                JSONTables.write(io, data)
            end
        elseif endswith(filename, ".xlsx")
            XLSX.writetable(filename, DataFrames.Table(data); sheet=sheet)
        elseif endswith(filename, ".feather")
            Feather.write(filename, data)
        else
            error("Unsupported file type: $filename")
        end
    catch e
        error("Error saving file $filename: $e")
    end
end

end # module FileIO
