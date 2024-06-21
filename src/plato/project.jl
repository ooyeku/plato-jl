module Project

include("file_io.jl")
include("sqlite_helper.jl")
include("report.jl")

using .FileIO
using .SQLiteHelper
using .Report
using DataFrames
using Plots
using ..Report: ReportGenerator, save_report

const PROJECT_PREFIX = "project-"

struct ProjectStruct
    name::String
    path::String
end

function create_project(name::String)
    project_name = PROJECT_PREFIX * name
    project_path = joinpath(pwd(), project_name)
    if !isdir(project_path)
        mkpath(project_path)
    end
    return ProjectStruct(project_name, project_path)
end

function get_project_path(project::ProjectStruct)
    return project.path
end

function save_project_file(project::ProjectStruct, data::DataFrame, filename::String)
    file_path = joinpath(project.path, filename)
    FileIO.save(data, file_path)
    println("Data saved to $file_path")
end

function load_project_file(project::ProjectStruct, filename::String)
    file_path = joinpath(project.path, filename)
    return FileIO.load(file_path)
end

function create_project_database(project::ProjectStruct, db_name::String)
    db_path = joinpath(project.path, db_name)
    return SQLiteHelper.create_database(db_path)
end

function generate_project_report(project::ProjectStruct, report::ReportGenerator, format::Symbol=:html)
    report_path = joinpath(project.path, "report.$(string(format))")
    save_report(report, report_path, format)
    println("Report saved to $report_path")
end

end # module Project