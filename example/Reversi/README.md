# Environment
- Julia 1.0
- Gtk.jl v0.16.4
- PackageCompiler v0.5.0


<img src="../../screenshots/reversi.gif" align="middle" />

# Building an executable

```bash
$ julia -e 'using PackageCompiler; build_executable("reversi_compile.jl", "reversi")'
$ builddir/reversi
```

**WARNING: There are many bugs in this reversi game. I only wanted to know how to handle combination PackageCompiler.jl with Gtk.jl.
 I don't plan to fix those bugs.**
