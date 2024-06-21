module Plato

include("plato/file_io.jl")
include("plato/r_utils.jl")
include("plato/dataframe_utils.jl")
include("plato/data_generator.jl")
include("plato/sqlite_helper.jl")
include("plato/query_builder.jl")
include("plato/qual.jl")
include("plato/quant.jl")

using .FileIO
using .RUtils
using .DataFrameUtils
using .DataGen
using .SQLiteHelper
using .QueryBuilder: Query
using .Qual
using .Quant
using Statistics
using .QueryBuilder: Query, from, select, where, limit, order_by, or_, and_, build
using BenchmarkTools

export DataGen, DataFrameUtils, FileIO, RUtils, SQLiteHelper, QueryBuilder, Qual, Quant

# Example of a higher-level function that uses multiple modules
function example_high_level_function()
    @btime begin
    println("Example high-level function using multiple modules")

    # Generate some data
    gen = DataGen.create_data_generator(1_000)
    DataGen.add_column!(gen, :age, "age")
    DataGen.add_column!(gen, :Text, "text", options=Dict(:max_chars=>20))  # Add a Text column
    df = DataGen.generate(gen)
    println("Generated DataFrame:\n$df")

    # Save the data to a CSV file
    FileIO.save(df, "example_data.csv")
    println("Data saved to example_data.csv")

    # Load the data back
    loaded_df = FileIO.load("example_data.csv")
    println("Loaded DataFrame:\n$loaded_df")

    # Ensure the DateColumn exists before manipulating it
    if "DateColumn" in names(loaded_df)
        # Perform some data manipulation
        df = DataFrameUtils.make_date(loaded_df, "DateColumn", "yyyy-mm-dd")
        df = DataFrameUtils.dayofweek(df, "DateColumn")
        println("DataFrame with date manipulation:\n$df")
    else
        println("DateColumn not found in the DataFrame.")
    end

    # Perform some statistical analysis
    stats = Quant.describe_df(df)
    println("Descriptive statistics:\n$stats")

    # Perform some text analysis
    text_summary = Qual.text_summary(df, :Text)
    println("Text summary:\n$text_summary")

    # Build and execute a SQL query
    db = SQLiteHelper.create_database("example.db")
    SQLiteHelper.create_table(db, "people", Dict("id" => "INTEGER PRIMARY KEY", "name" => "TEXT", "age" => "INTEGER"))
    query = Query()
    queries = [
        (build(from(select(Query(), "*"), "people")), 
         "Select all people:"),
        (build(where(from(select(Query(), "name", "age"), "people"), "age > 30")), 
         "Select people over 30:"),
        (build(limit(order_by(from(select(Query(), "name"), "people"), "age DESC"), 3)), 
         "Select top 3 oldest people:"),
        (build(from(select(Query(), "AVG(age) as avg_age"), "people")), 
         "Calculate average age:"),
        (build(or_(where(from(select(Query(), "name"), "people"), "age < 30"), "age > 40")), 
         "Select people younger than 30 or older than 40:")
    ]

    # Execute and display results for each query
    for (sql, description) in queries
        println("\n$description")
        println("SQL: $sql")
        result = SQLiteHelper.query_to_dataframe(db, sql)
        println(result)
    end
    query = QueryBuilder.build(QueryBuilder.from(QueryBuilder.select(query, "*"), "people"))

    result = SQLiteHelper.query_to_dataframe(db, query)
    println("SQL query result:\n$result")
    # Clean up
    SQLiteHelper.DBInterface.close!(db)
        SQLiteHelper.delete_db_file("example.db")
        println("Database connection closed and file deleted.")
    end
end

end # module Plato
