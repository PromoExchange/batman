# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
$('.tree-toggle').click ->
  $(this).parent().children('ul.tree').toggle 200
  return
