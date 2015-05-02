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

        #loopme = 0
        #do checkLoop = ->
        #  console.log("CheckLoop:"+loopme)
        #  loopme += 1
        #  setTimeout checkLoop, 500 unless loopme > 4

        #@checkServer()
        #Try aagain 1 second later, 2 seconds later too in case app takes time
        @statusMessage.textContent = "..."

        setTimeout @checkServer(), 1000
        setTimeout @checkServer(), 2000
        setTimeout @checkServer(), 3000


  checkServer:->


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

                    txt = response['Status']
                    this.daddy.statusMessage.textContent = " SHADER: "+txt
                    console.log "Status is:"+txt


                    #Error shows as "ERROR: 0:22:'some message'"
                    if txt.indexOf("ERROR:")!=-1
                      parts = txt.split(':')
                      if parts.length > 3
                        pos = parts[2]
                        console.log("Error in shader at line:"+pos)
                        editor = atom.workspace.getActivePaneItem()
                        editor.setCursorBufferPosition([pos-1,0])
                      else
                        console.log("wrong number of parts in error "+parts.length)

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
    message.textContent = "..."
    message.classList.add('shaderInfo')
    @statusMessage = message
    statusBar.addRightTile(item: message, priority: 100)
    @checkServer()

  deactivate: ->
    @subscriptions.dispose()
    @statusBarTile?.destroy()
    @statusBarTile = null
