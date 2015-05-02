{CompositeDisposable} = require 'atom'


module.exports = Exoshader =
  subscriptions: null
  statusMessage: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    console.log("exoshader  Activated, adding commands")
    @subscriptions = new CompositeDisposable
    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', "exoshader:testinsert", => @testinsert()
    @subscriptions.add atom.commands.add 'atom-workspace', "exoshader:testconvert", => @testconvert()

    @editorsSubscription = atom.workspace.observeTextEditors (editor) =>
      disposable = editor.onDidSave =>
        console.log("FILE was saved must check status of shader!");


        @statusMessage.textContent = "..."

        #request.get { uri:, json: true }, (err, r, body) -> results = body
        theUrl = 'http://localhost:55556/status'
        xhr = new XMLHttpRequest
        xhr.daddy = this
        xhr.open "GET", theUrl, true
        xhr.onreadystatechange = ->
            if xhr.readyState is 4
                if xhr.status is 200
                    console.log "Server replied"
                    response = JSON.parse xhr.responseText
                    console.log response
                    this.daddy.statusMessage.textContent = " SHADER: "+response['Status']
                else
                    this.daddy.statusMessage.textContent = " SHADER: NOSRV :-("

        xhr.send(); 

        #buffer = editor.getBuffer()
        #return unless buffer.isModified()



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

  consumeStatusBar: (statusBar) ->
    console.log("setting statusbar content");

    # Create message element
    message = document.createElement('span')
    message.textContent = "SHADER INFO on next save"
    message.classList.add('shaderInfo')
    @statusMessage = message
    statusBar.addRightTile(item: message, priority: 100)


  deactivate: ->
    @subscriptions.dispose()
    @statusBarTile?.destroy()
    @statusBarTile = null
