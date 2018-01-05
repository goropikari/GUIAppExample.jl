#!/usr/bin/env julia
using Gtk, Gtk.ShortNames

mutable struct Text
    name::AbstractString
    fileplace::AbstractString

    Text() = new("", "")
end

text = Text()


ui = if isinteractive()
    Builder(filename="ui.glade")
else
    Builder(filename=dirname(PROGRAM_FILE) * "/ui.glade")
end
showall(ui["win"])

writetext!(textview::GtkTextView, s::AbstractString) = getproperty(textview, :buffer, GtkTextBuffer) |> x -> setproperty!(x, :text, s)
gettext(textview::GtkTextView) = getproperty(textview, :buffer, GtkTextBuffer) |> x -> getproperty(x, :text, AbstractString)

function file_new()
    textcontent = gettext(ui["textview"])
    if !isempty(textcontent)
        info_dialog("中身消しちゃったけど許してね!")
    end
    writetext!(ui["textview"], "")
    setproperty!(ui["win"], :title, "")
    text.name, text.fileplace = "", ""

    return nothing
end

function file_open()
    text.fileplace = open_dialog("Open file", ui["win"], ("*.txt", "*",))
    if !isempty(text.fileplace)
        textcontent = open(readstring, text.fileplace)
        writetext!(ui["textview"], textcontent)
        text.name = split(text.fileplace, "/")[end]
        setproperty!(ui["win"], :title, text.name)
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
        setproperty!(ui["win"], :title, text.name)
    end

    return nothing
end


signal_connect((x,y)->file_new(), ui["file_new"], :activate, Void, (), false)
signal_connect((x,y)->file_open(), ui["file_open"], :activate, Void, (), false)
signal_connect((x,y)->file_save(), ui["file_save"], :activate, Void, (), false)
signal_connect((x,y)->file_save_as(), ui["file_save_as"], :activate, Void, (), false)
signal_connect((x,y)->exit(), ui["file_quit"], :activate, Void, (), false)

if !isinteractive()
    c = Condition()
    signal_connect(ui["win"], :destroy) do widget
        notify(c)
    end
    wait(c)
end
