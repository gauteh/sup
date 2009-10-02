module Redwood

class LabelListMode < LineCursorMode
  register_keymap do |k|
    km = I18n['label_list.keymap']
    k.add :select_label, km['select_label'], :enter
    k.add :reload, km['reload'], '@'
    k.add :jump_to_next_new, km['jump_to_next_new'], :tab
    k.add :toggle_show_unread_only, km['toggle_show_unread_only'], 'u'
  end

  def initialize
    @labels = []
    @text = []
    @unread_only = false
    super
    UpdateManager.register self
    regen_text
  end

  def cleanup
    UpdateManager.unregister self
    super
  end

  def lines; @text.length end
  def [] i; @text[i] end

  def jump_to_next_new
    n = ((curpos + 1) ... lines).find { |i| @labels[i][1] > 0 } || (0 ... curpos).find { |i| @labels[i][1] > 0 }
    if n
      ## jump there if necessary
      jump_to_line n unless n >= topline && n < botline
      set_cursor_pos n
    else
      BufferManager.flash I18n['flash.info.no_labels_msg_with_unread']
    end
  end

  def focus
    reload # make sure unread message counts are up-to-date
  end

  def handle_added_update sender, m
    reload
  end

protected

  def toggle_show_unread_only
    @unread_only = !@unread_only
    reload
  end

  def reload
    regen_text
    buffer.mark_dirty if buffer
  end

  def regen_text
    @text = []
    labels = LabelManager.all_labels

    counts = labels.map do |label|
      string = LabelManager.string_for label
      total = Index.num_results_for :label => label
      unread = (label == :unread)? total : Index.num_results_for(:labels => [label, :unread])
      [label, string, total, unread]
    end.sort_by { |l, s, t, u| s.downcase }

    width = counts.max_of { |l, s, t, u| s.length }

    if @unread_only
      counts.delete_if { | l, s, t, u | u == 0 }
    end

    @labels = []
    counts.map do |label, string, total, unread|
      ## if we've done a search and there are no messages for this label, we can delete it from the
      ## list. BUT if it's a brand-new label, the user may not have sync'ed it to the index yet, so
      ## don't delete it in this case.
      ##
      ## this is all a hack. what should happen is:
      ##   TODO make the labelmanager responsible for label counts
      ## and then it can listen to labeled and unlabeled events, etc.
      if total == 0 && !LabelManager::RESERVED_LABELS.include?(label) && !LabelManager.new_label?(label)
        debug "no hits for label #{label}, deleting"
        LabelManager.delete label
        next
      end

      @text << [[(unread == 0 ? :labellist_old_color : :labellist_new_color),
          sprintf("%#{width + 1}s %5d %s, %5d #{I18n['words.unread']}", string, total, total == 1 ? " #{I18n['words.message']}" : I18n['words.messages'], unread)]]
      @labels << [label, unread]
      yield i if block_given?
    end.compact

    BufferManager.flash I18n['flash.info.no_labels_with_unread_messages'] if counts.empty? && @unread_only
  end

  def select_label
    label, num_unread = @labels[curpos]
    return unless label
    LabelSearchResultsMode.spawn_nicely label
  end
end

end
