module Plato

include("plato/file_io.jl")
include("plato/r_utils.jl")
include("plato/dataframe_utils.jl")
include("plato/data_generator.jl")
include("plato/sqlite_helper.jl")
include("plato/query_builder.jl")
include("plato/qual.jl")
include("plato/quant.jl")
include("plato/visualization.jl")
include("plato/clean.jl")
include("plato/ml.jl")
include("plato/report.jl")
include("plato/project.jl")

using .FileIO
using .RUtils
using .DataFrameUtils
using .DataGen
using .SQLiteHelper
using .QueryBuilder: Query
using .Qual
using .Quant
using .Visualization
using .DataCleaning
using .MachineLearning
using Statistics
using .QueryBuilder: Query, from, select, where, limit, order_by, or_, and_, build
using BenchmarkTools
using .Report
using .Project
using Plots: plot, savefig

export DataGen, DataFrameUtils, FileIO, RUtils, SQLiteHelper, QueryBuilder, Qual, Quant, Visualization, DataCleaning, MachineLearning, Report, Project

function show_environment()
    for name in names(Main)
        if name != :show_environment
            println("$name: $(getfield(Main, name))")
        end
    end
end

function show_packages()
    for name in names(Main)
        if name != :show_packages
            println("$name: $(getfield(Main, name))")
        end
    end
end

function show_memory_usage()
    println("Memory usage: $(round(Sys.total_memory() - Sys.free_memory(), digits=2)) MB")
end

# Example of a higher-level function that uses multiple modules
function example_high_level_function()
    @btime begin
    println("Example high-level function using multiple modules")

    # Create a new project
    project = Project.create_project("example_project")
    println("Project created at: $(Project.get_project_path(project))")

    # Generate some data
    gen = DataGen.create_data_generator(1_000)
    DataGen.add_column!(gen, :age, "age")
    DataGen.add_column!(gen, :Text, "text", options=Dict(:max_chars=>20))  # Add a Text column
    df = DataGen.generate(gen)
    println("Generated DataFrame:\n$df")

    # Save the data to a CSV file within the project directory
    Project.save_project_file(project, df, "example_data.csv")

    # Load the data back from the project directory
    loaded_df = Project.load_project_file(project, "example_data.csv")
    println("Loaded DataFrame:\n$loaded_df")

    # Ensure the DateColumn exists before manipulating it
    if "DateColumn" in names(loaded_df)
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

    # Create a database within the project directory
    db = Project.create_project_database(project, "example.db")
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
    SQLiteHelper.delete_db_file(joinpath(Project.get_project_path(project), "example.db"))
    println("Database connection closed and file deleted.")

    # Generate a report within the project directory
    report = Report.create_report_generator()
    Report.add_note!(report, "Generated data and performed analysis.")
    Report.add_analysis!(report, "Descriptive statistics:\n$stats")
    Report.add_analysis!(report, "Text summary:\n$text_summary")
    plot_path = joinpath(Project.get_project_path(project), "example_plot.png")
    plot(df.age, title="Age Distribution", xlabel="Index", ylabel="Age")
    savefig(plot_path)
    Report.add_plot!(report, plot_path)
    Project.generate_project_report(project, report, :html)
    Project.generate_project_report(project, report, :markdown)
    end
end

end # module Plato
