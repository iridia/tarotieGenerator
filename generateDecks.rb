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

xcode = Xcode.new










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
		
		end
		
		def self.setDeck (deckName = "")
		
			@@deckName = deckName
			@@deckDirectory = "#{@@deckRootPath}/#{deckName}"
		
		end
		
		def self.setDestination (destination = "")
		
			@@resourceDestination = destination
		
		end

		def self.process (options)
		
			xcode = Xcode.new
			
			cardDeck = @@deckName
			cardTitle = options['title'] || ""
			cardSequelString = options['sequelString'] || ""
			cardSequelNumber = options['sequelNumber'] || ""
			cardAlignment = options['alignment'] || ""	

			cardImageName = "#{strip(cardAlignment)}#{cardAlignment.empty? ? "" : "-"}#{strip(cardTitle)}"
			finalCardImageName = "#{strip(cardAlignment, "-")}#{cardAlignment.empty? ? "" : "-"}#{strip(cardTitle, "-")}"

			cardImageExtension = "png"
			
			cardImagePath = "#{@@deckDirectory}/#{cardImageName}.#{cardImageExtension}"
			cardImagePath2x = "#{@@deckDirectory}/#{cardImageName}@2x.#{cardImageExtension}"
			finalCardImagePath = "#{@@resourceDestination}/Deck-#{@@deckName}-#{finalCardImageName}.#{cardImageExtension}"
			finalCardImagePath2x = "#{@@resourceDestination}/Deck-#{@@deckName}-#{finalCardImageName}@2x.#{cardImageExtension}"

			responseObject = nil	
			
			if (!(File.file? cardImagePath))

				xcode.warn "Original artwork for card #{cardTitle} does not exist.  This card will not show."
				xcode.warn "#{cardImagePath}"
				
			else
			
				File.copy(cardImagePath, finalCardImagePath)
			
				responseObject = {
			
					"title" => cardTitle,
					"sequelString" => cardSequelString.to_s,
					"sequelNumber" => cardSequelNumber.to_i,
					"alignment" => cardAlignment,
					"imageName" => finalCardImageName

				}
				
				xcode.log "Copy Deck-#{@@deckName}-#{finalCardImageName}.#{cardImageExtension}"
			
			end
			
			if (File.file? cardImagePath2x) 

				File.copy(cardImagePath2x, finalCardImagePath2x)
				xcode.log "Copy Deck-#{@@deckName}-#{finalCardImageName}@2x.#{cardImageExtension}"
			
			end
				
			
			return responseObject
			
		end
	
	end










#	Bail on nil argument / empty directory

	if ( ARGV.empty? | ARGV[0].nil? | ARGV[1].nil?)
	
		xcode.error "Usage: generateDecks.rb <PathToDecks> <PathToResources>."
		exit
	
	end
	
	[ARGV[0], ARGV[1]].each { |directoryPath|
	
		next if (File.directory? directoryPath)
	
		xcode.log "#{directoryPath} will be created."
		File.mkpath directoryPath
	
	}





#	Wiring

	TAROTIE_GENERATOR_DECKS_DIRECTORY = ARGV[0]
	TAROTIE_GENERATOR_DESTINATION_DIRECTORY = ARGV[1]
	Card.setDeckRoot(TAROTIE_GENERATOR_DECKS_DIRECTORY)
	Card.setDestination(TAROTIE_GENERATOR_DESTINATION_DIRECTORY)
	
	xcode.log "Generating Decks."
	xcode.log "Decks Root: #{TAROTIE_GENERATOR_DECKS_DIRECTORY}"
	xcode.log "Destination: #{TAROTIE_GENERATOR_DESTINATION_DIRECTORY}"
	
	
	
	
	
	DECKS.each_pair { |theDeckName, theDeck|
	
		xcode.groupStart "Deck: #{theDeckName}"
		Card.setDeck(theDeckName)
		
		if (!(File.directory? "#{TAROTIE_GENERATOR_DECKS_DIRECTORY}/#{theDeckName}"))
	
			xcode.error "Deck #{theDeckName} does not seem to have its own directory.  This deck will not be processed."
			xcode.groupEnd
			next
		
		end
		
		if (!DECKS[theDeckName])
		
			xcode.error "Deck #{theDeckName} does not have its own predicate.  This deck will not be processed."
			xcode.groupEnd
			next
	
		end
	
	
	
	
	
	#	Wiring stuff up
	
		
		
		
		
		
	
	#	Scaffold
		
		theOutput = {
		
			:Predicate => {},
			:Sequels => []
			
		}
		
		
		
		
	
	#	Predicates
		
		theDeck.each_pair { |key, value|
		
			next if key == "Cards"
			theOutput[:Predicate][key] = value
		
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
			
			next if (theCard == nil)
							
			majorArcana.push(theCard)
		
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
				
				next if (theCard == nil)
			
				theSequel.push(theCard)
				
			}
			
			theOutput[:Sequels].push(
		
				"Alignment" => 'Minor Arcana',
				"Cards" => theSequel,
				"Name" => theSetName,
				"Sequel" => theSetName
			
			)
		
		}

	#	Save
		
		Plist::Emit.save_plist(theOutput, "#{TAROTIE_GENERATOR_DESTINATION_DIRECTORY}/Deck-#{theDeckName}-Predicate.plist")
		xcode.log "Create Deck-#{theDeckName}-Predicate.plist"
		
		xcode.groupEnd
	
	}





	#	Shared Deck
	
	xcode.groupStart "Processing the Shared deck."
	
		Card.setDeck("Shared")
		
		Card.process({
		
			"title" => "Placeholder"
		
		})
		
		Card.process({
		
			"title" => "Empty"
		
		})
	
	xcode.groupEnd









