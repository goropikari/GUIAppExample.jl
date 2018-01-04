#!/usr/bin/env julia
using Gtk, Gtk.ShortNames

ui = if isinteractive()
	Builder(filename="ui.glade")
else
	Builder(filename=dirname(PROGRAM_FILE) * "/ui.glade")
end
showall(ui["win"])

gettext(textview::GtkTextView) = getproperty(textview, :buffer, GtkTextBuffer) |> x -> getproperty(x, :text, AbstractString)

function eqn2val()
	s = replace(gettext(ui["eqn"]), "\n", ";")
	val = eval(parse(s))

	setproperty!(ui["resultent"], :text, val)

	return nothing
end

function reset_button()
	setproperty!(ui["resultent"], :text, "")

	return nothing
end

signal_connect(x -> eqn2val(), ui["cal"], "clicked")
signal_connect(x -> reset_button(), ui["reset"], "clicked")

if !isinteractive()
	c = Condition()
	signal_connect(ui["win"], :destroy) do widget
		notify(c)
	end
	wait(c)
end
