#!/usr/bin/ruby

#	generateDecks.rb
#	Evadne Wu at Iridia, 2010

require 'find'
require 'ftools'
require 'rubygems'

gem 'plist', '~> 3.1.0'
require 'Plist'

require "#{File.expand_path(File.dirname(__FILE__))}/lib.XcodeBuildLogBridge/lib.XcodeBuildLogBridge.rb"
require "#{File.expand_path(File.dirname(__FILE__))}/lib.romanNumeral.rb"

TAROTIE_DECKS_DIRECTORY_NAME = "Decks"




















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




















#	Helper

	def strip (input = "", substitute = '.', regex = /[^a-zA-Z0-9]/)
	
		input.to_s.gsub(regex, substitute).gsub(Regexp.new("[#{substitute}]+"), substitute)
	
	end
	
	
	
	
	
	class Card

		@@deckRootPath = "";
		@@deckDirectory = "";
		@@deckName = "";
		@@resourceDestination = "";
		
		def self.setDeckRoot (deckRootPath = "")
		
			@@deckRootPath = deckRootPath
			
			return self
		
		end
		
		def self.setDeck (deckName = "", deckType = "png")
		
			@@deckName = deckName
			@@deckDirectory = "#{@@deckRootPath}/#{deckName}"
			@@deckType = deckType

			return self
		
		end
		
		def self.setDestination (destination = "")
		
			@@resourceDestination = destination
			
			return self
		
		end
		
		
		
		
		
		def self.process (options)
		
			cardDeck = @@deckName
			cardTitle = options['title'] || ""
			cardSequelString = options['sequelString'] || ""
			cardSequelNumber = options['sequelNumber'] || ""
			cardAlignment = options['alignment'] || ""	

			cardImageName = "#{strip(cardAlignment)}#{cardAlignment.empty? ? "" : "-"}#{strip(cardTitle)}"
			finalCardImageName = "#{strip(cardAlignment, "-")}#{cardAlignment.empty? ? "" : "-"}#{strip(cardTitle, "-")}"

			cardImageExtension = @@deckType || "png"
			
			cardImagePathPrefix = "#{@@deckDirectory}/"
			cardImagePathSuffix = ".#{cardImageExtension}"
			cardImagePathSuffix2x = "@2x.#{cardImageExtension}"
			
			cardImagePath = "#{cardImagePathPrefix}#{cardImageName}#{cardImagePathSuffix}"
			cardImagePath2x = "#{cardImagePathPrefix}#{cardImageName}#{cardImagePathSuffix2x}"
			
			finalCardImagePathPrefix = "#{@@resourceDestination}/Deck-#{@@deckName}-"
			
			finalCardImagePath = "#{finalCardImagePathPrefix}#{finalCardImageName}#{cardImagePathSuffix}"
			finalCardImagePath2x = "#{finalCardImagePathPrefix}#{finalCardImageName}#{cardImagePathSuffix2x}"
			
			return nil if !Xcode.assert((File.file? cardImagePath), "Original artwork for card #{cardTitle} does not exist at #{cardImagePath}.  This card will not show.")
						
			File.copy(cardImagePath, finalCardImagePath)
			File.copy(cardImagePath2x, finalCardImagePath2x) if (File.file? cardImagePath2x)
			
			return {
		
				"title" => cardTitle,
				"sequelString" => cardSequelString.to_s,
				"sequelNumber" => cardSequelNumber.to_i,
				"alignment" => cardAlignment,
				"imageName" => finalCardImageName

			}
			
		end
	
	end




















