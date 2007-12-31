require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../../lib/log_parser'

class LogParserTest < Test::Unit::TestCase

  # Replace this with your real tests.
  def test_truth
    assert true
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

  def test_get_message
    msg_text = "This is a test message"
    msg = LogParser.get_message(msg_text)
    assert_equal(msg_text, msg.text)
    assert_not_nil(msg.id)
  end

  def test_get_dup_message
    msg1_text = "This is a message"
    msg2_text = msg1_text
    msg1 = LogParser.get_message(msg1_text)
    msg2 = LogParser.get_message(msg2_text)
    assert_equal(msg1_text, msg1.text)
    assert_equal(msg2_text, msg2.text)
    assert_equal(msg1.id, msg2.id)
  end

  def test_get_nodup_message
    msg1_text = "This is a message"
    msg2_text = "Another message"
    msg1 = LogParser.get_message(msg1_text)
    msg2 = LogParser.get_message(msg2_text)
    assert_not_equal(msg1_text, msg2_text)
    assert_equal(msg1_text, msg1.text)
    assert_equal(msg2_text, msg2.text)
    assert_not_equal(msg1.id, msg2.id)
  end

  def test_get_team
    team_name = "PURPLE"
    team_text = "#{team_name} more stuff"
    team, detail = LogParser.get_team(team_text)
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

  def test_parse_player_email
    data = '[+]9:Bad Sushi() [+]10:spatialgur(15:spatialguru.com) [@]12:drunk driver()
'
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
end
