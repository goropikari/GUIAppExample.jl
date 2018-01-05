#!/usr/bin/env julia
using Gtk, Gtk.ShortNames, Plots
gr(legend=false)

outputdir = tempdir() * "/juliaplot" * randstring()
mkdir(outputdir)
filename = outputdir * "/plot.png"

ui = if isinteractive()
    Builder(filename="ui.glade")
else
    Builder(filename=dirname(PROGRAM_FILE) * "/ui.glade")
end

if isinteractive()
    setproperty!(ui["preview"], :file, "Julia_prog_language_logo.svg")
else
    setproperty!(ui["preview"], :file, dirname(PROGRAM_FILE) * "/Julia_prog_language_logo.svg")
end

showall(ui["win"])

mutable struct Variables
    eqn::String
	x::String
	xs::Float64
	xf::Float64
	y::String
    ys::Float64
    yf::Float64
    t::String
    ts::Float64
    tf::Float64
    xlog::Bool
    ylog::Bool
end


variables = Variables(getproperty(ui["eqn"], :text, String),
          getproperty(ui["x"], :text, String),
          eval(parse(getproperty(ui["xs"], :text, String))),
          eval(parse(getproperty(ui["xf"], :text, String))),
          getproperty(ui["y"], :text, String),
          eval(parse(getproperty(ui["ys"], :text, String))),
          eval(parse(getproperty(ui["yf"], :text, String))),
          getproperty(ui["t"], :text, String),
          eval(parse(getproperty(ui["ts"], :text, String))),
          eval(parse(getproperty(ui["tf"], :text, String))),
          getproperty(ui["xlog"], :active, Bool),
          getproperty(ui["ylog"], :active, Bool))

function update_variables()
    variables.eqn = getproperty(ui["eqn"], :text, String)
    variables.x = getproperty(ui["x"], :text, String)
    variables.xs = eval(parse(getproperty(ui["xs"], :text, String)))
    variables.xf = eval(parse(getproperty(ui["xf"], :text, String)))
    variables.y = getproperty(ui["y"], :text, String)
    variables.ys = eval(parse(getproperty(ui["ys"], :text, String)))
    variables.yf = eval(parse(getproperty(ui["yf"], :text, String)))
    variables.t = getproperty(ui["t"], :text, String)
    variables.ts = eval(parse(getproperty(ui["ts"], :text, String)))
    variables.tf = eval(parse(getproperty(ui["tf"], :text, String)))
    variables.xlog = getproperty(ui["xlog"], :active, Bool)
    variables.ylog = getproperty(ui["ylog"], :active, Bool)

    return nothing
end

function plot_option!()
    plot!(title=getproperty(ui["title"], :text, String))
    plot!(xlabel=getproperty(ui["xlabel"], :text, String))
    plot!(ylabel=getproperty(ui["ylabel"], :text, String))
    plot!(zlabel=getproperty(ui["zlabel"], :text, String))
    if variables.xlog
        plot!(xscale=:log10)
    end
    if variables.ylog
        plot!(yscale=:log10)
    end
end

function genfn_single()
     if contains(variables.eqn, "=")
        eqn = split(variables.eqn, "=")[2]
    else
        eqn = variables.eqn
    end
    f = eval(parse(variables.x * "->" * eqn))

    return f
end

function genfn_double()
    x = variables.xs:variables.xf
    y = variables.ys:variables.yf
    if contains(variables.eqn, "=")
        eqn = split(variables.eqn, "=")[2]
    else
        eqn = variables.eqn
    end
    f = eval(parse( "(" * variables.x * "," * variables.y * ")" * "->" * eqn))

    return x, y, f
end

function genfn_para()
    if length(split(variables.eqn, ",")) == 2
        de = split(variables.eqn, ",")
        if contains(de[1], "=")
            e1 = split(de[1], "=")[2]
        else
            e1 = de[1]
        end

        if contains(de[2], "=")
            e2 = split(de[2], "=")[2]
        else
            e2 = de[2]
        end

        f = eval(parse(variables.t * "->" * e1))
        g = eval(parse(variables.t * "->" * e2))

        return f, g
    else
        de = split(variables.eqn, ",")
        if contains(de[1], "=")
            e1 = split(de[1], "=")[2]
        else
            e1 = de[1]
        end

        if contains(de[2], "=")
            e2 = split(de[2], "=")[2]
        else
            e2 = de[2]
        end

        if contains(de[3], "=")
            e3 = split(de[3], "=")[2]
        else
            e3 = de[3]
        end

        f = eval(parse(variables.t * "->" * e1))
        g = eval(parse(variables.t * "->" * e2))
        h = eval(parse(variables.t * "->" * e3))

        return f, g, h
    end
end



function plot2d_button()
    update_variables()
    f = genfn_single()
    plot(x-> Base.invokelatest(f,x), variables.xs, variables.xf)
    plot_option!()
    savefig(filename)

    setproperty!(ui["preview"], :file, filename)
    println("plot 2d function")

    return nothing
end


function contour_button()
    update_variables()
    x, y, f = genfn_double()
    contour(x, y, (x,y) -> Base.invokelatest(f, x, y), fill=true, colorbar=true)
    plot_option!()
    savefig(filename)

    setproperty!(ui["preview"], :file, filename)
    println("contour")

    return nothing
end

function para2d_button()
    update_variables()
    f, g = genfn_para()
    plot(t1 -> Base.invokelatest(f,t1), t2 -> Base.invokelatest(g,t2), variables.ts, variables.tf)
    plot_option!()
    savefig(filename)
    setproperty!(ui["preview"], :file, filename)
    println("parametric function 2d")

    return nothing
end

function plot3d_button()
    update_variables()
    x, y, f = genfn_double()
    surface(x, y, (x,y) -> Base.invokelatest(f, x, y))
    plot_option!()
    savefig(filename)

    setproperty!(ui["preview"], :file, filename)
    println("plot 3d function")

    return nothing
end

function para3d_button()
    update_variables()
    f, g, h = genfn_para()
    plot3d(t -> Base.invokelatest(f,t),
         t -> Base.invokelatest(g,t),
         t -> Base.invokelatest(h,t),
         variables.ts, variables.tf)
    plot_option!()
    savefig(filename)
    setproperty!(ui["preview"], :file, filename)
    println("parametric function 3d")

    return nothing
end


function savefig_button()
    dstname = save_dialog("Save figure")
    cp(filename, dstname, remove_destination=true)

    return nothing
end

signal_connect(x -> plot2d_button(), ui["plot2d"], "clicked")
signal_connect(x -> contour_button(), ui["contour"], "clicked")
signal_connect(x -> para2d_button(), ui["para2d"], "clicked")
signal_connect(x -> plot3d_button(), ui["plot3d"], "clicked")
signal_connect(x -> para3d_button(), ui["para3d"], "clicked")
signal_connect(x -> savefig_button(), ui["savefig"], "clicked")

if !isinteractive()
    c = Condition()
    signal_connect(ui["win"], :destroy) do widget
        notify(c)
    end
    wait(c)
end
