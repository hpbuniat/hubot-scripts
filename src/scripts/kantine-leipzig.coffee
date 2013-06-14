# Description
#   Checks the menu of "Kantine Leipzig" and suggests alternatives from time to time
#
# Dependencies
#   scraper: "latest"
#
# Commands
#   mittag?
#   essen?
#   lunch?
#   happen pappen?
#
# Author
#   Hans-Peter Buniat

scraper = require "scraper"
src = "http://www.kantine-leipzig.de/speiseplan.htm"
alts = ["Leo's", "Curry", "Doener", "Pizza"]

parseMenu = (msg) ->
  dow = (new Date).getDay()

  scraper src, (err, $) ->
    msg.send "Unable to get the menu" if err
    throw err if err
    throw new Error ("No menu during the weekend") if dow > 5

    tr = $('div.TabbedPanelsContent:eq(0) tr')

    start = 2 + ((if dow == 0 then dow else dow - 1) * 6)

    res = []
    formatMeal res, tr, (start+i) for i in [0..2]

    msg.send s for s in res
    if (Math.floor(Math.random() * 5) == 5)
      alt = alts[Math.floor(Math.random() * alts.length)]
      msg.send "You may try #{ alt } as alternative!"

formatMeal = (res, tr, i) ->
  tds = tr.eq(i).find('td')
  res.push(tds.eq(0).text().trim() + ': ' + tds.eq(1).text().trim() + ' (' + tds.eq(2).text().trim() + ')' + "\n")

module.exports = (robot) ->
  robot.hear /(mittag|essen|lunch|happen pappen)\?/i, (msg) ->
    msg.send "Wait! I'm fetching the menu from #{ src }"
    try
      res = parseMenu(msg)
    catch e
      msg.send e
