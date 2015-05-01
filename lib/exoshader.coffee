ExoshaderView = require './exoshader-view'
{CompositeDisposable} = require 'atom'

module.exports = Exoshader =
  exoshaderView: null
  modalPanel: null
  subscriptions: null

  activate: (state) ->
    atom.commands.add 'atom-workspace', "exoshader:testinsert", => @testinsert()
    atom.commands.add 'atom-workspace', "exoshader:testconvert", => @testconvert()


  testinsert: ->
    # This assumes the active pane item is an editor
    editor = atom.workspace.getActivePaneItem()
    editor.insertText('Test insert from exoshader!')

  testconvert: ->
    # This assumes the active pane item is an editor
      editor = atom.workspace.getActivePaneItem()
      selection = editor.getLastSelection()

      figlet = require 'figlet'
      figlet selection.getText(), {font: "Larry 3D 2"} , (error, asciiArt) ->
        if error
          console.error(error)
        else
          selection.insertText("\n#{asciiArt}\n")

  toggle: ->
    console.log("Exovshader was toogled")
