#!/usr/bin/env julia
using Gtk, Gtk.ShortNames

mutable struct TextModule
    name::AbstractString
    fileplace::AbstractString

    TextModule() = new("", "")
end

text = TextModule()


ui = Builder(filename=(@__DIR__) * "/ui.glade")
showall(ui["win"])

writetext!(textview::GtkTextView, s::AbstractString) = get_gtk_property(textview, :buffer, GtkTextBuffer) |> x -> set_gtk_property!(x, :text, s)
gettext(textview::GtkTextView) = get_gtk_property(textview, :buffer, GtkTextBuffer) |> x -> get_gtk_property(x, :text, AbstractString)

function file_new()
    textcontent = gettext(ui["textview"])
    if !isempty(textcontent)
        info_dialog("中身消しちゃったけど許してね!")
    end
    writetext!(ui["textview"], "")
    set_gtk_property!(ui["win"], :title, "")
    text.name, text.fileplace = "", ""

    return nothing
end

function file_open()
    text.fileplace = open_dialog("Open file", ui["win"], ("*.txt", "*",))
    if !isempty(text.fileplace)
        textcontent = open(io->read(io, String), text.fileplace)
        writetext!(ui["textview"], textcontent)
        text.name = split(text.fileplace, "/")[end]
        set_gtk_property!(ui["win"], :title, text.name)
    end

    return nothing
end

function file_save()
    if isempty(text.name)
        file_save_as()
    else
        textcontent = gettext(ui["textview"])
        write(text.fileplace, textcontent)
    end

    return nothing
end

function file_save_as()
    fileplace = save_dialog("Save file")
    if !isempty(fileplace)
        text.fileplace = fileplace
        textcontent = gettext(ui["textview"])
        write(text.fileplace, textcontent)
        text.name = split(text.fileplace, "/")[end]
        set_gtk_property!(ui["win"], :title, text.name)
    end

    return nothing
end


signal_connect((x,y)->file_new(), ui["file_new"], :activate, Nothing, (), false)
signal_connect((x,y)->file_open(), ui["file_open"], :activate, Nothing, (), false)
signal_connect((x,y)->file_save(), ui["file_save"], :activate, Nothing, (), false)
signal_connect((x,y)->file_save_as(), ui["file_save_as"], :activate, Nothing, (), false)
signal_connect((x,y)->exit(), ui["file_quit"], :activate, Nothing, (), false)

if !isinteractive()
    c = Condition()
    signal_connect(ui["win"], :destroy) do widget
        notify(c)
    end
    wait(c)
end
