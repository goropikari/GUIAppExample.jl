module Hello

using Gtk

Base.@ccallable function julia_main(ARGS::Vector{String})::Cint
    win = GtkWindow("Count Click")
    v = GtkBox(:v)
    l = GtkLabel("You clicked 0 times.")
    b = GtkButton("Click!")
    push!(win, v)
    push!(v, l)
    push!(v, b)
    set_gtk_property!(v, :expand, l, true)

    # callback function
    global nclick = 0
    function click(x)
        nclick += 1
        set_gtk_property!(l, :label, "You clicked $(nclick) times.")
    end

    # connect button and function
    signal_connect(click, b, "clicked")
    showall(win)

    if !isinteractive()
        c = Condition()
        signal_connect(win, :destroy) do widget
            notify(c)
        end
        wait(c)
    end

    return 0
end

end
