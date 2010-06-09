#!/usr/bin/ruby

#	generateDecks.rb
#	Evadne Wu at Iridia, 2010

require 'find'
require 'rubygems'

gem 'plist', '~> 3.1.0'
require 'Plist'

require "#{File.expand_path(File.dirname(__FILE__))}/lib.XcodeBuildLogBridge/lib.XcodeBuildLogBridge.rb"
require "#{File.expand_path(File.dirname(__FILE__))}/lib.romanNumeral.rb"










#	Information

DECKS = {

	"Rider-Smith-Waite" => {
	
		"AllowReversals" => true,
		"Dimensions" => [320, 520],
		"Cards" => {
	
			"Major Arcana" => [
	
				"The Fool", "The Magician", "The High Priestess", "The Empress", "The Emperor", "The Hierophant", "The Lovers", "The Chariot", "Strength", "The Hermit", "Wheel of Fortune", "Justice", "The Hanged Man", "Death", "Temperance", "The Devil", "The Tower", "The Star", "The Moon", "The Sun", "Judgement", "The World"
				
			], "Minor Arcana" => {
			
				"Sets" => ["Wands", "Pentacles", "Cups", "Swords"],
				"Personae" => ["Ace", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Page", "Knight", "Queen", "King"]
			
			}
		
		}
	
	}

}

xcode = Xcode.new










#	Bail on nil argument / empty directory

if ( ARGV.empty? || ARGV[0].empty?)

	xcode.warn "please call generateDecks.rb with 1 argument that is the absolute path pointing to the Decks directory."

end

puts "#{ARGV[0]}: No such directory." if !(File.directory? ARGV[0])





TAROTIE_GENERATOR_DECKS_DIRECTORY = ARGV[0]
xcode.log "Generating Decks using #{TAROTIE_GENERATOR_DECKS_DIRECTORY} as the root reference."





DECKS.each_pair { |theDeckName, theDeck|

	xcode.groupStart "Generating predicate about deck #{theDeckName}"
	
	if (!(File.directory? "#{TAROTIE_GENERATOR_DECKS_DIRECTORY}/#{theDeckName}"))

		xcode.error "Deck #{theDeckName} does not seem to have its own directory."
		xcode.groupEnd
	
	end
	
	xcode.log "Checking if directory exists…"
	
	#	Check if this directory exists
	
	xcode.groupEnd

}





#	Helpers

	def card (title, sequelString, sequelNumber, alignment = "Major Arcana") {
		
		"title" => title,
		"sequelString" => sequelString.to_s,
		"sequelNumber" => sequelNumber.to_i,
		"alignment" => alignment,
		"imageName" => "#{strip(alignment)}-#{strip(title)}"
		
	} end
	
	
	
	
	
	def strip (input = "", regex = /[^a-zA-Z0-9]/, substitute = '.')
	
		input.to_s.gsub(regex, substitute).gsub(Regexp.new("[#{substitute}]+"), substitute)
	
	end




















exit

	Output = {
	
		"Predicate" => Deck['Predicate'], 
		"Sequels" => []
		
	}





	majorArcana = []
	
	Deck['Major Arcana'].each_index { |cardIndex|
	
		majorArcana.push(card(
		
			Deck['Major Arcana'][cardIndex], 
			cardIndex.to_i.to_roman, 
			cardIndex.to_i,
			"Major Arcana"
		
		))
	
	}
	
	Output['Sequels'].push(
	
		"Alignment" => "Major Arcana",
		"Cards" => majorArcana,
		"Name" => "Major Arcana",
		"Sequel" => "Major Arcana"
	
	)





	Deck['Minor Arcana']['Sets'].each { |theSetName|
	
		sequel = []

		Deck['Minor Arcana']['Personae'].each_with_index { |cardValue, cardIndex|
		
			sequel.push(card(
			
				"#{Deck['Minor Arcana']['Personae'][cardIndex]} of #{theSetName}",
				cardValue,
				cardIndex,
				'Minor Arcana'
				
			))
			
		}
		
		Output['Sequels'].push(
	
			"Alignment" => 'Minor Arcana',
			"Cards" => sequel,
			"Name" => theSetName,
			"Sequel" => theSetName
		
		)
	
	}





# puts Output.to_plist









