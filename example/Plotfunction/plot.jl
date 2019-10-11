# script for PackageCompiler.jl

module Hello

using Gtk, Gtk.ShortNames, Plots, Random
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

Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
	gr(legend=false)

	outputdir = joinpath(tempdir(),"juliaplot" * randstring())
	mkdir(outputdir)
	filename = joinpath(outputdir, "plot.png")

	ui = Builder(filename=joinpath(@__DIR__, "ui.glade"))

	if isinteractive()
		set_gtk_property!(ui["preview"], :file, "Julia_prog_language_logo.svg")
	else
		set_gtk_property!(ui["preview"], :file, joinpath(dirname(PROGRAM_FILE), "Julia_prog_language_logo.svg"))
	end

	showall(ui["win"])

	# mutable struct Variables
	# 	eqn::String
	# 	x::String
	# 	xs::Float64
	# 	xf::Float64
	# 	y::String
	# 	ys::Float64
	# 	yf::Float64
	# 	t::String
	# 	ts::Float64
	# 	tf::Float64
	# 	xlog::Bool
	# 	ylog::Bool
	# end


	variables = Variables(get_gtk_property(ui["eqn"], :text, String),
			  get_gtk_property(ui["x"], :text, String),
			  eval(Meta.parse(get_gtk_property(ui["xs"], :text, String))),
			  eval(Meta.parse(get_gtk_property(ui["xf"], :text, String))),
			  get_gtk_property(ui["y"], :text, String),
			  eval(Meta.parse(get_gtk_property(ui["ys"], :text, String))),
			  eval(Meta.parse(get_gtk_property(ui["yf"], :text, String))),
			  get_gtk_property(ui["t"], :text, String),
			  eval(Meta.parse(get_gtk_property(ui["ts"], :text, String))),
			  eval(Meta.parse(get_gtk_property(ui["tf"], :text, String))),
			  get_gtk_property(ui["xlog"], :active, Bool),
			  get_gtk_property(ui["ylog"], :active, Bool))

	function update_variables()
		variables.eqn = get_gtk_property(ui["eqn"], :text, String)
		variables.x = get_gtk_property(ui["x"], :text, String)
		variables.xs = eval(Meta.parse(get_gtk_property(ui["xs"], :text, String)))
		variables.xf = eval(Meta.parse(get_gtk_property(ui["xf"], :text, String)))
		variables.y = get_gtk_property(ui["y"], :text, String)
		variables.ys = eval(Meta.parse(get_gtk_property(ui["ys"], :text, String)))
		variables.yf = eval(Meta.parse(get_gtk_property(ui["yf"], :text, String)))
		variables.t = get_gtk_property(ui["t"], :text, String)
		variables.ts = eval(Meta.parse(get_gtk_property(ui["ts"], :text, String)))
		variables.tf = eval(Meta.parse(get_gtk_property(ui["tf"], :text, String)))
		variables.xlog = get_gtk_property(ui["xlog"], :active, Bool)
		variables.ylog = get_gtk_property(ui["ylog"], :active, Bool)

		return nothing
	end

	function plot_option!()
		plot!(title=get_gtk_property(ui["title"], :text, String))
		plot!(xlabel=get_gtk_property(ui["xlabel"], :text, String))
		plot!(ylabel=get_gtk_property(ui["ylabel"], :text, String))
		plot!(zlabel=get_gtk_property(ui["zlabel"], :text, String))
		if variables.xlog
			plot!(xscale=:log10)
		end
		if variables.ylog
			plot!(yscale=:log10)
		end
	end

	function genfn_single()
		if occursin("=", variables.eqn)
			eqn = split(variables.eqn, "=")[2]
		else
			eqn = variables.eqn
		end
		f = eval(Meta.parse(variables.x * "->" * eqn))

		return f
	end

	function genfn_double()
		x = variables.xs:variables.xf
		y = variables.ys:variables.yf
		if occursin("=", variables.eqn)
			eqn = split(variables.eqn, "=")[2]
		else
			eqn = variables.eqn
		end
		f = eval(Meta.parse( "(" * variables.x * "," * variables.y * ")" * "->" * eqn))

		return x, y, f
	end

	function genfn_para()
		if length(split(variables.eqn, ",")) == 2
			de = split(variables.eqn, ",")
			if occursin("=", de[1])
				e1 = split(de[1], "=")[2]
			else
				e1 = de[1]
			end

			if occursin("=", de[2])
				e2 = split(de[2], "=")[2]
			else
				e2 = de[2]
			end

			f = eval(Meta.parse(variables.t * "->" * e1))
			g = eval(Meta.parse(variables.t * "->" * e2))

			return f, g
		else
			de = split(variables.eqn, ",")
			if occursin("=", de[1])
				e1 = split(de[1], "=")[2]
			else
				e1 = de[1]
			end

			if occursin("=", de[2])
				e2 = split(de[2], "=")[2]
			else
				e2 = de[2]
			end

			if occursin("=", de[3])
				e3 = split(de[3], "=")[2]
			else
				e3 = de[3]
			end

			f = eval(Meta.parse(variables.t * "->" * e1))
			g = eval(Meta.parse(variables.t * "->" * e2))
			h = eval(Meta.parse(variables.t * "->" * e3))

			return f, g, h
		end
	end



	function plot2d_button()
		update_variables()
		f = genfn_single()
		plot(x-> Base.invokelatest(f,x), variables.xs, variables.xf)
		plot_option!()
		savefig(filename)

		set_gtk_property!(ui["preview"], :file, filename)
		println("plot 2d function")

		return nothing
	end


	function contour_button()
		update_variables()
		x, y, f = genfn_double()
		contour(x, y, (x,y) -> Base.invokelatest(f, x, y), fill=true, colorbar=true)
		plot_option!()
		savefig(filename)

		set_gtk_property!(ui["preview"], :file, filename)
		println("contour")

		return nothing
	end

	function para2d_button()
		update_variables()
		f, g = genfn_para()
		plot(t1 -> Base.invokelatest(f,t1), t2 -> Base.invokelatest(g,t2), variables.ts, variables.tf)
		plot_option!()
		savefig(filename)
		set_gtk_property!(ui["preview"], :file, filename)
		println("parametric function 2d")

		return nothing
	end

	function plot3d_button()
		update_variables()
		x, y, f = genfn_double()
		surface(x, y, (x,y) -> Base.invokelatest(f, x, y))
		plot_option!()
		savefig(filename)

		set_gtk_property!(ui["preview"], :file, filename)
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
		set_gtk_property!(ui["preview"], :file, filename)
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

    return 0
end

end
