require 'rubygems'

SCHEDULER.every '1m', first_in: '5m' do
  threshold = 7200
  stale = 'stale'

  widgets = Sinatra::Application.settings.history
  total = 0

  widgets.each do |key, value|
    update_s = value.to_s.slice(value.to_s.index('updatedAt') + 11..-1)
    update_s = update_s.tr('}', '').strip

    updated = update_s.to_i
    now = Time.new.to_i
    diff = now - updated
    min = diff / 60
    next if diff < threshold
    puts Time.now.to_s + ': Stale widget (' + key.to_s + ') update time: ' +
         min.to_s + ' minutes ago.'
    send_event(key.to_s, status: stale)
    total += 1
  end
  puts Time.now.to_s + ': Stale widgets: ' + total.to_s
  stale_list = { value: total, current: total }
  send_event('stale_widgets', stale_list)
end
