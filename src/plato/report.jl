module Report

using DataFrames
using Plots
using Markdown

export ReportGenerator, create_report_generator, add_note!, add_analysis!, add_plot!, generate_report, save_report

struct ReportGenerator
    notes::Vector{String}
    analyses::Vector{String}
    plots::Vector{String}
end

function create_report_generator()
    return ReportGenerator(String[], String[], String[])
end

function add_note!(report::ReportGenerator, note::String)
    push!(report.notes, note)
end

function add_analysis!(report::ReportGenerator, analysis::String)
    push!(report.analyses, analysis)
end

function add_plot!(report::ReportGenerator, plot_path::String)
    push!(report.plots, plot_path)
end

function generate_report(report::ReportGenerator, format::Symbol=:html)
    if format == :html
        return generate_html_report(report)
    elseif format == :markdown
        return generate_markdown_report(report)
    else
        error("Unsupported format: $format")
    end
end

function generate_html_report(report::ReportGenerator)
    html = "<html><body>"
    html *= "<h1>Report</h1>"
    
    html *= "<h2>Notes</h2><ul>"
    for note in report.notes
        html *= "<li>$note</li>"
    end
    html *= "</ul>"
    
    html *= "<h2>Analyses</h2><ul>"
    for analysis in report.analyses
        html *= "<li>$analysis</li>"
    end
    html *= "</ul>"
    
    html *= "<h2>Plots</h2>"
    for plot in report.plots
        html *= "<img src=\"$plot\" alt=\"Plot\">"
    end
    
    html *= "</body></html>"
    return html
end

function generate_markdown_report(report::ReportGenerator)
    md = "# Report\n"
    
    md *= "## Notes\n"
    for note in report.notes
        md *= "- $note\n"
    end
    
    md *= "## Analyses\n"
    for analysis in report.analyses
        md *= "- $analysis\n"
    end
    
    md *= "## Plots\n"
    for plot in report.plots
        md *= "![Plot]($plot)\n"
    end
    
    return md
end

function save_report(report::ReportGenerator, filename::String, format::Symbol=:html)
    content = generate_report(report, format)
    open(filename, "w") do file
        write(file, content)
    end
end

function example_usage()
    report = create_report_generator()
    
    add_note!(report, "This is a note about the data.")
    add_analysis!(report, "The average age is 35.")
    
    # Generate a sample plot
    df = DataFrame(x=1:10, y=rand(10))
    plot_path = "plot.png"
    plot(df.x, df.y, title="Sample Plot", xlabel="X", ylabel="Y")
    savefig(plot_path)
    add_plot!(report, plot_path)
    
    html_report = generate_report(report, :html)
    println("HTML Report:\n$html_report")
    
    markdown_report = generate_report(report, :markdown)
    println("Markdown Report:\n$markdown_report")
    
    # Save reports to files
    save_report(report, "report.html", :html)
    save_report(report, "report.md", :markdown)
end

end # module Report