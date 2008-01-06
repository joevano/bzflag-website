require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../lib/log_parser'

class LogParserTest < Test::Unit::TestCase
  fixtures :server_hosts, :bz_servers, :callsigns, :log_types

  def setup
    @server_host = ServerHost.find(1)
    @bz_server = BzServer.find(1)
  end

  def test_get_callsign
    callsign, detail = LogParser.get_callsign("3:xyz more stuff")
    assert_equal("xyz", callsign.name)
    assert_equal("more stuff", detail)
  end

  def test_get_callsign_no_data
    callsign, detail = LogParser.get_callsign("0: more stuff")
    assert_equal("UNKNOWN", callsign.name)
    assert_equal("more stuff", detail)
  end

  def test_get_blank_callsign
    callsign, detail = LogParser.get_callsign("3:    more stuff")
    assert_equal("UNKNOWN", callsign.name)
    assert_equal("more stuff", detail)
  end

  def test_get_message
    msg_text = "This is a test message"
    msg = LogParser.get_message(msg_text)
    assert_not_nil(msg)
    assert_equal(msg_text, msg.text)
    assert_not_nil(msg.id)
  end

  def test_get_dup_message
    msg1_text = "This is a message"
    msg2_text = msg1_text
    msg1 = LogParser.get_message(msg1_text)
    assert_not_nil(msg1)
    msg2 = LogParser.get_message(msg2_text)
    assert_not_nil(msg2)
    assert_equal(msg1_text, msg1.text)
    assert_equal(msg2_text, msg2.text)
    assert_equal(msg1.id, msg2.id)
  end

  def test_get_nodup_message
    msg1_text = "This is a message"
    msg2_text = "Another message"
    msg1 = LogParser.get_message(msg1_text)
    assert_not_nil(msg1)
    msg2 = LogParser.get_message(msg2_text)
    assert_not_nil(msg2)
    assert_not_equal(msg1_text, msg2_text)
    assert_equal(msg1_text, msg1.text)
    assert_equal(msg2_text, msg2.text)
    assert_not_equal(msg1.id, msg2.id)
  end

  def test_get_team
    team_name = "PURPLE"
    team_text = "#{team_name} more stuff"
    team, detail = LogParser.get_team(team_text)
    assert_not_nil(team)
    assert_equal(team_name, team.name)
    assert_equal(detail, "more stuff")
    assert_not_nil(team.id)
  end

  def test_get_dup_team
    team_name = "RED"
    team1_text = "#{team_name} more stuff"
    team2_text = "#{team_name} something else"
    team1, detail = LogParser.get_team(team1_text)
    team2, detail2  = LogParser.get_team(team2_text)
    assert_not_nil(team1)
    assert_not_nil(team2)
    assert_equal(team_name, team1.name)
    assert_equal(team_name, team2.name)
    assert_equal(team1.id, team2.id)
  end

  def test_get_nodup_team
    team1_name = "RED"
    team2_name = "BLUE"
    team1_text = "#{team1_name} more stuff"
    team2_text = "#{team2_name} something else"
    team1, rest1 = LogParser.get_team(team1_text)
    team2, rest2 = LogParser.get_team(team2_text)
    assert_not_nil(team1)
    assert_not_nil(team2)
    assert_not_equal(team1_text, team2_text)
    assert_equal(team1_name, team1.name)
    assert_equal(team2_name, team2.name)
    assert_not_equal(team1.id, team2.id)
  end
    
  def test_parse_callsign
    cs, rest = LogParser.parse_callsign("7:ABCDEFG other stuff")
    assert_equal("ABCDEFG", cs)
    assert_equal("other stuff", rest)
  end

  def test_parse_callsign_empty
    cs, rest = LogParser.parse_callsign("0: something")
    assert_equal("", cs)
    assert_equal("something", rest)
  end

  def test_parse_callsign_unknown
    cs, rest = LogParser.parse_callsign("junk goes here")
    assert_equal("UNKNOWN", cs)
    assert_equal("junk goes here", rest)
  end

  def test_parse_bzid
    bzid, rest = LogParser.parse_bzid('BZid:1234 more stuff')
    assert_equal('1234', bzid)
    assert_equal('more stuff', rest)
  end

  def test_parse_bzid_nil
    bzid, rest = LogParser.parse_bzid('more stuff goes here')
    assert_nil(bzid)
    assert_equal('more stuff goes here', rest)
  end

  def test_parse_player_email_special_chars
    data = '[+]22:(}=-!@#$%^&*()-_=~-={)(30:~`!@#$%^&*()_+=-\|{}][<>.,/?12) '
    v, callsign, email, moredata = LogParser.parse_player_email(data)
    assert_equal('+', v)
    assert_equal('(}=-!@#$%^&*()-_=~-={)', callsign)
    assert_equal('(~`!@#$%^&*()_+=-\|{}][<>.,/?12)', email)
    assert_equal('', moredata)
  end

  def test_parse_player_email
    data = '[+]9:Bad Sushi() [+]10:spatialgur(15:spatialguru.com) [@]12:drunk driver()'
    v, callsign, email, moredata = LogParser.parse_player_email(data)
    assert_equal('+', v)
    assert_equal('Bad Sushi', callsign)
    assert_equal('', email)
    v, callsign, email, evenmoredata = LogParser.parse_player_email(moredata)
    assert_equal('+', v)
    assert_equal('spatialgur', callsign)
    assert_equal('(spatialguru.com)', email)
    v, callsign, email, rest = LogParser.parse_player_email(evenmoredata)
    assert_equal('@', v)
    assert_equal('drunk driver', callsign)
    assert_equal('', email)
    assert_equal('', rest)
  end

  def test_player_join_anon
    line = '2007-12-29T00:00:04Z PLAYER-JOIN 7:widgets #2 RED  IP:1.2.4.7'
    LogParser.process_line(@server_host, @bz_server, line)
    pc = PlayerConnection.find(:first)
    assert_not_nil(pc)
    callsign = Callsign.find_by_name("widgets")
    assert_not_nil(callsign)
    assert_equal(callsign.id, pc.callsign_id)
    assert_equal(2, pc.slot)
    assert_nil(pc.bzid)
    team = Team.find_by_name("RED")
    assert_not_nil(team)
    assert_equal(team.id, pc.team_id)
    ip = Ip.find_by_ip("1.2.4.7")
    assert_not_nil(ip)
    assert_equal(ip.id, pc.ip_id)
    assert_not_nil(pc.join_at)
    assert_equal('2007-12-29T00:00:04Z', pc.join_at.strftime('%Y-%m-%dT%H:%M:%SZ'))
    lm = LogMessage.find(:first)
    assert_not_nil(lm)
    assert_not_nil(lm.logged_at)
    assert_equal(pc.join_at, lm.logged_at)
    lt = LogType.find_by_token("PLAYER-JOIN")
    assert_not_nil(lt)
    assert_equal(lt.id, lm.log_type_id)
    assert_equal(pc.callsign_id, lm.callsign_id)
    assert_nil(lm.to_callsign_id)
    assert_nil(lm.bzid)
    assert_equal(pc.team_id, lm.team_id)
    assert_equal(false, pc.is_verified)
    assert_equal(false, pc.is_admin)
    assert_equal(false, pc.is_globaluser)
    assert_nil(lm.message_id)
    assert_equal(@bz_server.id, lm.bz_server_id)
  end

  def test_player_join_bzid
    line = '2007-12-29T00:03:57Z PLAYER-JOIN 19:Some Random Persona #23 BZid:12345 RED  IP:4.7.3.4 VERIFIED GLOBALUSER'
    LogParser.process_line(@server_host, @bz_server, line)
    pc = PlayerConnection.find(:first)
    assert_not_nil(pc)
    callsign = Callsign.find_by_name("Some Random Persona")
    assert_not_nil(callsign)
    assert_equal(callsign.id, pc.callsign_id)
    assert_equal(23, pc.slot)
    assert_equal(12345, pc.bzid)
    team = Team.find_by_name("RED")
    assert_not_nil(team)
    assert_equal(team.id, pc.team_id)
    ip = Ip.find_by_ip("4.7.3.4")
    assert_not_nil(ip)
    assert_equal(ip.id, pc.ip_id)
    assert_not_nil(pc.join_at)
    assert_equal('2007-12-29T00:03:57Z', pc.join_at.strftime('%Y-%m-%dT%H:%M:%SZ'))
    lm = LogMessage.find(:first)
    assert_not_nil(lm)
    assert_not_nil(lm.logged_at)
    assert_equal(pc.join_at, lm.logged_at)
    lt = LogType.find_by_token("PLAYER-JOIN")
    assert_not_nil(lt)
    assert_equal(lt.id, lm.log_type_id)
    assert_equal(pc.callsign_id, lm.callsign_id)
    assert_nil(lm.to_callsign_id)
    assert_equal(pc.bzid, lm.bzid)
    assert_equal(pc.team_id, lm.team_id)
    assert_equal(true, pc.is_verified)
    assert_equal(false, pc.is_admin)
    assert_equal(true, pc.is_globaluser)
    assert_nil(lm.message_id)
    assert_equal(@bz_server.id, lm.bz_server_id)
  end

  def test_player_join_admin
    line = '2007-12-29T00:15:52Z PLAYER-JOIN 7:simtech #20 BZid:2000 GREEN  IP:10.447.11.12 VERIFIED GLOBALUSER ADMIN'
    LogParser.process_line(@server_host, @bz_server, line)
    pc = PlayerConnection.find(:first)
    assert_not_nil(pc)
    callsign = Callsign.find_by_name("simtech")
    assert_not_nil(callsign)
    assert_equal(callsign.id, pc.callsign_id)
    assert_equal(20, pc.slot)
    assert_equal(2000, pc.bzid)
    team = Team.find_by_name("GREEN")
    assert_not_nil(team)
    assert_equal(team.id, pc.team_id)
    ip = Ip.find_by_ip("10.447.11.12")
    assert_not_nil(ip)
    assert_equal(ip.id, pc.ip_id)
    assert_not_nil(pc.join_at)
    assert_equal('2007-12-29T00:15:52Z', pc.join_at.strftime('%Y-%m-%dT%H:%M:%SZ'))
    lm = LogMessage.find(:first)
    assert_not_nil(lm)
    assert_not_nil(lm.logged_at)
    assert_equal(pc.join_at, lm.logged_at)
    lt = LogType.find_by_token("PLAYER-JOIN")
    assert_not_nil(lt)
    assert_equal(lt.id, lm.log_type_id)
    assert_equal(pc.callsign_id, lm.callsign_id)
    assert_nil(lm.to_callsign_id)
    assert_equal(pc.bzid, lm.bzid)
    assert_equal(pc.team_id, lm.team_id)
    assert_equal(true, pc.is_verified)
    assert_equal(true, pc.is_admin)
    assert_equal(true, pc.is_globaluser)
    assert_nil(lm.message_id)
    assert_equal(@bz_server.id, lm.bz_server_id)
  end

  def test_player_part
    line = '2007-12-29T00:02:14Z PLAYER-PART 11:Roger Smith #14 BZid:33333 left'
    # Add a player connection for this server and verify it's still there after processing
    cs = Callsign.create!(:name => "Roger Smith")
    pc = PlayerConnection.create!(:bz_server => @bz_server, :join_at => '2007-10-11', :part_at => nil, :callsign => cs)
    assert_not_nil(pc)
    LogParser.process_line(@server_host, @bz_server, line)
    lm = LogMessage.find(:first)
    assert_not_nil(lm)
    assert_not_nil(lm.logged_at)
    assert_equal('2007-12-29T00:02:14Z', lm.logged_at.strftime('%Y-%m-%dT%H:%M:%SZ'))
    lt = LogType.find_by_token("PLAYER-PART")
    assert_not_nil(lt)
    assert_equal(lt.id, lm.log_type_id)
    callsign = Callsign.find_by_name("Roger Smith")
    assert_not_nil(callsign)
    assert_equal(callsign.id, lm.callsign_id)
    assert_nil(lm.to_callsign_id)
    assert_equal(33333, lm.bzid)
    assert_nil(lm.team_id)
    msg = Message.find_by_text("left")
    assert_not_nil(msg)
    assert_equal(msg.id, lm.message_id)
    assert_equal(@bz_server.id, lm.bz_server_id)
    pc.reload
    assert_equal('2007-12-29T00:02:14Z', pc.part_at.strftime('%Y-%m-%dT%H:%M:%SZ'))
  end

  def test_player_part_no_join
    line = '2007-12-29T00:02:14Z PLAYER-PART 11:Roger Smith #14 BZid:33333 left'
    # Add a player connection for this server and verify it's still there after processing
    cs = Callsign.create!(:name => "Roger Smith")
    LogParser.process_line(@server_host, @bz_server, line)
    lm = LogMessage.find(:first)
    assert_not_nil(lm)
    assert_not_nil(lm.logged_at)
    assert_equal('2007-12-29T00:02:14Z', lm.logged_at.strftime('%Y-%m-%dT%H:%M:%SZ'))
    lt = LogType.find_by_token("PLAYER-PART")
    assert_not_nil(lt)
    assert_equal(lt.id, lm.log_type_id)
    callsign = Callsign.find_by_name("Roger Smith")
    assert_not_nil(callsign)
    assert_equal(callsign.id, lm.callsign_id)
    assert_nil(lm.to_callsign_id)
    assert_equal(33333, lm.bzid)
    assert_nil(lm.team_id)
    msg = Message.find_by_text("left")
    assert_not_nil(msg)
    assert_equal(msg.id, lm.message_id)
    assert_equal(@bz_server.id, lm.bz_server_id)
    assert_equal(0, PlayerConnection.count)
  end

  def test_player_auth
    line = '2007-12-01T07:01:20Z PLAYER-AUTH 6:WhoDat  IP:10.13.181.223 VERIFIED'
    cs = Callsign.locate("WhoDat")
    ip = Ip.locate("10.13.181.223")
    pc = PlayerConnection.create!(:bz_server => @bz_server, :callsign => cs, :ip => ip, :part_at => nil, :is_verified => false, :is_admin => false, :is_globaluser => false)
    assert_not_nil(pc)
    LogParser.process_line(@server_host, @bz_server, line)
    pc.reload
    assert_equal(1, PlayerConnection.count)
    callsign = Callsign.find_by_name("WhoDat")
    assert_not_nil(callsign)
    assert_equal(callsign.id, pc.callsign_id)
    assert_equal(ip.id, pc.ip_id)
    lm = LogMessage.find(:first)
    assert_not_nil(lm)
    assert_not_nil(lm.logged_at)
    assert_equal('2007-12-01T07:01:20Z', lm.logged_at.strftime('%Y-%m-%dT%H:%M:%SZ'))
    lt = LogType.find_by_token("PLAYER-AUTH")
    assert_not_nil(lt)
    assert_equal(lt.id, lm.log_type_id)
    assert_equal(pc.callsign_id, lm.callsign_id)
    assert_nil(lm.to_callsign_id)
    assert_nil(lm.bzid)
    assert_nil(lm.team_id)
    assert_equal(true, pc.is_verified)
    assert_equal(false, pc.is_admin)
    assert_equal(false, pc.is_globaluser)
    assert_nil(lm.message_id)
    assert_equal(@bz_server.id, lm.bz_server_id)
  end

  def test_player_auth_operator
    line = '2007-12-16 11:09:42: PLAYER-AUTH 22:this is really long...  IP:10.168.124.93 ADMIN OPERATOR'
    cs = Callsign.locate("this is really long...")
    ip = Ip.locate("10.168.124.93")
    pc = PlayerConnection.create!(:bz_server => @bz_server, :callsign => cs, :ip => ip, :part_at => nil, :is_verified => false, :is_admin => false, :is_globaluser => false)
    assert_not_nil(pc)
    LogParser.process_line(@server_host, @bz_server, line)
    pc.reload
    assert_equal(1, PlayerConnection.count)
    callsign = Callsign.find_by_name("this is really long...")
    assert_not_nil(callsign)
    assert_equal(callsign.id, pc.callsign_id)
    assert_equal(ip.id, pc.ip_id)
    lm = LogMessage.find(:first)
    assert_not_nil(lm)
    assert_not_nil(lm.logged_at)
    assert_equal('2007-12-16T11:09:42Z', lm.logged_at.strftime('%Y-%m-%dT%H:%M:%SZ'))
    lt = LogType.find_by_token("PLAYER-AUTH")
    assert_not_nil(lt)
    assert_equal(lt.id, lm.log_type_id)
    assert_equal(pc.callsign_id, lm.callsign_id)
    assert_nil(lm.to_callsign_id)
    assert_nil(lm.bzid)
    assert_nil(lm.team_id)
    assert_equal(true, pc.is_verified)
    assert_equal(true, pc.is_admin)
    assert_equal(false, pc.is_globaluser)
    assert_equal(true, pc.is_operator)
    assert_nil(lm.message_id)
    assert_equal(@bz_server.id, lm.bz_server_id)
  end

  def test_server_status
    line = '2007-12-28T01:22:05Z SERVER-STATUS Restart Pending'
    LogParser.process_line(@server_host, @bz_server, line)
    lm = LogMessage.find(:first)
    assert_not_nil(lm)
    assert_not_nil(lm.logged_at)
    assert_equal('2007-12-28T01:22:05Z', lm.logged_at.strftime('%Y-%m-%dT%H:%M:%SZ'))
    lt = LogType.find_by_token("SERVER-STATUS")
    assert_not_nil(lt)
    assert_equal(lt.id, lm.log_type_id)
    assert_nil(lm.callsign_id)
    assert_nil(lm.to_callsign_id)
    assert_nil(lm.bzid)
    assert_nil(lm.team_id)
    msg = Message.find_by_text("Restart Pending")
    assert_not_nil(msg)
    assert_equal(msg.id, lm.message_id)
    assert_equal(@bz_server.id, lm.bz_server_id)
    assert_equal(lm.id, @bz_server.server_status_log_message_id)
  end

  def test_msg_broadcast
    line = '2007-12-29T00:02:12Z MSG-BROADCAST 9:onetwosix random message'
    LogParser.process_line(@server_host, @bz_server, line)
    lm = LogMessage.find(:first)
    assert_not_nil(lm)
    assert_not_nil(lm.logged_at)
    assert_equal('2007-12-29T00:02:12Z', lm.logged_at.strftime('%Y-%m-%dT%H:%M:%SZ'))
    lt = LogType.find_by_token("MSG-BROADCAST")
    assert_not_nil(lt)
    assert_equal(lt.id, lm.log_type_id)
    callsign = Callsign.find_by_name("onetwosix")
    assert_not_nil(callsign)
    assert_equal(callsign.id, lm.callsign_id)
    assert_nil(lm.to_callsign_id)
    assert_nil(lm.bzid)
    assert_nil(lm.team_id)
    msg = Message.find_by_text("random message")
    assert_not_nil(msg)
    assert_equal(msg.id, lm.message_id)
    assert_equal(@bz_server.id, lm.bz_server_id)
  end

  def test_msg_filtered
    line = '2007-12-29T00:28:46Z MSG-FILTERED 7:badguy2 whata $*^'
    LogParser.process_line(@server_host, @bz_server, line)
    lm = LogMessage.find(:first)
    assert_not_nil(lm)
    assert_not_nil(lm.logged_at)
    assert_equal('2007-12-29T00:28:46Z', lm.logged_at.strftime('%Y-%m-%dT%H:%M:%SZ'))
    lt = LogType.find_by_token("MSG-FILTERED")
    assert_not_nil(lt)
    assert_equal(lt.id, lm.log_type_id)
    callsign = Callsign.find_by_name("badguy2")
    assert_not_nil(callsign)
    assert_equal(callsign.id, lm.callsign_id)
    assert_nil(lm.to_callsign_id)
    assert_nil(lm.bzid)
    assert_nil(lm.team_id)
    msg = Message.find_by_text("whata $*^")
    assert_not_nil(msg)
    assert_equal(msg.id, lm.message_id)
    assert_equal(@bz_server.id, lm.bz_server_id)
  end

  def test_msg_report
    line = '2007-12-29T00:58:41Z MSG-REPORT 5:WQR42 This is the coolest website project ever!'
    LogParser.process_line(@server_host, @bz_server, line)
    lm = LogMessage.find(:first)
    assert_not_nil(lm)
    assert_not_nil(lm.logged_at)
    assert_equal('2007-12-29T00:58:41Z', lm.logged_at.strftime('%Y-%m-%dT%H:%M:%SZ'))
    lt = LogType.find_by_token("MSG-REPORT")
    assert_not_nil(lt)
    assert_equal(lt.id, lm.log_type_id)
    callsign = Callsign.find_by_name("WQR42")
    assert_not_nil(callsign)
    assert_equal(callsign.id, lm.callsign_id)
    assert_nil(lm.to_callsign_id)
    assert_nil(lm.bzid)
    assert_nil(lm.team_id)
    msg = Message.find_by_text("This is the coolest website project ever!")
    assert_not_nil(msg)
    assert_equal(msg.id, lm.message_id)
    assert_equal(@bz_server.id, lm.bz_server_id)
  end

  def test_msg_command
    line = '2007-12-29T01:08:57Z MSG-COMMAND 10:IMonDialup lagstats'
    LogParser.process_line(@server_host, @bz_server, line)
    lm = LogMessage.find(:first)
    assert_not_nil(lm)
    assert_not_nil(lm.logged_at)
    assert_equal('2007-12-29T01:08:57Z', lm.logged_at.strftime('%Y-%m-%dT%H:%M:%SZ'))
    lt = LogType.find_by_token("MSG-COMMAND")
    assert_not_nil(lt)
    assert_equal(lt.id, lm.log_type_id)
    callsign = Callsign.find_by_name("IMonDialup")
    assert_not_nil(callsign)
    assert_equal(callsign.id, lm.callsign_id)
    assert_nil(lm.to_callsign_id)
    assert_nil(lm.bzid)
    assert_nil(lm.team_id)
    msg = Message.find_by_text("lagstats")
    assert_not_nil(msg)
    assert_equal(msg.id, lm.message_id)
    assert_equal(@bz_server.id, lm.bz_server_id)
  end

  def test_msg_admins
    line = '2007-12-29T00:00:40Z MSG-ADMIN 6:SERVER Team kill: furball14 killed AnotherUser'
    LogParser.process_line(@server_host, @bz_server, line)
    lm = LogMessage.find(:first)
    assert_not_nil(lm)
    assert_not_nil(lm.logged_at)
    assert_equal('2007-12-29T00:00:40Z', lm.logged_at.strftime('%Y-%m-%dT%H:%M:%SZ'))
    lt = LogType.find_by_token("MSG-ADMIN")
    assert_not_nil(lt)
    assert_equal(lt.id, lm.log_type_id)
    callsign = Callsign.find_by_name("SERVER")
    assert_not_nil(callsign)
    assert_equal(callsign.id, lm.callsign_id)
    assert_nil(lm.to_callsign_id)
    assert_nil(lm.bzid)
    assert_nil(lm.team_id)
    msg = Message.find_by_text("Team kill: furball14 killed AnotherUser")
    assert_not_nil(msg)
    assert_equal(msg.id, lm.message_id)
    assert_equal(@bz_server.id, lm.bz_server_id)
  end

  def test_msg_direct
    line = '2007-12-29T01:25:18Z MSG-DIRECT 10:DirectMsgs 6:Fred55 ok'
    LogParser.process_line(@server_host, @bz_server, line)
    lm = LogMessage.find(:first)
    assert_not_nil(lm)
    assert_not_nil(lm.logged_at)
    assert_equal('2007-12-29T01:25:18Z', lm.logged_at.strftime('%Y-%m-%dT%H:%M:%SZ'))
    lt = LogType.find_by_token("MSG-DIRECT")
    assert_not_nil(lt)
    assert_equal(lt.id, lm.log_type_id)
    callsign = Callsign.find_by_name("DirectMsgs")
    assert_not_nil(callsign)
    assert_equal(callsign.id, lm.callsign_id)
    callsign = Callsign.find_by_name("Fred55")
    assert_not_nil(callsign)
    assert_equal(callsign.id, lm.to_callsign_id)
    assert_nil(lm.bzid)
    assert_nil(lm.team_id)
    msg = Message.find_by_text("ok")
    assert_not_nil(msg)
    assert_equal(msg.id, lm.message_id)
    assert_equal(@bz_server.id, lm.bz_server_id)
  end

  def test_msg_team
    line = '2007-12-29T00:00:44Z MSG-TEAM 9:xxyyzzaab GREEN gah'
    LogParser.process_line(@server_host, @bz_server, line)
    lm = LogMessage.find(:first)
    assert_not_nil(lm)
    assert_not_nil(lm.logged_at)
    assert_equal('2007-12-29T00:00:44Z', lm.logged_at.strftime('%Y-%m-%dT%H:%M:%SZ'))
    lt = LogType.find_by_token("MSG-TEAM")
    assert_not_nil(lt)
    assert_equal(lt.id, lm.log_type_id)
    callsign = Callsign.find_by_name("xxyyzzaab")
    assert_not_nil(callsign)
    assert_equal(callsign.id, lm.callsign_id)
    assert_nil(lm.to_callsign_id)
    assert_nil(lm.bzid)
    team = Team.find_by_name("GREEN")
    assert_not_nil(team)
    assert_equal(team.id, lm.team_id)
    msg = Message.find_by_text("gah")
    assert_not_nil(msg)
    assert_equal(msg.id, lm.message_id)
    assert_equal(@bz_server.id, lm.bz_server_id)
  end

  def test_players
    line = '2007-12-29T00:00:04Z PLAYERS (3) [+]11:AAAAAAAAAAA(21:BBBBBBBBBBBBBBBBBBBBB) [ ]7:CCCCCCC(14:DDDDDDDDDDDDDD) [@]5:NNNNN()'
    # Add a player connection for this server and verify it's still there after processing
    PlayerConnection.create!(:bz_server => @bz_server, :join_at => '2007-10-11', :part_at => nil)
    assert_equal(1, PlayerConnection.count(:conditions => "bz_server_id = #{@bz_server.id} and part_at is null"))
    LogParser.process_line(@server_host, @bz_server, line)
    assert_equal(0, LogMessage.count)
    assert_equal(1, PlayerConnection.count(:conditions => "bz_server_id = #{@bz_server.id} and part_at is null"))
    assert_equal(3, @bz_server.current_players.size)
    assert_equal(true, @bz_server.current_players[0].is_verified)
    assert_equal(1, @bz_server.current_players[0].slot_index)
    assert_equal('AAAAAAAAAAA', @bz_server.current_players[0].callsign)
    assert_equal('(BBBBBBBBBBBBBBBBBBBBB)', @bz_server.current_players[0].email)
    assert_equal(false, @bz_server.current_players[0].is_admin)
    assert_equal(false, @bz_server.current_players[1].is_verified)
    assert_equal(2, @bz_server.current_players[1].slot_index)
    assert_equal('CCCCCCC', @bz_server.current_players[1].callsign)
    assert_equal('(DDDDDDDDDDDDDD)', @bz_server.current_players[1].email)
    assert_equal(false, @bz_server.current_players[1].is_admin)
    assert_equal(true, @bz_server.current_players[2].is_verified)
    assert_equal(true, @bz_server.current_players[2].is_admin)
    assert_equal(3, @bz_server.current_players[2].slot_index)
    assert_equal('NNNNN', @bz_server.current_players[2].callsign)
    assert_equal("", @bz_server.current_players[2].email)
  end

  def test_players_zero
    line = '2007-12-29T00:00:04Z PLAYERS (0) '
    # Add a player connection for this server and verify it's still there after processing
    PlayerConnection.create!(:bz_server => @bz_server, :join_at => '2007-10-11', :part_at => nil)
    assert_equal(1, PlayerConnection.count(:conditions => "bz_server_id = #{@bz_server.id} and part_at is null"))
    LogParser.process_line(@server_host, @bz_server, line)
    assert_equal(0, LogMessage.count)
    assert_equal(0, PlayerConnection.count(:conditions => "bz_server_id = #{@bz_server.id} and part_at is null"))
    assert_equal(0, @bz_server.current_players.size)
  end

  def test_players_cleared
    line = '2007-12-29T00:00:04Z PLAYERS (3) [+]11:AAAAAAAAAAA(21:BBBBBBBBBBBBBBBBBBBBB) [ ]7:CCCCCCC(14:DDDDDDDDDDDDDD) [@]5:NNNNN()'
    LogParser.process_line(@server_host, @bz_server, line)
    assert_equal(3, CurrentPlayer.count)
    line = '2007-12-29T00:00:04Z PLAYERS (1) [+]11:XXXXXXXXXXX(21:UUUUUUUUUUUUUUUUUUUUU)'
    LogParser.process_line(@server_host, @bz_server, line)
    assert_equal(1, CurrentPlayer.count)
  end

  def test_missing_date
    line = '2007-12-28T01:22:05Z some random debug output goes here'
    LogParser.process_line(@server_host, @bz_server, line)
    # That fails to create anything since there is not log token
    assert(0, LogMessage.count)
    # Now create a log without a date and verify it gets the date from the previous log line
    line = 'MSG-BROADCAST 5:ABCDE Some text to broadcast'
    LogParser.process_line(@server_host, @bz_server, line)
    
    lm = LogMessage.find(:first)
    assert_not_nil(lm)
    assert_not_nil(lm.logged_at)
    assert_equal('2007-12-28T01:22:05Z', lm.logged_at.strftime('%Y-%m-%dT%H:%M:%SZ'))
    lt = LogType.find_by_token("MSG-BROADCAST")
    assert_not_nil(lt)
    assert_equal(lt.id, lm.log_type_id)
    assert_equal(@bz_server.id, lm.bz_server_id)
  end

  def test_multiple_player_joins_no_part
    line = '2007-12-29T00:00:04Z PLAYER-JOIN 7:widgets #2 RED  IP:1.2.4.7'
    LogParser.process_line(@server_host, @bz_server, line)
    pc = PlayerConnection.find(:first)
    assert_not_nil(pc)
    line = '2007-12-29T00:10:04Z PLAYER-JOIN 7:widgets #4 RED  IP:1.2.4.8'
    LogParser.process_line(@server_host, @bz_server, line)
    pc.reload
    assert_not_nil(pc.part_at)
  end

  def test_player_join_unknown_team
    line = '2005-06-10T14:40:26Z PLAYER-JOIN 8:ABCDEFGH #11 UNKNOWN IP:10.237.7.91'
    LogParser.process_line(@server_host, @bz_server, line)
    pc = PlayerConnection.find(:first)
    assert_not_nil(pc)
    assert_not_nil(pc.callsign)
    assert_equal("ABCDEFGH", pc.callsign.name)
    assert_equal(11, pc.slot)
    assert_not_nil(pc.team)
    assert_equal("UNKNOWN", pc.team.name)
    assert_not_nil(pc.ip)
    assert_equal("10.237.7.91", pc.ip.ip)
  end

  def test_player_join_no_part_same_slot
    line = '2007-12-29T00:00:04Z PLAYER-JOIN 7:widgets #2 RED  IP:1.2.4.7'
    LogParser.process_line(@server_host, @bz_server, line)
    pc = PlayerConnection.find(:first)
    assert_not_nil(pc)
    line = '2007-12-29T00:10:04Z PLAYER-JOIN 7:getwids #2 BLUE IP:1.2.4.8'
    LogParser.process_line(@server_host, @bz_server, line)
    pc.reload
    assert_not_nil(pc.part_at)
    assert_equal(2, PlayerConnection.count)
  end
end
