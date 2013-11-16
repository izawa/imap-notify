class Trigger
  attr_accessor :from, :subject, :action

  def from(from)
    @from = from
  end

  def get_from
    @from
  end

  def subject(subject)
    @subject = subject
  end

  def get_subject
    @subject
  end


  def action(&block)
    @action = Action.new
    @action.instance_eval &block if block_given?
  end

  def get_action
    @action
  end

end
