//= require_tree ./vendor
//= require_self

window.App =
  findBooks: (term, offset=0, callback) ->
    results = []
    App.get("/#{term}", offset, callback)

  cache: {}
  cachedFindBooks: (term, offset=0, callback) ->
    cacheKey = "#{term}#{offset}"
    if App.cache[cacheKey]
      callback App.cache[cacheKey]
    else
      App.findBooks term, offset, (books) =>
        App.cache[cacheKey] = books
        callback(books)

  booksFromLines: (lines) ->
    books = []
    i = 0

    while i < lines.length
      s = lines[i].split("\t")
      books.push s  if s.length > 1
      i++
    books

  lastPosition: 0
  clearBooks: ->
    App.lastPosition = 0
    App.isLoading = false
    $(".books").html ""

  addBook: (book) ->
    downloads = book[0]
    id = parseInt(book[1])
    title = book[2]
    creator = book[3] or ""
    
    #var x = creator.split(",");
    #creator = (x[1] || "") + " " +  (x[0] || "");
    color = "color" + id % 5
    link = "http://www.gutenberg.org/ebooks/" + id
    epub = link + ".epub"
    cut = 50 - (Math.random() * 100)
    readmillHtml = "<div class=\"buttons\"><div class=\"send-to-readmill\" data-download-url=\"http://www.gutenberg.org/ebooks/" + id + ".epub\" data-buy-url=\"http://www.gutenberg.org/ebooks/\"" + id + " data-display=\"small\" ></div></div>"
    
    #var readmillHtml = '<div class="buttons"><iframe src="https://widgets.readmill.com/send?alt=a&amp;download_url=EPUB&amp;buy_url=LINK&amp;display=small&amp;origin_domain=http%3A%2F%2FORIGIN" style="top: 0px !important; left: 0px !important; width: 72px !important; height: 26px !important; margin: 0px !important; border: none !important; position: static !important; background-size: 100% !important; background-color: transparent !important; background-image: url(http://d3kdyw6hgzoh5r.cloudfront.net/assets/widgets/btn_str_small-05a10061a2250cba9d18f9e22ec5e87a.png) !important; background-position: 0px 0px !important; background-repeat: no-repeat no-repeat !important;" data-str-size="small" tabindex="0" scrolling="no" frameborder="0" class="send-to-readmill"></iframe></div>'
    #readmillHtml = readmillHtml.replace("LINK", encodeURIComponent(link));
    #readmillHtml = readmillHtml.replace("EPUB", encodeURIComponent(epub));
    html = "<li class=\"book " + color + "\"><h2 class=\"creator\"><a href=\"" + link + "\" target=\"_blank\">" + creator + "</a></h2><h2 class=\"title\"><a href=\"" + link + "\" target=\"_blank\">" + title + "</a></h2>" + readmillHtml + "<div class=\"corner\"></div></li>"
    $el = $(html).appendTo(".books")
    $el.attr "data-orig", book.join(";")
    App.setCutCSS $el.find(".corner"), cut

  addBooks: (books) ->
    i = 0

    while i < books.length
      App.addBook books[i]
      i++
    window.Readmill.SendToReadmill.build()

  setCutCSS: ($el, cut) ->
    $el.attr "data-cut", cut
    $el.css
      "border-right": Math.abs(cut) + "px solid #F2F1E6"
      top: ((if cut < 0 then "-120px" else "0px"))

  getTerm: ->
    $(".search").val()

  onChange: ->
    newTerm = App.getTerm()
    unless App.lastTerm is newTerm
      url = "/#{encodeURIComponent(newTerm)}".replace(/%20/g, "-")
      window.history.replaceState({}, document.title, url)
      App.lastTerm = newTerm
      App.clearBooks()
      App.cachedFindBooks newTerm, 0, (books) ->
        if newTerm == App.getTerm() # check if search term is already outdated
          if books.length == 0 && $("ul").is(":empty")
            $("ul").html("Sorry, no books found...")
          else
            App.addBooks books
        else
          console.log("outdated, don't add")

  loadMore: (callback) ->
    term = App.getTerm()
    App.lastPosition += 10
    App.cachedFindBooks term, App.lastPosition, (books) ->
      App.addBooks books
      callback()

  get: (term, offset=0, callback) ->
    console.log("get", term)
    $.ajax
      url: "#{term}?offset=#{offset}"
      dataType: "json"
      success: (books) ->
        callback(books)

$ ->
  $(".search").focus()
  $(".search").on("change", App.onChange).on "keyup", App.onChange

  App.isLoading = false
  $(window).scroll ->
    console.log $(window).scrollTop(), $(document).height() - $(window).height() - 10
    if $(window).scrollTop() >= $(document).height() - $(window).height() - 10
      unless App.isLoading
        App.isLoading = true
        App.loadMore ->
          App.isLoading = false

