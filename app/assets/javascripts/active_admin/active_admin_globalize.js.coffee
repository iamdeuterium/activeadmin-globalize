$ ->
  $(".available-locales-switch a").on 'click', (e) ->
    $container = if $(this).closest('legend').length > 0
      $(this).parents('fieldset')
    else
      $(this).parents('.activeadmin-translation-input')

    $container.find("fieldset").hide()
    $container.find("fieldset" + $(this).attr('href')).show()

    $container.find('.available-locales-switch a').removeClass('locale-current')
    $(this).addClass('locale-current')

    e.preventDefault()


  translations = ->
    $(".activeadmin-translations > ul").each ->
      $dom = $(this)
      if !$dom.data("ready")
        $dom.data("ready", true)
        $tabs = $("li > a", this)
        $contents = $(this).siblings("fieldset")

        $tabs.click ->
          $tab = $(this)
          $tabs.not($tab).removeClass("active")
          $tab.addClass("active")
          $contents.hide()
          $contents.filter($tab.attr("href")).show()
          false

        $tabs.eq(0).click()

        $tabs.each ->
          $tab = $(@)
          $content = $contents.filter($tab.attr("href"))
          containsErrors = $content.find(".input.error").length > 0
          $tab.toggleClass("error", containsErrors)

  # this is to handle elements created with has_many
  $("a").bind "click", ->
    setTimeout(
      -> translations()
      50
    )

  translations()

