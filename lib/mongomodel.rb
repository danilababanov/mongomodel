require 'active_support'
require 'active_model'
require 'mongo'

require 'mongomodel/core_extensions'
require 'mongomodel/exceptions'

module MongoModel
  autoload :Document,         'mongomodel/document'
  autoload :EmbeddedDocument, 'mongomodel/embedded_document'
  
  autoload :Properties,       'mongomodel/properties'
  autoload :Attributes,       'mongomodel/attributes'
  autoload :AttributeMethods, 'mongomodel/attribute_methods'
  autoload :Types,            'mongomodel/types'
  
  autoload :Finders,          'mongomodel/finders'
  autoload :FinderOperator,   'mongomodel/finders'
  autoload :Finder,           'mongomodel/finders'
  
  autoload :Scopes,           'mongomodel/scopes'
  autoload :Scope,            'mongomodel/scopes'
  
  autoload :PrettyInspect,    'mongomodel/pretty_inspect'
  
  module AttributeMethods
    autoload :Read,           'mongomodel/attribute_methods/read'
  end
  
  module Attributes
    autoload :Store,          'mongomodel/attributes/store'
    autoload :Typecasting,    'mongomodel/attributes/typecasting'
    autoload :Mongo,          'mongomodel/attributes/mongo'
  end
  
  def self.database
    @database ||= Mongo::Connection.new.db("mydb")
  end
end
