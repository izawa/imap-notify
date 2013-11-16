class Action
  attr_accessor :title, :body, :url, :sound, :seen_flag


  def initialize
    @seen_flag = true
  end

  def title(title)
    @title = title
  end

  def get_title
    @title
  end

  def body(body)
    @body = body
  end

  def get_body
    @body
  end

  def url(url)
    @url = url
  end

  def get_url
    @url
  end

  def sound(sound)
    @sound = sound
  end

  def get_sound
    @sound
  end

  def seen(flag)
    @seen_flag = flag
  end

  def seen?
    @seen_flag
  end

end
