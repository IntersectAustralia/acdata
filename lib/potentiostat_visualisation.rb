class PotentiostatVisualisation

  require 'rubygems'
  require 'rchart'

  def self.build(attachment)
    file = File.open(attachment.path, 'r')

    p = Rdata.new
    min_x = 0.0
    max_x = 0.0
    min_y = 0.0
    max_y = 0.0
    x_vals = []
    y_vals = {}
    while (line = file.gets)
      /^\s*([\d\.E-]+)\s+(.+)/.match(line)
      x = $1
      next if x.nil?
      x = x.to_f
      x_vals << x
      min_x = x if x < min_x
      max_x = x if x > max_x
      p.add_point(x, "x")
      yvals = $2.chomp.split(/\s+/)
      y_index = 0
      yvals.each do |y|
        yval = y.to_f
        y_vals.include?(y_index) ? y_vals[y_index] << yval : y_vals[y_index] = [yval]
        y_index += 1
        p.add_point(yval, "y#{y_index}")
        min_y = yval if yval < min_y
        max_y = yval if yval > max_y
      end
    end
    if x_vals.empty?
      raise "No data for chart from: #{attachment.path}"
    end
    p.add_all_series
    ch = Rchart.new(600, 400)
    ch.load_color_palette(create_palette)
    # Add a 10% buffer to the x and y scales for improved viewing
    min_y = min_y < 0 ? min_y*1.1 : min_y*0.9
    max_y = max_y < 0 ? max_y*0.9 : max_y*1.1
    min_x = min_x < 0 ? min_x*1.1 : min_x*0.9
    max_x = max_x < 0 ? max_x*0.9 : max_x*1.1
    ch.set_fixed_scale(min_y, max_y, 10, min_x, max_x, 10)
    ch.set_graph_area(55, 30, 570, 330)
    ch.draw_background(255, 255, 255)
    ch.draw_grid(1, false, 50, 50, 50, 20)
    ch.draw_xy_scale(p.get_data, p.get_data_description, "y1", "x", 0, 0, 0, true, 45, 6)

    # Draw XY Chart
    (1..y_index).map { |i|
      palette = i%10
      ch.draw_xy_graph(p.get_data, p.get_data_description, "y#{i}", "x", i-1)
    }
    ch.clear_shadow

    p.remove_serie("x")
    output_path = chart_file_path(attachment.dataset)
    ch.render_png(output_path)
  end

  def self.display_file(attachment)
    unless attachment.nil?
      chart_file_path(attachment.dataset)
    end
  end

  private

  def self.chart_file_path(dataset)
    File.join(dataset.dataset_path, "dataset_#{dataset.id}_potentiostat_chart.png")
  end

  def self.create_palette
    palette = []
    frequency = 0.3
    32.times do |i|
      red = Math.sin(frequency*i + 0) * 127 + 128;
      green = Math.sin(frequency*i + 2) * 127 + 128;
      blue = Math.sin(frequency*i + 4) * 127 + 128;
      palette << [red.to_i, green.to_i, blue.to_i]
    end
    palette
  end

end
