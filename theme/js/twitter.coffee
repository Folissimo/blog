_.templateSettings =
  interpolate: /\{\{(.+?)\}\}/g
  evaluate: /\{\[(.+?)\]\}/g
class Twitter

  constructor : (config) ->
    @defs =
      destination: $('.latestTweets') # append area for the tweets
      connectionError: 'Connection Error - couldn\'t get tweets'
      twitterUrl : 'http://admin.folissimo.com/json/latestTweets.php'
      textOnly: false # shows text only tweets (ie no links)
      title: '<h3><a href="http://twitter.com/{{screen_name}}">Latest Tweets</a></h3>'
      container: '<ul class="tweets"></ul>'
      tweetRow: '<li class="tweetRow"><span>{{ tweet }}</span><span class="tweetTime">{{ age }}</span></li>'
      callback: (tweetData) -> # callback when tweets loaded
      userid: 1

    $.extend @defs, config

    @getTweetData()

  # fetches tweet data from twitter via
  # folisismo servers
  getTweetData : =>
    $.getJSON @defs.twitterUrl + '?callback=?',
      userid: @defs.userid
    , @renderOverall

  # appends the tweets to destination
  renderOverall : (json)=>
    if not json[0]? or not json[0]
      return @defs.destination.append('<div />')
        .text @defs.connectionError

    # create tweet title

    $title = $ _.template(@defs.title, json[0].user)

    $tweetContainer = $ @defs.container

    # now iterate through tweets and render
    _.each json, (tweet) =>
      @renderTweet tweet, $tweetContainer

    # append the whole set to destination
    @defs.destination.append($title)
      .append $tweetContainer

    if @defs.callback?
      @defs.callback()

  # renders a single tweet row
  renderTweet : (tweet, $container) =>
    data =
      tweet: tweet.text
    # calculate age of tweet
    data.age = @getTweetAge tweet.created_at

    unless @defs.textOnly
      # replace hashtags and
      # screennames with links
      # hashtags:
      data.tweet = data.tweet.replace /#(\S*)/g,'<a href="http://twitter.com/#!/search/$1">#$1</a>'
      # screennames
      data.tweet = data.tweet.replace /\@(\S*)/g, '<a href="http://twitter.com/$1">@$1</a>'

    $tweet = $(_.template(@defs.tweetRow, data))
    $container.append $tweet

    $tweet

  # returns twitter style age since
  # tweet
  getTweetAge : (tweetDate) =>
    twitterDateFormat = 'ddd MMM DD HH:mm:ss Z YYYY'
    parsedDate = moment tweetDate, twitterDateFormat

    now = moment()

    minutesAgo = now.diff(parsedDate, 'minutes')
    hoursAgo = now.diff(parsedDate, 'hours')
    daysAgo = now.diff(parsedDate, 'days')
    monthsAgo = now.diff(parsedDate, 'months')

    return minutesAgo + ' mins' if minutesAgo < 60
    return hoursAgo + ' hrs' if hoursAgo < 24
    return daysAgo + ' days' if daysAgo < 14
    parsedDate.format('D MMM')

$(document).ready ->
  setTimeout ->
    window.twitterData = new Twitter()

  , 3

