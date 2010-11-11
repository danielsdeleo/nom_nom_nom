require 'bundler/setup'
$:.unshift(File.expand_path(File.dirname(__FILE__) + '/../../'))

require 'nom_nom_nom/server'

run NomNomNom::Server::Application