; docformat = 'rst'


function mg_battery_plot_extract, line
  compile_opt strictarr

  tokens = stregex(line, '.* = ([[:digit:]]+)', /extract, /subexpr)
  return, tokens[1] eq '' ? -1L : long(tokens[1])
end


pro mg_battery_plot
  compile_opt strictarr

  filename = '~/data/battery.log'
  nlinesPerReading = 5L

  nlines = file_lines(filename)
  nreadings = nlines / nlinesPerReading

  reading = strarr(nlinesPerReading)
  times = lonarr(nreadings)
  cycle_count = lonarr(nreadings)
  max_capacity = lonarr(nreadings)
  current_capacity = lonarr(nreadings)
  design_capacity = lonarr(nreadings)

  openr, lun, filename, /get_lun
  for i = 0L, nreadings - 1L do begin
    readf, lun, reading
    times[i] = long(reading[0])
    cycle_count[i] = mg_battery_plot_extract(reading[1])
    max_capacity[i] = mg_battery_plot_extract(reading[2])
    current_capacity[i] = mg_battery_plot_extract(reading[3])
    design_capacity[i] = mg_battery_plot_extract(reading[4])
  endfor
  free_lun, lun

  cycles = uniq(cycle_count)

  mg_psbegin, /image, filename='battery.ps', xsize=6, ysize=4, /inches
  mg_decomposed, 1, old_decomposed=odec

  plot, times, float(current_capacity) / float(max_capacity), $
        xstyle=9, ystyle=9, yrange=[0., 1.], $
        psym=mg_usersym(/circle), symsize=0.15

  for c = 0L, n_elements(cycles) - 2L do begin
    plots, fltarr(2) + times[cycles[c]], !y.crange, color='0000ff'x, thick=4
  endfor

  mg_decomposed, odec
  mg_psend
  mg_convert, 'battery', max_dimensions=[700, 700], output=im

  mg_image, im, /new_window
end