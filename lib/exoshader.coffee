{CompositeDisposable} = require 'atom'


module.exports = Exoshader =
  editorsSubscription: null
  panesSubscription: null
  subscriptions: null
  statusMessage: null

  activate: (state) ->
    # Events subscribed to in atom's system can be easily cleaned up with a CompositeDisposable
    console.log("exoshader  Activated, adding commands")
    @subscriptions = new CompositeDisposable
    # Register command that toggles this view
    @subscriptions.add atom.commands.add 'atom-workspace', "exoshader:reloadview", => @forceFileUpdate()
    @subscriptions.add atom.commands.add 'atom-workspace', "exoshader:testinsert", => @testinsert()
    @subscriptions.add atom.commands.add 'atom-workspace', "exoshader:testconvert", => @testconvert()

    @editorsSubscription = atom.workspace.observeTextEditors (editor) =>
      disposable = editor.onDidChangePath =>
        @updatedSelectedFile(editor)
      disposable = editor.onDidSave =>
        @updatedSelectedFile(editor)
      disposable = editor.onDidChangePath =>
        @updatedSelectedFile(editor)

    @panesSubscription = atom.workspace.onDidChangeActivePaneItem (event) =>
      console.log "Exoshader - Changed active panel"
      @forceFileUpdate()


  forceFileUpdate: ->
    editor = atom.workspace.getActivePaneItem()
    console.log "Exoshader - force file update:"+editor.getPath()
    @updatedSelectedFile(editor)


  updatedSelectedFile: (editor)->
        if @statusMessage is null
          console.log "Cannot update in updateSelected File - status item not ready"
          return

        fext =path.extname(editor.getPath())
        if  fext is ".fs" or fext is ".fsh"
          #editor.setGrammar(atom.grammars.grammarForScopeName('source.smarty'))
          console.log("FILE was saved must check status of shader! File:"+editor.getPath());


          #loopme = 0
          #do checkLoop = ->
          #  console.log("CheckLoop:"+loopme)
          #  loopme += 1
          #  setTimeout checkLoop, 500 unless loopme > 4

          #@checkServer()
          #Try aagain 1 second later, 2 seconds later too in case app takes time
          @statusMessage.textContent = " Server is reloading..."

          @changeFileOnServer(editor.getPath())

        else
         console.log("exoshader ignoring file save with extension:"+fext)

  changeFileOnServer: (fpath)->
        theUrl = 'http://localhost:55556/loadshader/'+encodeURI(fpath)
        xhr = new XMLHttpRequest
        xhr.daddy = this
        xhr.onreadystatechange = ->
            if xhr.readyState is 4
              error = false
              if xhr.status is 200
                 this.daddy.checkServer()
              else
                error=true

              if error
                xhr.daddy.statusMessage.textContent = " SHADER: NOSRV :-("

        xhr.open "GET", theUrl, true
        xhr.send();


  checkServer:->
        #request.get { uri:, json: true }, (err, r, body) -> results = body
        theUrl = 'http://localhost:55556/status'
        xhr = new XMLHttpRequest
        xhr.daddy = this
        xhr.open "GET", theUrl, true
        xhr.onreadystatechange = ->
            if xhr.readyState is 4
                error = false
                if xhr.status is 200
                    console.log "Server replied with"+xhr.responseText
                    try
                      response = JSON.parse xhr.responseText
                      txt = response['Status']

                      #Error shows as "ERROR: 0:22:'some message'"
                      if txt.indexOf("ERROR:")!=-1
                        error=true
                        parts = txt.split(':')
                        if parts.length > 3
                          pos = parts[2]
                          console.log("Error in shader at line:"+pos)
                          editor = atom.workspace.getActivePaneItem()
                          editor.setCursorBufferPosition([pos,0])
                        else
                          console.log("wrong number of parts in error "+parts.length)

                    catch err
                      console.log("JSON parse %s", err);
                      txt ="PARSERRRO"+err
                      error true

                    xhr.daddy.statusMessage.textContent = " SHADER "+txt
                    console.log "Status is:"+txt


                else
                    error = true
                    xhr.daddy.statusMessage.textContent = " SHADER: NOSRV :-("

                #swap color class in case of error
                xhr.daddy.statusMessage.classList.remove('shaderOK')
                xhr.daddy.statusMessage.classList.remove('shaderError')

                if error
                      xhr.daddy.statusMessage.classList.add('shaderError')
                else
                      xhr.daddy.statusMessage.classList.add('shaderOK')




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

    # Create message element in statusBar so we can update it later on save
    message = document.createElement('span')
    message.textContent = "..."
    message.classList.add('shaderOK')
    @statusMessage = message
    statusBar.addRightTile(item: message, priority: 100)
    @checkServer()

  deactivate: ->
    @subscriptions.dispose()
    @panesSubscription.dispose()
    @editorsSubscription.dispose()
    @statusBarTile?.destroy()
    @statusBarTile = null
