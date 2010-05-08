#!/opt/local/bin/ruby

#	generateDecks.rb
#	Evadne Wu at Iridia, 2010





require "lib.romanNumeral.rb"










MAJOR_ARCANA_CARDS = <<-eos

The Fool
The Magician / The Juggler
The High Priestess / The Popess
The Empress
The Emperor
The Hierophant / The Pope
The Lovers
The Chariot
Justice
The Hermit
Wheel of Fortune
Strength / Fortitude
The Hanged Man / The Traitor
Death
Temperance
The Devil
The Tower / Fire
The Star
The Moon
The Sun
Judgement / The Angel
The World

eos





Minor_Arcana_Count = 14
Minor_Arcana_Sets = ["Staves", "Pentacles", "Chalices", "Swords"]





Minor_Arcana_Personae = {

	0 => "Ace",
	1 => "Two",
	2 => "Three",
	3 => "Four",
	4 => "Five",
	5 => "Six",
	6 => "Seven",
	7 => "Eight",
	8 => "Nine",
	9 => "Ten",
	10 => "Prince",
	11 => "Princess",
	12 => "King",
	13 => "Queen"

}




















class CardGenerator

	@@cardsGenerated = 0
	@@cardsGeneratedInSequel = 0
	
	
	
	
	
	@@processingAlignment = ""
	@@processingSequel = ""










#	Session.

	def startSession
	
		@@cardsGenerated = 0
	
		puts <<-eos
		
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
		
		eos
	
	end
	
	def endSession
	
		puts <<-eos
		
</dict>
</plist>
		
		eos
	
	end
	
	
	
	
	
	
	
	
	
	
#	Predicate
	
	def makePredicate(options)
	
		puts <<-eos
		
	<key>Predicate</key>
	<dict>
		<key>Title</key>
		<string>#{options['title']}</string>
		<key>Reversible</key>
		<#{options['reversible']}/>
	</dict>
		
		eos
	
	end
	
	
	
	
	
	




#	Sequels.

	def startSequels
	
		puts <<-eos

	<key>Sequels</key>
	<array>
		
		eos
	
	end
	
	def endSequels
	
		puts <<-eos

	</array>
	
		eos
	
	end










#	Sequel.  Major Arcana, Minor Arcana, etc.
	
	def startSequel(name, alignment = name, sequel = alignment)
	
		@@processingAlignment = alignment;
		@@processingSequel = sequel;
		
		@@cardsGeneratedInSequel = 0;
		
		puts <<-eos
		
		<dict>
			<key>Name</key>
			<string>#{name}</string>
			<key>Alignment</key>
			<string>#{@@processingAlignment}</string>
			<key>Sequel</key>
			<string>#{@@processingSequel}</string>
			<key>Cards</key>
			<array>
		
		eos
	
	end
	
	def endSequel
	
		puts <<-eos

			</array>
		</dict>
		
		eos
	
	end
	
	
	

	
	def generateCard(title)
	
		return if (title.nil? || title.empty?)
	
		#	Generate card here
		
		@@cardsGenerated += 1
		@@cardsGeneratedInSequel += 1
		
		self.generateCardDetailed({
		
			"title" => title, 
			"alignment" => @@processingAlignment,
			"sequel" => @@processingSequel			

		})
	
	end

	def generateCardDetailed(options)
	
		sequelString = (@@processingAlignment == "Major Arcana" ? (@@cardsGeneratedInSequel.to_i - 1).to_roman : @@cardsGeneratedInSequel).to_s
		
		relativeImageURL =	(options['alignment'].gsub /[^a-zA-Z0-9]/, '.') + '-' +
					(options['title'].gsub /[^a-zA-Z0-9]/, '.') + '.png'

		relativeImageURL = 	relativeImageURL.gsub /\.+/, '.'
			
		puts <<-eos
	
			<dict>
			
				<key>title</key>
				<string>#{options['title']}</string>
				
				<key>sequelString</key>
				<string>#{sequelString}</string>
				
				<key>alignment</key>
				<string>#{options['alignment']}</string>
				
				<key>relativeImagePathURL</key>
				<string>#{relativeImageURL}</string>
			
			</dict>
	
		eos
	
	end
	
end




















generator = CardGenerator.new





generator.startSession();

generator.makePredicate({

	"title" => "Waite",
	"reversible" => true

});

	generator.startSequels();





		generator.startSequel("Major Arcana");
					
		MAJOR_ARCANA_CARDS.each {|cardName| 
		
			generator.generateCard(cardName.gsub /[\n]/, '');
			
		}	

		generator.endSequel();
		
		
		
		
		
		Minor_Arcana_Sets.each { |setName|
		
			generator.startSequel(setName, "Minor Arcana", setName);
			
			Minor_Arcana_Count.times { |minorArcanaCardIndexInSequel|
			
				generator.generateCard("#{Minor_Arcana_Personae[minorArcanaCardIndexInSequel]} of #{setName}");
			
			}
			
			generator.endSequel();	
		
		}





	generator.endSequels();

generator.endSession();




