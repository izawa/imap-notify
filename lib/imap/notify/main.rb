# -*- coding: utf-8 -*-
require 'net/imap'
require 'terminal-notifier'
require 'nkf'

def mainloop
  OpenSSL::SSL.module_eval{ remove_const(:VERIFY_PEER) }
  OpenSSL::SSL.const_set( :VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE )

  # メールヘッダの件名(Subject)
  subject_attr = 'BODY[HEADER.FIELDS (SUBJECT)]'
  # メールヘッダの差出人(From)
  from_attr = 'BODY[HEADER.FIELDS (FROM)]'
  # メール本文(Body)
  body_attr = 'BODY[TEXT]'

  conn = { }
  threads = { }

########
# initializing connections.
########

  $myConfig.each do |hostname, value|
    imap = Net::IMAP.new(hostname, value.get_port, value.get_use_ssl)
    imap.authenticate(value.get_auth_mode, value.get_user, value.get_password)
    conn[hostname] = imap
  end

########
# main loop
########

  $myConfig.each do |hostname, hostcfgs|  # サーバ毎のループ
    threads[hostname] = Thread.start do
      loop do 
        hostcfgs.get_mboxes.each do |mboxname, triggers| # mbox 毎のループ
          conn[hostname].examine(mboxname)
          # mboxのunseen なメールでループ
          conn[hostname].search(['UNSEEN']).each do |msgid|
            conn[hostname].fetch(msgid, [subject_attr, from_attr, body_attr]).each do |mail|
              #from, subject, bodyを取得
              from = get_mailaddr(mail.attr[from_attr]) if mail.attr[from_attr]
              subject = NKF.nkf("-m -w", mail.attr[subject_attr]) if mail.attr[subject_attr]
              subject = subject.tr("\r\n","")[9..-1]  if subject
              body = NKF.nkf("-m -w", mail.attr[body_attr]) if mail.attr[body_attr]
              
              puts "==============="
              puts msgid
              puts from

              triggers.each do |trigger| # trigger 毎にループしてmatchチェック
                if matcher(trigger, from: from, subject: subject, body: body)
                  puts "==MATCH=="
                  actant(trigger.get_action, from: from, subject: subject, body: body)
                  #seen 処理
                  if(trigger.get_action.seen?)
                    conn[hostname].select(mboxname)
                    conn[hostname].store(msgid, '+FLAGS', :Seen)
                    conn[hostname].examine(mboxname)
                  end
                end
              end
            end
          end
        end
        puts "--- #{hostname} ----------------------------------------------"
        sleep hostcfgs.get_duration.to_i
      end
    end
  end

  threads.each_value do |thread|
    thread.join
  end

########
# finisiating connections.
########
  conn.each do |key, imap|
    imap.disconnect
  end
end

def matcher(trigger, mail = { })
  if trigger.get_from
    return true if mail[:from].match(trigger.get_from)
  end

  if trigger.get_subject
    return true if mail[:subject].match(trigger.get_subject)
  end

  return false
end

def actant(action, mail = { })
  title = action.get_title
  title = title.call(mail) if title.class.to_s == "Proc"

  body = action.get_body
  body = body.call(mail) if body.class.to_s == "Proc"

  url = action.get_url
  url = url.call(mail) if url.class.to_s == "Proc"

  sound = action.get_sound

  option_hash = { }

  option_hash[:title] = title if title
  option_hash[:open]  = url   if url
  option_hash[:sound] = sound if sound

  TerminalNotifier.notify(body, option_hash)
end
