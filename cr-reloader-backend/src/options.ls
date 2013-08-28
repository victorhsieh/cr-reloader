save_option = ->
  localStorage['dev_mode'] = document.getElementById('dev_mode').checked

document.addEventListener 'DOMContentLoaded', ->
  checkbox = document.getElementById 'dev_mode'
    ..checked = localStorage['dev_mode'] === 'true'
    ..onchange = save_option
