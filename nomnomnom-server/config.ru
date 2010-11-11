$:.unshift(File.expand_path(File.dirname(__FILE__) + '/lib/'))
$:.unshift(File.expand_path(File.dirname(__FILE__)))
$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../nomnomnom-client/lib'))

require 'nom_nom_nom/server'

run NomNomNom::Server::Application