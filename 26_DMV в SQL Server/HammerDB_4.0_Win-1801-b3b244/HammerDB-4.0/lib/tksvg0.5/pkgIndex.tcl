#
# Tcl package index file
#
#library requires 0.4 to load
package ifneeded tksvg 0.4 \
    [list load [file join $dir tksvg05t.dll] tksvg]
