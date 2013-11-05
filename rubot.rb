# $Id$
# RuBot - An AI bot for IRC written in Ruby
# Copyright (C) 2013 Lloyd Dilley (see authors.txt for details) 
# http://www.devux.org/projects/rubot/
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

require 'socket'

class Rubot
  # Configurables
  @@server = "irc.devux.org"
  @@port = 6667
  @@channel = "#sysadmininkudzu"
  @@nick = "RuBot"
  @@altnick = "RuBot-"
  @@ident = "rubot"
  @@realname = "RuBot"
  @@nickserv_password = ""

  # Leave stuff below here alone
  @@connection = nil

  def self.connect()
    @@connection = TCPSocket.open(@@server, @@port) # add exception handling later when I get around to it
    @@connection.write("USER #{@@ident} #{@@ident} localhost :#{@@realname}\r\n")
    @@connection.write("NICK #{@@nick}\r\n")
    data_received = ""
    loop do
      data_received = @@connection.gets("\r\n").chomp("\r\n").split
      if data_received[0].casecmp("PING") == 0
        @@connection.gets("\r\n") # extra gets() needed for PONG timeout message some IRC daemons use
        break
      end
    end
    @@connection.write("PONG #{data_received[1]}\r\n")
    @@connection.gets("\r\n") # skip motd
    @@connection.write("JOIN #{@@channel}\r\n")
  end

  def self.main_loop()
    loop do
      data_received = @@connection.gets("\r\n").chomp("\r\n").split
      unless data_received == nil
        if data_received[0].casecmp("PING") == 0
          @@connection.write("PONG #{data_received[1]}\r\n")
        # Some example commands to handle below
        elsif data_received[1].casecmp("PRIVMSG") == 0 && data_received[3].casecmp(":!op") == 0
          @@connection.write("MODE #{data_received[2]} +o #{data_received[4]}\r\n")
        elsif data_received[1].casecmp("PRIVMSG") == 0 && data_received[3].casecmp(":!deop") == 0
          @@connection.write("MODE #{data_received[2]} -o #{data_received[4]}\r\n")
        elsif data_received[1].casecmp("PRIVMSG") == 0 && data_received[3].casecmp(":!voice") == 0
          @@connection.write("MODE #{data_received[2]} +v #{data_received[4]}\r\n")
        elsif data_received[1].casecmp("PRIVMSG") == 0 && data_received[3].casecmp(":!devoice") == 0
          @@connection.write("MODE #{data_received[2]} -v #{data_received[4]}\r\n")
        elsif data_received[1].casecmp("PRIVMSG") == 0 && data_received[3].casecmp(":!kick") == 0
          @@connection.write("KICK #{data_received[2]} #{data_received[4]}\r\n")
        elsif data_received[1].casecmp("PRIVMSG") == 0 && data_received[3].casecmp(":!ban") == 0
          @@connection.write("MODE #{data_received[2]} +b #{data_received[4]}\r\n")
        elsif data_received[1].casecmp("PRIVMSG") == 0 && data_received[3].casecmp(":!rep") == 0
          @@connection.write("PRIVMSG #{data_received[2]} :#{data_received[4..-1].join(" ")}\r\n")
        end
      end
      sleep 1
    end
  end
end

Rubot.connect()
Rubot.main_loop()
