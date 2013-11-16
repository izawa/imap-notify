require "imap/notify/version"
require "imap/notify/config"
require "imap/notify/trigger"
require "imap/notify/action"
require "imap/notify/main"
require "imap/notify/util"

module Imap
  module Notify
    def imapConfig(host, &block)
      config = HostConfig.new(host)
      config.instance_eval &block
      $myConfig[host] = config
    end
  end
end
