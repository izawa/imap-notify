
class HostConfig
  attr_accessor :host, :port, :user, :password, :ssl_flag, :auth_mode, :duration,:mboxes
  attr_accessor :name

  def initialize(host)
    @host = host
    @triggers = []
    @duration = 60 #sec
    @ssl_flag = false
    @mboxes = { }
  end


  def host(host)
    @host = host
  end

  def get_host
    @host
  end

  def port(port)
    @port = port
  end

  def get_port
    @port
  end

  def user(user)
    @user = user
  end

  def get_user
    @user
  end

  def password(password)
    @password = password
  end

  def get_password
    @password
  end

  def use_ssl
    @ssl_flag = true
  end

  def get_use_ssl
    @ssl_flag
  end

  def auth_mode(auth_mode)
    @auth_mode = auth_mode
  end

  def get_auth_mode
    @auth_mode
  end

  def duration(duration)
    @duration = duration
  end

  def get_duration
    @duration
  end

  def get_mboxes
    @mboxes
  end

###
# DSL functions
###

  def mbox(name, &block)
    @name = name
    self.instance_eval &block if block_given?
  end

  def trigger(&block)
    trigger = Trigger.new
    trigger.instance_eval &block if block_given?
    @mboxes[@name] =[] unless @mboxes[@name]
    @mboxes[@name] << trigger
  end
end
