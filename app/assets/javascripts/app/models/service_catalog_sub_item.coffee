class App.ServiceCatalogSubItem extends App.Model
  @configure 'ServiceCatalogSubItem', 'name'
  @extend Spine.Model.Ajax
  @url: @apiPath + '/service_catalog_sub_item'
