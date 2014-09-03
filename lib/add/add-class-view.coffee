{View, EditorView} = require 'atom'
StudioAPI= require 'StudioAPI'
fs= require 'fsplus' # JSON fsplus
module.exports =
class AddClassView extends View
  @Data:null
  @content: ->
      @div class: 'cache-modal-dialog overlay from-top', =>
        @div class: "panel", =>
          @h1 "Create Cache' Class", class: "panel-heading"
        @div class: 'block', =>
          @label 'Package name'
          @subview 'PackageName', new EditorView(mini: true)
        @div class: 'block', =>
          @label 'Class name'
          @subview 'ClassName', new EditorView(mini: true)
        @div class: 'block', =>
          @label 'Super'
          @subview 'Extends', new EditorView(mini: true)
        @div class: 'block', =>
          @label 'Description'
          @subview 'Description', new EditorView(mini: true)
        @ul class: 'error-messages block', =>
          @li outlet:'ErrorMessages'
        @div class: 'block', =>
          @div class: 'btn-group', =>
            @button "OK", outlet:'OKButton', class:'btn'
            @button "Cancel", outlet:'CancelButton', class:'btn'

  initialize:  ->
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
    @bind(this)
    @Data=fs.readJSON(atom.packages.resolvePackagePath('cache-studio')+'/.config');

  serialize: ->
  destroy: ->
    @detach()
  toggle: ->
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
  CreateClass: (status) ->
    PackageName=@PackageName.getEditor().getText()
    ClassName=@ClassName.getEditor().getText()
    Description=@Description.getEditor().getText()
    Extends=@Extends.getEditor().getText()

    StudioAPI.NewClass.data.namespace=@Data.NameSpace
    StudioAPI.NewClass.data.nameClass="#{PackageName}.#{ClassName}"
    StudioAPI.NewClass.data.Super=Extends
    StudioAPI.NewClass.data.Description=Description
    StudioAPI.createclass (status) =>
      if status=='1'
        uri=@Data.TempDir+'/Classes/'+PackageName.replace('.','/')+'/'+ClassName+'.cls'
        atom.workspace.open(uri, split: 'left', searchAllPanes: true)
        @destroy()
      else
        @ErrorMessages.html(status)

  # Buttons events
  bind: (e) ->
    @OKButton.on 'click', ->
      if e.PackageName.getEditor().getText()!='' && e.ClassName.getEditor().getText()!=''
        e.CreateClass (status) =>
          if status=='1'
            console.log ''
      else
        e.ErrorMessages.html('Error')
    @CancelButton.on 'click', ->
      e.destroy()