#	Bail on nil argument / empty directory

	exit if !Xcode.assert(
	
		!(ARGV.empty? | ARGV[0].nil? | ARGV[1].nil?), 
		
		"Usage: generateDecks.rb <PathToDecks> <PathToResources>."
		
	)
	
	
	
	
	
	[ARGV[0], ARGV[1]].each { |directoryPath|
	
		next if (File.directory? directoryPath)
	
		Xcode.log "#{directoryPath} will be created."
		File.mkpath directoryPath
	
	}





	TAROTIE_GENERATOR_DECKS_DIRECTORY = ARGV[0]
	TAROTIE_GENERATOR_DESTINATION_DIRECTORY = ARGV[1]

	Card.setDeckRoot(TAROTIE_GENERATOR_DECKS_DIRECTORY).setDestination(TAROTIE_GENERATOR_DESTINATION_DIRECTORY)
	
	Xcode.log "Decks Root: #{TAROTIE_GENERATOR_DECKS_DIRECTORY}"
	Xcode.log "Destination: #{TAROTIE_GENERATOR_DESTINATION_DIRECTORY}"
	
	
	
	
	
	DECKS.each_pair { |theDeckName, theDeck|
	
		next if !Xcode.assert((File.directory? "#{TAROTIE_GENERATOR_DECKS_DIRECTORY}/#{theDeckName}"), "Deck #{theDeckName} does not seem to have its own directory.  This deck will not be processed.")
		
		next if !Xcode.assert(DECKS[theDeckName] != nil, "Deck #{theDeckName} does not have its own predicate.  This deck will not be processed.")
			
	
	
	
	
		Xcode.groupStart "Deck: #{theDeckName}"

		Card.setDeck(theDeckName, "jpg")





	#	Scaffold
		
		theOutput = {
		
			:Predicate => {},
			:Sequels => []
			
		}
		
		
		
		
	
	#	Predicates
		
		theDeck.each_pair { |key, value|
		
			theOutput[:Predicate][key] = value if key != "Cards"
		
		}
		
		
		
		
	
	#	Major Arcana
	
		majorArcana = []
	
		theDeck['Cards']['Major Arcana'].each_index { |cardIndex|
		
			cardName = theDeck['Cards']['Major Arcana'][cardIndex]
		
			theCard = Card.process({
			
				"title" => cardName, 
				"sequelString" => cardIndex.to_i.to_roman, 
				"sequelNumber" => cardIndex.to_i,
				"alignment" => "Major Arcana"
				
			})
			
			majorArcana.push(theCard) if (theCard != nil)
		
		}
		
		theOutput[:Sequels].push(
	
			"Alignment" => "Major Arcana",
			"Cards" => majorArcana,
			"Name" => "Major Arcana",
			"Sequel" => "Major Arcana"
		
		)
		
		
		
		
	
	#	Minor Arcana
	
		theDeck['Cards']['Minor Arcana']['Sets'].each { |theSetName|
	
			theSequel = []
	
			theDeck['Cards']['Minor Arcana']['Personae'].each_with_index { |cardValue, cardIndex|
			
				theCard = Card.process({
				
					"title" => "#{theDeck['Cards']['Minor Arcana']['Personae'][cardIndex]} of #{theSetName}",
					"sequelString" => cardValue,
					"sequelNumber" => cardIndex,
					"alignment" => "Minor Arcana"
				
				})
				
				theSequel.push(theCard) if (theCard != nil)
				
			}
			
			theOutput[:Sequels].push(
		
				"Alignment" => 'Minor Arcana',
				"Cards" => theSequel,
				"Name" => theSetName,
				"Sequel" => theSetName
			
			)
		
		}

	#	Save
		
		Xcode.log "Create Deck-#{theDeckName}-Predicate.plist"

		Plist::Emit.save_plist(theOutput, "#{TAROTIE_GENERATOR_DESTINATION_DIRECTORY}/Deck-#{theDeckName}-Predicate.plist")
		
		
		
		
		
		Xcode.groupEnd
	
	}





	#	Shared Deck
	
	Xcode.groupStart "Processing the Shared deck."
	
		Card.setDeck("Shared", "png")
		
		Card.process({
		
			"title" => "Placeholder"
		
		})
		
		Card.process({
		
			"title" => "Empty"
		
		})
	
	Xcode.groupEnd









