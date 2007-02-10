module Redwood

class ResumeMode < ComposeMode
  def initialize m
    super()
    @id = m.id
    @header, @body = parse_file m.draft_filename
    @header.delete "Date"
    @header["Message-Id"] = gen_message_id # generate a new'n
    regen_text
    @safe = false
  end

  def killable?
    return true if @safe

    case BufferManager.ask_yes_or_no "Discard draft?"
    when true
      DraftManager.discard @id
      BufferManager.flash "Draft discarded."
      true
    when false
      if edited?
        DraftManager.write_draft { |f| write_message f, false }
        DraftManager.discard @id
        BufferManager.flash "Draft saved."
      end
      true
    else
      false
    end
  end

  def send_message
    if super
      DraftManager.discard @id 
      @safe = true
    end
  end

  def save_as_draft
    @safe = true
    DraftManager.discard @id if super
  end
end

end
