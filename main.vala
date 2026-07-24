int corner_radius = 16;

void draw_corner (Cairo.Context cr, double x0, double y0, double cx, double cy, double r) {
    cr.save ();
    cr.rectangle (x0, y0, r, r);
    cr.clip ();

    cr.set_operator (Cairo.Operator.SOURCE);
    cr.set_source_rgba (0, 0, 0, 1);
    cr.paint ();

    cr.set_operator (Cairo.Operator.CLEAR);
    cr.arc (cx, cy, r, 0, 2 * Math.PI);
    cr.fill ();

    cr.restore ();
}

bool on_draw (Gtk.Widget widget, Cairo.Context cr) {
    double w = widget.get_allocated_width ();
    double h = widget.get_allocated_height ();
    double r = (double) corner_radius;

    cr.set_operator (Cairo.Operator.SOURCE);
    cr.set_source_rgba (0, 0, 0, 0);
    cr.paint ();

    draw_corner (cr, 0, 0, r, r, r);
    draw_corner (cr, w - r, 0, w - r, r, r);
    draw_corner (cr, 0, h - r, r, h - r, r);
    draw_corner (cr, w - r, h - r, w - r, h - r, r);

    return false;
}

const OptionEntry[] options = {
    { "radius", 'r', 0, OptionArg.INT, ref corner_radius, "Corner radius in pixels", "RADIUS" },
    { null }
};

int main (string[] args) {
    // Parse command line arguments using GLib.OptionContext
    try {
        var opt_context = new OptionContext ("- Rounded Screen Corners");
        opt_context.set_help_enabled (true);
        opt_context.add_main_entries (options, null);
        opt_context.parse (ref args);
    } catch (OptionError e) {
        stderr.printf ("Error parsing arguments: %s\n", e.message);
        return 1;
    }

    Gtk.init (ref args);

    var win = new Gtk.Window ();
    win.set_decorated (false);
    win.app_paintable = true;

    Gdk.Screen screen = win.get_screen ();
    Gdk.Visual? visual = screen.get_rgba_visual ();
    if (visual != null) {
        win.set_visual (visual);
    } else {
        stderr.printf ("warning: no rgba visual available.\n");
    }

    GtkLayerShell.init_for_window (win);
    GtkLayerShell.set_namespace (win, "screen-corners");
    GtkLayerShell.set_layer (win, GtkLayerShell.Layer.OVERLAY);
    GtkLayerShell.set_exclusive_zone (win, -1);
    GtkLayerShell.set_anchor (win, GtkLayerShell.Edge.TOP, true);
    GtkLayerShell.set_anchor (win, GtkLayerShell.Edge.BOTTOM, true);
    GtkLayerShell.set_anchor (win, GtkLayerShell.Edge.LEFT, true);
    GtkLayerShell.set_anchor (win, GtkLayerShell.Edge.RIGHT, true);

    var area = new Gtk.DrawingArea ();
    area.set_hexpand (true);
    area.set_vexpand (true);
    area.draw.connect (on_draw);
    win.add (area);

    win.map_event.connect (() => {
      Gdk.Window? gdk_win = win.get_window ();
        if (gdk_win != null) {
          var empty_region = new Cairo.Region ();
          gdk_win.input_shape_combine_region (empty_region, 0, 0);
        }
        return false;
    }); 

    win.destroy.connect (Gtk.main_quit);
    win.show_all ();
    Gtk.main ();

    return 0;
}
