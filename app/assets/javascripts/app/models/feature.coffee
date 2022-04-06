class App.Feature extends App.Model
  @configure 'feature', 'name', 'active'
  @extend Spine.Model.Ajax
  @url: @apiPath + '/features'

  # dati delle features popolate da signshow (zammad sessions controller)
  @isDisabled: (featureName) ->
    featureName = featureName.toLowerCase()
    return App.Config.get('features')[featureName] && !App.Config.get('features')[featureName].enabled
 


