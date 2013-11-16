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
              from = get_mailaddr(mail.attr[from_attr])
              subject = NKF.nkf("-m -w", mail.attr[subject_attr].tr("\r\n",""))[9..-1]
              body = NKF.nkf("-m -w", mail.attr[body_attr])

              
              puts "==============="
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
  # pp action
  # pp mail

  title = action.get_title
  title = title.call(mail) if title.class.to_s == "Proc"

  body = action.get_body
  body = body.call(mail) if body.class.to_s == "Proc"

  url = action.get_url
  url = url.call(mail) if url.class.to_s == "Proc"

  TerminalNotifier.notify(body, title: title, sound: action.get_sound, open: url)
end

def mainloop_
  OpenSSL::SSL.module_eval{ remove_const(:VERIFY_PEER) }
  OpenSSL::SSL.const_set(:VERIFY_PEER, OpenSSL::SSL::VERIFY_NONE)
  imap = Net::IMAP.new('izawa.org', 993, true)

  user = "izawa"
  pass = "vzcs1bk"
  duration = 60

  imap.authenticate('PLAIN', user, pass)
  
  # メールヘッダの件名(Subject)
  subject_attr_name = 'BODY[HEADER.FIELDS (SUBJECT)]'
  # メールヘッダの差出人(From)
  from_attr_name = 'BODY[HEADER.FIELDS (FROM)]'
  # メール本文(Body)
  body_attr_name = 'BODY[TEXT]'

  # ここから先をループ
  while(true)
    imap.examine('INBOX')
    msgids = imap.search(['UNSEEN']).each do |msgid|
      imap.fetch(msgid, [subject_attr_name, from_attr_name, body_attr_name]).each do |mail|
      from = get_mailaddr(mail.attr[from_attr_name])
      if from == 'osirase_r@kakaku.com'
        puts mail.attr[subject_attr_name]
        subject = NKF.nkf("-m -w", mail.attr[subject_attr_name].gsub("\r","").gsub("\n","")).gsub("Subject: ","")
        puts subject
        body = kakaku_body2info(NKF.nkf("-m -w", mail.attr[body_attr_name]))
        puts body
        TerminalNotifier.notify(body, title: subject, sound: 'Purr', open: kakaku_body2url(NKF.nkf("-m -w", mail.attr[body_attr_name])))
        puts msgid
        imap.select('INBOX')
        imap.store(msgid, '+FLAGS', :Seen)
        imap.examine('INBOX')
      end
    end
  end
  sleep duration
end
end
