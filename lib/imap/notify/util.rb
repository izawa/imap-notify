# -*- coding: utf-8 -*-
#
## regular expression if mail address (addr-spec) RFC5322 like
## ref: http://blog.everqueue.com/chiba/2009/03/22/163/

def get_mailaddr(line)
  wsp           = '[\x20\x09]'
  vchar         = '[\x21-\x7e]'
  quoted_pair   = "\\\\(?:#{vchar}|#{wsp})"
  qtext         = '[\x21\x23-\x5b\x5d-\x7e]'
  qcontent      = "(?:#{qtext}|#{quoted_pair})"
  quoted_string = "\"#{qcontent}*\""
  atext         = '[a-zA-Z0-9!#$%&\'*+\-\/\=?^_`{|}~]'
  dot_atom_text = "#{atext}+(?:[.]#{atext}+)*"
  dot_atom      = dot_atom_text
  local_part    = "(?:#{dot_atom}|#{quoted_string})"
  domain        = dot_atom
  addr_spec     = "#{local_part}[@]#{domain}"

  dot_atom_loose   = "#{atext}+(?:[.]|#{atext})*"
  local_part_loose = "(?:#{dot_atom_loose}|#{quoted_string})"
  addr_spec_loose  = "#{local_part_loose}[@]#{domain}"

  if /(#{addr_spec})/ =~ line then
    return $1
  else
    return nil
  end
end

def check_mailaddr(addr)
  wsp           = '[\x20\x09]'
  vchar         = '[\x21-\x7e]'
  quoted_pair   = "\\\\(?:#{vchar}|#{wsp})"
  qtext         = '[\x21\x23-\x5b\x5d-\x7e]'
  qcontent      = "(?:#{qtext}|#{quoted_pair})"
  quoted_string = "\"#{qcontent}*\""
  atext         = '[a-zA-Z0-9!#$%&\'*+\-\/\=?^_`{|}~]'
  dot_atom_text = "#{atext}+(?:[.]#{atext}+)*"
  dot_atom      = dot_atom_text
  local_part    = "(?:#{dot_atom}|#{quoted_string})"
  domain        = dot_atom
  addr_spec     = "#{local_part}[@]#{domain}"

  dot_atom_loose   = "#{atext}+(?:[.]|#{atext})*"
  local_part_loose = "(?:#{dot_atom_loose}|#{quoted_string})"
  addr_spec_loose  = "#{local_part_loose}[@]#{domain}"

  if /\A#{addr_spec}\z/ =~ addr
    return true
  else
    return false
  end
end

