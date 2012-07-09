module CPGraphBuilder

  PALETTE_INDEX = 3

  def build(inputstream, output_path)
    rdata = Rdata.new
    set_axes_names(rdata)
    x_points, y_points = get_graph_points(inputstream)
    write_graph(rdata, x_points, y_points, output_path)
  end

  def set_axes_names(rdata)
    raise "Implement abstract method set_axes_names"
  end

  def write_graph(p, x_points, y_points, output_path)
    min_x = 0.0
    max_x = 0.0
    min_y = 0.0
    max_y = 0.0
    x_points.each_with_index do |x, i|
      y = y_points[i]
      p.add_point(x, "x")
      p.add_point(y, "y")
      min_x = x if x < min_x
      max_x = x if x > max_x
      min_y = y if y < min_y
      max_y = y if y > max_y
    end
    p.add_all_series
    ch = Rchart.new(APP_CONFIG['chart_width'], APP_CONFIG['chart_height'])

    # Add a 10% buffer to the x and y scales for improved viewing
    min_y = min_y < 0 ? min_y*1.1 : min_y*0.9
    max_y = max_y < 0 ? max_y*0.9 : max_y*1.1
    min_x = min_x < 0 ? min_x*1.1 : min_x*0.9
    max_x = max_x < 0 ? max_x*0.9 : max_x*1.1
    ch.set_fixed_scale(min_y, max_y, 10, min_x, max_x, 10)
    ch.set_graph_area(100, 30, 570, 330)
    ch.draw_background(255, 255, 255)
    ch.draw_grid(1, false, 50, 50, 50, 20)
    ch.draw_xy_scale(p.get_data, p.get_data_description, "y", "x", 0, 0, 0, true, 45, 6)

    ch.draw_xy_graph(p.get_data, p.get_data_description, "y", "x", PALETTE_INDEX)
    ch.draw_xy_plot_graph(p.get_data, p.get_data_description, "y", "x", PALETTE_INDEX, 2, 1, -1, -1, -1, false)
    ch.clear_shadow

    ch.render_png(output_path)
  end

end
