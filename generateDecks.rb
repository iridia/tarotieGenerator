#!/usr/bin/ruby

#	generateDecks.rb
#	Evadne Wu at Iridia, 2010

require 'rubygems'

gem 'plist', '~> 3.1.0'
require 'Plist'

require "./lib.romanNumeral.rb"










#	Data

	Deck = {
	
		"Title" => "Rider-Smith-Waite",
		"Reversible" => true,
		"Dimensions" => [320, 520],
	
		"Major Arcana" => [
		
			"The Fool", "The Magician", "The High Priestess", "The Empress", "The Emperor", "The Hierophant", "The Lovers", "The Chariot", "Strength", "The Hermit", "Wheel of Fortune", "Justice", "The Hanged Man", "Death", "Temperance", "The Devil", "The Tower", "The Star", "The Moon", "The Sun", "Judgement", "The World"
			
		], "Minor Arcana" => {
		
			"Sets" => ["Wands", "Pentacles", "Cups", "Swords"],
			"Personae" => ["Ace", "Two", "Three", "Four", "Five", "Six", "Seven", "Eight", "Nine", "Ten", "Page", "Knight", "Queen", "King"]
		
		}
	
	}










#	Helpers

	def card (title, sequelString, sequelNumber, alignment = "Major Arcana") {
		
		"title" => title,
		"sequelString" => sequelString.to_s,
		"sequelNumber" => sequelNumber.to_i,
		"alignment" => alignment,
		"relativeImagePathURL" => "#{strip(alignment)}-#{strip(title)}.png"
		
	} end
	
	
	
	
	
	def strip (input = "", regex = /[^a-zA-Z0-9]/, substitute = '.')
	
		input.to_s.gsub(regex, substitute).gsub(Regexp.new("[#{substitute}]+"), substitute)
	
	end




















#	Output

	Output = {
	
		"Predicate" => {
	
			:title => "Rider-Smith-Waite",
			:reversible => true,
			:dimensions => Deck['Dimensions']
	
		}, 
		
		"Sequels" => []
		
	}





#	Major Arcana

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





#	Minor Arcana

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





puts Output.to_plist









